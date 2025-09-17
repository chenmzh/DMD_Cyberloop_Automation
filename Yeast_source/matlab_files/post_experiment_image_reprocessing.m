% Input parameter: Data_folder,end_time,

% Data_Folder is the folder to put the microscope image
% Time is the current time stamp
% ic is the initial condition
% n_well is the number of wells


Data_folder = 'E:\MC\data\cell_death_20250218_Cygentig_6x_closed_loop\microscope_images_20250218T150959';
end_time = 136; % The endpoint of time
n_well = 6;

area_log = zeros(end_time, n_well);
seg_folder = fullfile(Data_folder,'segmentation');
if ~exist(seg_folder,"dir")  
    mkdir(seg_folder)
end

for time = 1:end_time
    % run = 'RUN';

    % process images in batch
    data = struct();
    % Data_folder = "E:\MC\data\cell_death_20240314_new_4x_fastER_test_4_8\test";
    path_struct.targetFolder = Data_folder;
    % path_struct.model_path = "D:\MC\calibration\fastER-model\4x_HeLa_New_microscope_20240322";
    path_struct.model_path = "D:\MC\calibration\fastER-model\6x_HeLa_for_normalization_20250219";
    path_struct.fastER_path = "D:\MC\calibration\fastER-CL";
    threads = 4;
    % time = 2; % Your time variable
    formatted_time = sprintf('%06d', time); % Formats the time as a six-digit number with leading zeros
    pattern_collection.brightfield = ['^\d+_brightfield_z1_t', formatted_time, '\.tif$'];
    pattern_collection.Cy3 = ['^\d+_Cy3_z1_t', formatted_time, '\.tif$'];
    pattern_collection.Cy5 = ['^\d+_Cy5_z1_t', formatted_time, '\.tif$'];
%     multithread_process_image(path_struct,pattern_collection,threads,seg_folder)
    channels = {'brightfield','Cy3','Cy5'}; % Hard coded for now
    [area,dataCell,~] = stats_calculation(path_struct,pattern_collection,threads,channels,time);
    area_log(time,:) = area;
    fprintf("done %s time\n", time)
end


save(fullfile(seg_folder,'area_log.mat'),"area_log")
% save(fullfile(Data_folder,'post_processing','area_log.mat'),"area_log")