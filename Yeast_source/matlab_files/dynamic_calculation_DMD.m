function [ic,data] = dynamic_calculation_DMD(Data_folder,time,ic,parameters)
% Data_Folder is the folder to put the microscope image
% Time is the current time stamp
% ic is the initial condition
% n_well is the number of wells

if ~exist(fullfile(Data_folder,'intermediate_data'),"dir")  
    mkdir(fullfile(Data_folder,'intermediate_data'))
end

n_well = parameters.n_well;
history_experiment = parameters.history_experiment;
is_history = process_experiment(history_experiment);
% run = 'RUN';
% process images in batch
data = struct();
% Data_folder = "E:\MC\data\cell_death_20240314_new_4x_fastER_test_4_8\test";
path_struct.targetFolder = Data_folder;
% path_struct.model_path = "D:\MC\calibration\fastER-model\3x_HeLa_New_microscope_20240322";
path_struct.model_path = "D:\MC\calibration\fastER-model\6x_HeLa_20250307_2";
path_struct.fastER_path = "D:\MC\calibration\fastER-CL";
threads = 4;
% time = 2; % Your time variable
formatted_time = sprintf('%06d', time); % Formats the time as a six-digit number with leading zeros
pattern_collection.brightfield = ['^\d+_brightfield_z1_t', formatted_time, '\.tif$'];
pattern_collection.Cy3 = ['^\d+_Cy3_z1_t', formatted_time, '\.tif$'];
% pattern_collection.Cy5 = ['^\d+_Cy5_z1_t', formatted_time, '\.tif$'];
multithread_process_image(path_struct,pattern_collection,threads)

channels = {'brightfield','Cy3'}; % Hard coded for now
[area,dataCell,cell_number] = stats_calculation(path_struct,pattern_collection,threads,channels,time); % Cell number calculate the number of cells recognized
data.area = area;

save(fullfile(Data_folder, '\intermediate_data\', strcat('t',num2str(time,'%06d'),'output_data','.mat')),"dataCell") 

end