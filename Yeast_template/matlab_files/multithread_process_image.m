function multithread_process_image(path_struct,pattern_collection,threads,target_seg_Folder,varargin)
%MULTITHREAD_PROCESS_IMAGE Summary of this function goes here
%   Detailed explanation goes here
targetFolder = path_struct.targetFolder;
model_path = path_struct.model_path;
fastER_path = path_struct.fastER_path;
pattern = pattern_collection.brightfield;


if nargin < 4
    target_seg_Folder = fullfile(targetFolder,'segmentation');
end

if ~exist(target_seg_Folder, 'dir')
    % If the directory does not exist, create it
    mkdir(target_seg_Folder);
    fprintf('Directory created: %s\n', target_seg_Folder);
else
    fprintf('Directory already exists: %s\n', target_seg_Folder);
end

if nargin < 5
    target_norm_Folder = fullfile(targetFolder,'normalization');
end
if ~exist(target_norm_Folder, 'dir')
    % If the directory does not exist, create it
    mkdir(target_norm_Folder);
    fprintf('Directory created: %s\n', target_norm_Folder);
else
    fprintf('Directory already exists: %s\n', target_norm_Folder);
end


% 获取目标文件夹中所有文件
allFiles = dir(fullfile(targetFolder, '*.tif')); % 使用*.tif来初步筛选TIF文件

% 初始化一个空的 cell array 来存储匹配的文件名
matchedFiles = {};

% 遍历所有文件，使用正则表达式筛选
for i = 1:length(allFiles)
    fileName = allFiles(i).name;
    if ~isempty(regexp(fileName, pattern, 'once')) % 如果文件名匹配正则表达式
        matchedFiles{end+1} = fileName; % 添加到匹配的文件列表中
    end
end


% % Get a list of all files in the target folder
% files = dir(fullfile(targetFolder, pattern)); % Optimized to only list .tif files

% Initialize parallel pool with 36 workers
poolobj = gcp('nocreate'); % Check if a pool already exists
if isempty(poolobj)
    parpool(threads); % Adjust the number of workers as needed
elseif poolobj.NumWorkers ~= threads
    delete(poolobj); % Close the existing pool
    parpool(threads); % Open a new pool with 36 workers
end

% Loop through each file in the directory in parallel
parfor i = 1:length(matchedFiles)
    fileName = matchedFiles{i};
    image_path = fullfile(targetFolder,fileName);
    fprintf('Processing file: %s\n', fileName);
    norm_path = fullfile(target_norm_Folder,fileName);
    normalization(image_path,norm_path)
    segmented_path = fullfile(target_seg_Folder,fileName);
    command = sprintf('"%s" -headless "%s" "%s" "%s"', ...
                      fullfile(fastER_path, 'fastER_qt5_msvc2017.exe'), ...
                      fullfile(model_path, 'trained.fastER'), ...
                      norm_path, ...
                      segmented_path);
    % Execute segmentation command
    seg_flag = system(command);
    if seg_flag ~= 0
        error('Check segmentation (fastER) pipeline for file: %s\n', fileName);
    end
end

end

