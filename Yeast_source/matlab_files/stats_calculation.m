
%% process image

%% update 20240314 using only z1 for segmentation, not preprocess images. For example image, refer to group folder 
% N:\khammash\MC\microscope\Remote_desktop_analysis\MATLAB\cell_area_analysis_with_fastER\test
function [area,dataCell,cell_number] = stats_calculation(path_struct,pattern_collection,threads,channels,time)

targetFolder = path_struct.targetFolder;
target_seg_Folder = fullfile(targetFolder,'segmentation');



% Initialize parallel pool with 36 workers
poolobj = gcp('nocreate'); % Check if a pool already exists
if isempty(poolobj)
    parpool(threads); % Adjust the number of workers as needed
elseif poolobj.NumWorkers ~= threads
    delete(poolobj); % Close the existing pool
    parpool(threads); % Open a new pool with 36 workers
end


n_channels = length(channels);
timepoint = time;

% % Get a list of all files in the target folder
% files = dir(fullfile(target_seg_Folder, pattern)); % Optimized to only list .tif files


allFiles = dir(fullfile(targetFolder, '*.tif')); 

% Extract the leading numbers from each filename and convert them to numbers
numericParts = arrayfun(@(x) str2double(regexp(x.name, '^\d+', 'match', 'once')), allFiles);

% Sort the numeric parts and use the index to sort allFiles
[~, sortIndex] = sort(numericParts);
allFiles = allFiles(sortIndex);



for ch_i = 1 : length(channels) 
    matchedFiles.(channels{ch_i}) = {};
end



for ch_i = 1 : n_channels 
for i = 1:length(allFiles)
    fileName = allFiles(i).name;
    if ~isempty(regexp(fileName, pattern_collection.(channels{ch_i}), 'once')) 
        matchedFiles.(channels{ch_i}){end+1} = fileName; 
    end
end
end


sample_num = length(matchedFiles.(channels{1}));
dataCell = cell(sample_num, 1);  % Preallocate a cell array to collect your results
area = zeros(1,sample_num);
cell_number = zeros(1,sample_num);
for i = 1:sample_num
    fileName = [];
    for ch_i = 1 : length(channels) 
        fileName.(channels{ch_i}) = {};
    end
    for ch_i = 1: n_channels
        fileName.(channels{ch_i}) = matchedFiles.(channels{ch_i}){i};
    end
%     fileName = matchedFiles{i};
%     fprintf('Processing file: %s\n', fileName);
    segmented_path = fullfile(target_seg_Folder,fileName.brightfield);
    position = i;

    seg_image = imread(segmented_path);
    identifiers = unique(seg_image);
    n_cells = length(identifiers);

    data_table = zeros(n_channels * n_cells, 8, 'uint32');

    for ch_i = 1:n_channels
        
        temp_data = zeros(n_cells, 3, 'uint32');

        lower_i = (ch_i - 1) * n_cells + 1;
        upper_i = ch_i * n_cells;
        % 1-3 index by position, 4 is timepoint, 5 is channel
        % 5th element is channel(index), brightfield(1), Cy3(2) and Cy5(3)
        data_table(lower_i:upper_i, 1:5) = [repmat(floor(position), n_cells, 1) repmat(get_dec(position, 1), n_cells, 1) repmat(get_dec(position, 2), n_cells, 1) repmat(timepoint, n_cells, 1) repmat(ch_i, n_cells, 1)];

%         img_fl = imread(fullfile(image_location, strcat(num2str(position, '%.2f'), '_', channels{ch_i}, '_z1_t', num2str(timepoint, '%06d'), '.tif')));
%         img_fl = imread(fullfile(image_location, strcat(num2str(position), '_', channels{ch_i}, '_z1_t', num2str(timepoint, '%06d'), '.tif')));
        img_fl = imread(fullfile(targetFolder,fileName.(channels{ch_i}))); % read fluorescence values
        
        % ?? seg_image ????????????????
        seg_image = uint32(seg_image);
        
        % ??seg_image????????????????
        [uniqueIndices, ~, newIndex] = unique(seg_image); % need to check how it flat the matrix

        % ?????????????
        % ?????????
        cellAreas = accumarray(newIndex(:), 1);

        % ?????????????
        cellFluorescence = accumarray(newIndex(:), img_fl(:));

        % ?????????????????
%         cellAverageFluorescence = cellFluorescence ./ cellAreas;
        temp_data = [(0:n_cells-1)', cellFluorescence, cellAreas];
        % ??????? (:)+1 ??? MATLAB ????1????????0???
        % ?? seg_image ????1?????????? +1?
        
%         for id_i = 1:n_cells
% 
%             id = identifiers(id_i);
%             ind = seg_image == id;
%             val_1 = sum(img_fl(ind), 'all');
%             val_2 = sum(ind, 'all');
% 
%             temp_data(id_i, :) = [double(id) val_1 val_2];
%             % data_table(from - 1 + id_i, 4:5) = [double(id) val];
%         end

        data_table(lower_i:upper_i, 6:8) = temp_data;
    end
    area(i) = sum_area(data_table);
    cell_number(i) = cal_cell_number(data_table);
    dataCell{i} = data_table;
end


end