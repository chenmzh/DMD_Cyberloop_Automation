%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Microscope setup:
% - standard configuration was used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sending messages when error
% Set up email sending preferences
mail = 'MingzheMicroscope@gmail.com'; % Your Gmail address
password = 'tflcemzdmypjmsku'; % Your Gmail password
server = 'smtp.gmail.com';
port = '465';

setpref('Internet', 'E_mail', mail);
setpref('Internet', 'SMTP_Server', server);
setpref('Internet', 'SMTP_Username', mail);
setpref('Internet', 'SMTP_Password', password);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', port);


%% Setup working path
experiment_root = 'Y:\khammash\MC\microscope';
experiment = 'cell_death_20250817_DMD_opened_loop';
code_folder =  fullfile(experiment_root,'experiment',experiment);
data_root = 'E:\MC';
data_folder = fullfile(data_root,'data',experiment);

cd([fullfile(code_folder,'matlab_files')]);
currentRun = datestr(now, 'yyyymmddTHHMMSS');
microscopyFolderName = fullfile(data_folder, strcat('microscope_images_', currentRun));
locationFile = fullfile(code_folder, 'multipoints.xml');
mkdir(fullfile(microscopyFolderName,'data'))

% Process python files
python_path = fullfile(code_folder,'DMD_closed_loop_Left_right_half');
python_input_path = fullfile(microscopyFolderName,'segmentation');
python_output_path = fullfile(microscopyFolderName,'py_output');
if ~exist(python_output_path,'dir')
    mkdir(python_output_path);
end

% Edit config file for input and output path
modify_config(fullfile(python_path,'config.json'), 'input.input_dir', python_input_path)
modify_config(fullfile(python_path,'config.json'), 'output.output_dir', python_output_path)

%% read the layout
% Output contain the layout info in 1 dimension, size is the dimension of layout
[Output,Size] = read_layout(code_folder);
Period = Output{1};
intensity = Output{2};
Illumination_time = Output{3};

Using_DMD = true;

% Initialize DMD once for the entire experiment to avoid reinitialization issues
if Using_DMD
    fprintf('Initializing DMD for the experiment...\n');
    
    % Add DMD path from local matlab_files folder
    current_dir = fileparts(mfilename('fullpath'));
    dmd_path = fullfile(current_dir, 'driverDMD');
    if exist(dmd_path, 'dir')
        addpath(genpath(dmd_path), '-end');
        if usejava('desktop')
            fprintf('✓ Added DMD driver path: %s\n', dmd_path);
        end
    else
        warning('DMD driver path not found: %s', dmd_path);
    end
    
    % Initialize DMD once for the entire experiment
    try
        experiment_dmd = DMD;
        experiment_dmd.definePattern;
        experiment_dmd.setMode(3);
        if usejava('desktop')
            fprintf('✓ DMD initialized successfully\n');
        end
    catch ME
        fprintf('❌ DMD initialization failed: %s\n', ME.message);
        error('Cannot initialize DMD. Experiment cannot continue.');
    end
end

% Let's assume period should be the multiples of 10
% Check if it's multiple of 10 first
if any(mod(Period,10))
    error("The period should be multiples of 10")
end

% Calculate the multiplier of Period
% PERIOD FOR IMAGING
period = 10 * 60; % seconds
Period_Multiplier = floor(Period/10); % in minutes
Period_Multiplier_temp = Period_Multiplier;

% Fetch the number of wells 
n_well = length(Period);

% Number of wells
% It has to be 24 if using the Multiple_dynamic_system as the dynamic
% system function
parameters.n_well = n_well;
parameters.history_experiment = ""; % Full path for the folder of experiment data
process_experiment(parameters.history_experiment);

positionIndeces = 1:n_well; % for 24 well plate

%% Parameters
run = "RUN";

%% USER DEFINED IMAGING PARAMETERS
imaging.types = {'brightfield','Cy3','Cy5'};
imaging.groups = {'Channels','Trigger','Trigger'};
imaging.exposure = {5, 500, 500};
imaging.zOffsets = {[0], [0], [0]};
imaging.condenser = {5, 5, 5};
imaging.n_subimages = 3; %^2
imaging.field_diagonal = 1.3 * 10 ^ 3; % um


%%

% STIMULATION DELAY
stimDel = -Inf; %ceil(6 * 60 * 60 / period);
stimDur = Inf; %ceil(48 * 60 * 60 / period);


%% Initialization

% ADJUST FOR TRAINING
imgTraining = imaging;
imgTraining.n_subimages = 1;

% MAKE MICROSCOPY FOLDER
mkdir(microscopyFolderName);

% INITIALIZE CONFIGURATIONS
config = config_routine(microscopyFolderName);

% GET XY LOCATIONS AND PFS_OFFSET
xyPoints = extract_nis_locations(locationFile);




% Run through plate from A01 to A10, then B01 to B10
sort_array = true;

if sort_array == true % set it to true, otherwise, also reverse the layout
    [xyPoints.location,index] = sort(xyPoints.location);
    xyPoints.coordinates = xyPoints.coordinates(index,:);
    xyPoints.pfsOffset = xyPoints.pfsOffset(index);
    xyPoints.zPosition = xyPoints.zPosition(index);
else
    % reverse the excel files
    % todo
end

intensity = Output{2};

% INITIAL MICROSCOPE-CONFIGURATION (Projection Shutter closed)
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0'); % Change to empty filter
area_log = [];

Intensity_log = intensity;
ic = intensity;
acc_error_log = zeros(1,n_well);


%% Try to catch error
% Function that can potentially raise an error
try

for loopNum = 1:100000
    loopStart = tic;
    for posIndx = positionIndeces
        if Period_Multiplier_temp(posIndx) ~= 0 % skip the period = 0 samples
            go_to_position(posIndx,xyPoints,microscope);
            pause(1);
            capture_images(config, imaging, xyPoints, posIndx, microscope);
            if config.sampleNum ~=1 % Pass the illumination for the first run
                if Period_Multiplier_temp(posIndx) == 1
                    if loopNum > stimDel && loopNum <= stimDur
                        duration = Illumination_time(posIndx);
                        NDfilter = 1;
                        img_matrix = pattern_collection{posIndx};
                        capture_projector_images(config, xyPoints, posIndx, microscope, img_matrix, experiment_dmd)
                        light_stimulation_cyan_DMD(config, NDfilter, duration, microscope, img_matrix, experiment_dmd);                    
                    else
                        pause(1);
                    end
                    Period_Multiplier_temp(posIndx) = Period_Multiplier(posIndx);
                else
                    Period_Multiplier_temp(posIndx) = Period_Multiplier_temp(posIndx) -1;
                end
            end
        end
    end

    % Run segmentation
    [~,data] = dynamic_calculation_DMD(microscopyFolderName,config.sampleNum,ic,parameters);
    
    % Process cell area control with PID and generate DMD patterns using MATLAB
    segmentation_folder = fullfile(microscopyFolderName, 'segmentation');
    config_json_path = fullfile(python_path, 'config.json');
    pattern_collection = process_cell_area_control(segmentation_folder, n_well, config.sampleNum, config_json_path);
    elapsedTime = toc(loopStart);
    if usejava('desktop')
        disp(elapsedTime);
    end
    if config.sampleNum ~=1 % For the first run, not wait for period time
        pause(period - elapsedTime);
    end
    config.sampleNum = config.sampleNum + 1; % Addup 1 sampleNum(time stamp)
end

catch ME
    % Send email when an error is caught
    subject = 'MATLAB Error Notification';
    message = sprintf('An error occurred in your MATLAB script:\n\nError: %s\n\nLocation: %s\n\nDetails: %s', ...
                      ME.message, ME.stack.name, ME.stack.file);
    sendmail('cmzcswxp@gmail.com', subject, message);
    rethrow(ME);
end


