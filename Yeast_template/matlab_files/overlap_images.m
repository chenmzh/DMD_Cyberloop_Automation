% Define the input and output directories
root_dir = "E:\MC\data\cell_death_20250505_Cygentig_6x_closed_loop\microscope_images_20250506T160820";


original_dir = fullfile(root_dir,'\normalization');
% mask_dir = fullfile(root_dir,'\segmentation');
mask_dir = fullfile(root_dir,'\segmentation');
output_dir = fullfile(root_dir,'overlay');

% Create output directory if it doesn't exist

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Get list of files in original directory
files = dir(fullfile(original_dir, '*_brightfield_z1_t*.tif'));

% Define transparency level (0 to 1, where 1 is fully opaque)
alpha = 0.2;  % Adjust this value to control transparency

% % Start parallel pool if not already running
% if isempty(gcp('nocreate'))
%     parpool();
% end

% Process files in parallel
% parfor i = 1:length(files)
for i = 1:length(files)
    % Read original image
    original_path = fullfile(original_dir, files(i).name);
    original_img = imread(original_path);
    
    % Read corresponding mask
    mask_path = fullfile(mask_dir, files(i).name);
    mask = imread(mask_path);
    
    % Binarize mask (make values > 1 maximum)
    mask = mask > 1;
    
    % Create RGB version of original image
    original_rgb = cat(3, original_img, original_img, original_img);
    
    % Create cyan overlay
    cyan_overlay = zeros(size(original_rgb), 'uint8');
    cyan_overlay(:,:,2) = uint8(mask) * 255; % Green channel
    cyan_overlay(:,:,3) = uint8(mask) * 255; % Blue channel
    
    % Blend original and overlay using alpha
    overlay_img = uint8(double(original_rgb) .* (1 - (alpha * double(mask))) + ...
                       double(cyan_overlay) .* (alpha * double(mask)));
    
    % Save overlaid image
    output_path = fullfile(output_dir, files(i).name);
    imwrite(overlay_img, output_path);
    
    % Display progress
    fprintf('Processed %s (%d/%d)\n', files(i).name, i, length(files));
end

fprintf('Processing complete!\n');  