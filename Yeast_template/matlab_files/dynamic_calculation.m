function [ic,data] = dynamic_calculation(Data_folder,time,ic,parameters)
% Data_Folder is the folder to put the microscope image
% Time is the current time stamp
% ic is the initial condition
% n_well is the number of wells

if ~exist(fullfile(Data_folder,'intermediate_data'),"dir")  
    mkdir(fullfile(Data_folder,'intermediate_data'))
end

n_well = parameters.n_well;
open_loop = parameters.open_loop;
history_experiment = parameters.history_experiment;
is_history = process_experiment(history_experiment);
% run = 'RUN';
% process images in batch
data = struct();
% Data_folder = "E:\MC\data\cell_death_20240314_new_4x_fastER_test_4_8\test";
path_struct.targetFolder = Data_folder;
% path_struct.model_path = "D:\MC\calibration\fastER-model\4x_HeLa_New_microscope_20240322";
path_struct.model_path = "D:\MC\calibration\fastER-model\6x_HeLa_20250307_2";
path_struct.fastER_path = "D:\MC\calibration\fastER-CL";
threads = 4;
% time = 2; % Your time variable
formatted_time = sprintf('%06d', time); % Formats the time as a six-digit number with leading zeros
pattern_collection.brightfield = ['^\d+_brightfield_z1_t', formatted_time, '\.tif$'];
pattern_collection.Cy3 = ['^\d+_Cy3_z1_t', formatted_time, '\.tif$'];
pattern_collection.Cy5 = ['^\d+_Cy5_z1_t', formatted_time, '\.tif$'];
multithread_process_image(path_struct,pattern_collection,threads)

channels = {'brightfield','Cy3','Cy5'}; % Hard coded for now
[area,dataCell,cell_number] = stats_calculation(path_struct,pattern_collection,threads,channels,time); % Cell number calculate the number of cells recognized
data.area = area;

save(fullfile(Data_folder, '\intermediate_data\', strcat('t',num2str(time,'%06d'),'output_data','.mat')),"dataCell") 

    if ~open_loop % Only run the multiple dynamic system for closed-loop
        if time == 1
            if is_history % If there is a history experiment
                acc_error_temp = load(fullfile(history_experiment, '\data\acc_error_log.mat')).acc_error_log;
                input_list.acc_error = acc_error_temp(end,:);
            else 
                input_list.acc_error = zeros(1,n_well);
            end
        else
            load(fullfile(Data_folder, '\intermediate_data\', strcat('t',num2str(time-1,'%06d'),'acc_error','.mat')))
            input_list.acc_error = acc_error;
        end
        input_list.area = area;
        [light,acc_error] = Multiple_dynamic_system(input_list,ic);
        save(fullfile(Data_folder, '\intermediate_data\', strcat('t',num2str(time,'%06d'),'acc_error','.mat')),"acc_error") 
        data.intensity = light;
        data.acc_error = acc_error;
    end
end