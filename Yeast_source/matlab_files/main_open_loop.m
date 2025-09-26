%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main open loop - DMD illumination with predefined intensities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This version uses intensities from layout.xlsx instead of feedback control
% Intensity scaling is controlled by light_normalization parameter in config.json
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


original_root_folder = pwd();

% Set the codebase folder
code_folder =  'Y:\khammash\MC\microscope\experiment_git_sync\Fake_DMD_test\Yeast_source';
cd([fullfile(code_folder,'matlab_files')]);


%% sending messages when error
% Set up email sending preferences
mail = 'MingzheMicroscope@gmail.com'; % Your Gmail address
password = 'tflcemzdmypjmsku'; % Your Gmail password
server = 'smtp.gmail.com';
port = '465';

% set up Telegram bot 
telegram_send = telepush('host', "10.146.224.80", 'port', 8787, 'secret', "change-me");

setpref('Internet', 'E_mail', mail);
setpref('Internet', 'SMTP_Server', server);
setpref('Internet', 'SMTP_Username', mail);
setpref('Internet', 'SMTP_Password', password);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth', 'true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', port);

% Read exp_config file
config_exp = exp_config()
date = config_exp.time_date; 
hour = config_exp.time_hour; 
experiment_name = config_exp.experiment_name;
organism = config_exp.organism;
objective_type = config_exp.objective_type;
magnification = config_exp.magnification;
strains = config_exp.strains;
initial_delay = config_exp.initial_delay;
experiment_pattern_times = config_exp.experiment_pattern_times;
experiment_time_length = sum(experiment_pattern_times); 
experiment_pattern_times_cumulative = cumsum(experiment_pattern_times);
experiment_pattern_values = config_exp.experiment_pattern_values;
Period = config_exp.Period;
intensity = config_exp.intensity;
light_normalization = config_exp.light_normalization;

%% If using PFS or not
UsingPFS = config_exp.UsingPFS;


imaging.types     = config_exp.imaging.types;        
imaging.groups    = config_exp.imaging.groups;       
imaging.exposure  = config_exp.imaging.exposure;        
imaging.zOffsets  = config_exp.imaging.zOffsets;        
imaging.condenser = config_exp.imaging.condenser;        

additional_git_message = config_exp.imaging.message


%% Setup working path
experiment_root = 'Y:\khammash\MC\microscope';
experiment = experiment_name + "_" + date + hour ;
data_root = 'E:\MC'; 
data_folder = fullfile(data_root,'data',experiment);

currentRun = datestr(now, 'yyyymmddTHHMMSS');
subexperiment_name = strcat('microscope_images_', currentRun);
microscopyFolderName = fullfile(char(data_folder), char(subexperiment_name));
locationFile = fullfile(code_folder, 'multipoints.xml');
log_data_folder =fullfile(microscopyFolderName,'data');
mkdir(log_data_folder)

% instantiate the logger
log = logger(fullfile(log_data_folder, 'log.txt'));
log(['original root folder is ', original_root_folder]);

% Layout intensities are the actual desired intensities in mW/cm^2
actual_intensities = intensity; % These are already in mW/cm^2

% Calculate DMD intensity values (0-255 integers) from actual intensities
% DMD_intensity = round(actual_intensity * 255 / light_normalization)
dmd_intensities = round(actual_intensities * 255 / light_normalization);

% Check if any values exceed 255
if any(dmd_intensities > 255)
    max_actual_intensity = max(actual_intensities);
    max_dmd_intensity = max(dmd_intensities);
    error(['DMD intensity value exceeds 255! Maximum actual intensity: %.3f mW/cm^2 ' ...
           'requires DMD intensity: %d. Please reduce layout intensities or ' ...
           'increase light_normalization factor (current: %.3f mW/cm^2).'], ...
           max_actual_intensity, max_dmd_intensity, light_normalization);
end

% Ensure no negative values
dmd_intensities = max(0, dmd_intensities);


Period_Multiplier = floor(Period/Period); 
Period_Multiplier_temp = Period_Multiplier;

% Fetch the number of wells 
n_well = length(Period);

% Number of wells
parameters.n_well = n_well;
parameters.history_experiment = ""; % Full path for the folder of experiment data
process_experiment(parameters.history_experiment);
positionIndeces = 1:n_well; % for 24 well plate


%% Initialization
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

% INITIAL MICROSCOPE-CONFIGURATION (Projection Shutter closed)
log('DMD shutter to 0...')
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
log('... done')
log('DMD filter block to 0...')
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0'); % Change to empty filter
log('... done')
area_log = [];

% Create DMD patterns based on calculated DMD intensity values
pattern_collection = cell(n_well, 1);
for i = 1:n_well
    if actual_intensities(i) > 0
        % Create a uniform pattern with the calculated DMD intensity (0-255)
        % DMD resolution is typically 1080 by 1920
        dmd_intensity = dmd_intensities(i);
        pattern_collection{i} = ones(1080, 1920) * dmd_intensity;
        fprintf('Well %d: DMD intensity = %d, Actual intensity = %.3f mW/cm^2\n', ...
                i, dmd_intensity, actual_intensities(i));
    else
        % No illumina
        % tion for this well
        pattern_collection{i} = zeros(1080, 1920);
        fprintf('Well %d: No illumination\n', i);
    end
end

%% Try to catch error
% Function that can potentially raise an error
try

    % shutter closed at the start of the experiment 
    log('DMD shutter to 0...')
    microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
    log('... done')

log('setup completed')

% apply initial delay
telegram_send("Starting open loop experiment: " + experiment + " with initial delay of " + num2str(initial_delay) + " seconds.")
pause(initial_delay)
log("starting experiment")

% saving initial starting time
experiment_start_time = datetime('now');

% Set filter block
log("DMD filter block to 1...")
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str('1'));
log("...done")

% initialize temp vars
time_within_the_period = 0;
last_period_start = datetime('now');
is_first_time = true;
last_pattern = -1;
current_pattern = 0;
if UsingPFS
    log("moving to capturing position ...")
    go_to_position_PFS(positionIndeces(1),xyPoints,microscope);
    microscope.getDevice('PFS').getProperty('FocusMaintenance').setValue('On'); % setup PFS
    microscope.getDevice(config.devicePFSOffset).getProperty(config.propertyPFSOffset).setValue(num2str(xyPoints.pfsOffset(positionIndeces(1)))); % Need to turn on PFS first, then change the offset
    pause(2);
    log("...done")
else
    log("moving to capturing position ...")
    go_to_position(positionIndeces(1),xyPoints,microscope);
    log("...done")
end

% set position only once

telegram_send("Microscope moved to position. Starting open loop illumination.")

% Iterate over the loop until time reached
while true
    time_within_the_period = seconds(datetime("now") - last_period_start)
    
    % pausing 1 second between actions for safety (are they blocking operations?)
    if time_within_the_period >= Period | is_first_time
        is_first_time = false;
        last_period_start = datetime("now");
        log('DMD shutter to 0...')
        microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
        log('... done')
        pause(0.5);

        if UsingPFS
            log('Using PFS')
            go_to_position_PFS(positionIndeces(1),xyPoints,microscope); % Without z axis
            log('capturing images...')
            capture_images_PFS(config, imaging, xyPoints, positionIndeces(1), microscope);
            log('... done')
        else
            log('Not using PFS')
            log('capturing images...')
            capture_images(config, imaging, xyPoints, positionIndeces(1), microscope); % Projcetor block would swtich to empty one, but shutter would open after capturing images
            log('... done')
        end
        currentZ = string(microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).getValue());
        log("z value is set to: " + currentZ)
        pause(0.5);
        if current_pattern == 1
            % To activate the DMD path, need to set the projector block to correct position
            log('DMD filter block to 1...')
            microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str('1'));
            log('... done')
            log('DMD shutter to 1...')
            microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');
            log('... done')
        end
        config.sampleNum = config.sampleNum + 1; % Addup 1 sampleNum(time stamp)
    end
    
    % Illuminate with predefined pattern (no need to skip first run since patterns are pre-calculated)  

    current_time = datetime('now');
    dt = current_time - experiment_start_time;
    total_experiment_time = seconds(dt);

    pattern_index = find(experiment_pattern_times_cumulative > total_experiment_time, 1, 'first'); % search for current pattern index

    if length(pattern_index) > 0
        current_pattern = experiment_pattern_values(pattern_index);

        if last_pattern ~= current_pattern
            log(['Changing pattern from ' num2str(last_pattern) ' to ' num2str(current_pattern)])
            if current_pattern == 1
                log('DMD filter block to 1...')
                microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str('1'));
                log('... done')
                log('DMD shutter to 1...')
                microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');
                log('... done')
                % img_matrix = pattern_collection{positionIndeces(1)};
                % experiment_dmd.display(img_matrix);
            else
                log('DMD shutter to 0...')
                microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
                log('... done')
                % img_matrix = zeros(1080,1920);
                % experiment_dmd.display(img_matrix);
            end
            last_pattern = current_pattern
        end

    end
               
    % check if we have reached the time limit:
    current_time = datetime('now');
    dt = current_time - experiment_start_time;
    total_experiment_time = seconds(dt);

    if total_experiment_time > experiment_time_length

        % Folder on server to storage images after finishing experiment
        root_destination_folder = 'Y:\khammash\MC\microscope\CyGenTiG_AUTO'
        destination_experiment_folder = fullfile(root_destination_folder,experiment);
        mkdir(destination_experiment_folder)
        destination_folder = fullfile(destination_experiment_folder,subexperiment_name);
        mkdir(destination_folder)

        % Open projection shutter to start illumination
        log('DMD shutter to 0...')
        microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
        log('... done')
        command = sprintf('Y:\\khammash\\MC\\microscope\\experiment_git_sync\\Fake_DMD_test\\syncexp.bat "%s"', additional_git_message);
        system(command);
        exp_info = struct();
        exp_info.runtime = total_experiment_time;
        exp_info.file_path = fullfile(log_data_folder,'summary.txt');
        exp_info.end_time_stamp = current_time

        create_summary(exp_info);


        % Copy file after summary generated
        copyfile(microscopyFolderName, destination_folder);

        telegram_send("Open loop experiment: " + experiment + " completed successfully! Total time: " + num2str(total_experiment_time) + " seconds. Data copied to server.")
        error("Time limit reached, bye bye!");
    end

end

catch ME
    % Send email when an error is caught
    subject = 'MATLAB Error Notification - Open Loop';
    message = sprintf('An error occurred in your MATLAB open loop script:\n\nError: %s\n\nLocation: %s\n\nDetails: %s', ...
                      ME.message, ME.stack.name, ME.stack.file);
    sendmail('cmzcswxp@gmail.com', subject, message);
    rethrow(ME);
end