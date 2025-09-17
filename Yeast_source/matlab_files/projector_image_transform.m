function outputImage = projector_image_transform(inputImage)
% Process image to be projected according to the mapping between real image
% and the input image using projectionParams_6x_20250717.mat calibration

    % Find calibration file
    current_dir = fileparts(mfilename('fullpath'));
    dmd_data_path = fullfile(current_dir, '..', 'DMD_closed_loop_Left_right_half', 'data');
    calib_file = fullfile(dmd_data_path, 'projectionParams_6x_20250806.mat');
    
    if ~exist(calib_file, 'file')
        error('Calibration file not found: %s', calib_file);
    end
    calibParams = load(calib_file);
    segImage = inputImage;
    % segImage(segImage>0) = 255;
    % segImage = flip(segImage,2);
    segImageColored = zeros([2048 2048]);
    segImageColored(:,:) = segImage;
    segImageScaled = imresize(segImageColored, 0.5273); % 1080/2048
    projPatch = imwarp(segImageScaled, calibParams.tformPoly);
    projPatch = flip(projPatch,2);
    
    % Add paths for required functions
    script_dir = fileparts(mfilename('fullpath'));
    
    % Add DMD driver path
    dmd_path = fullfile(script_dir, 'driverDMD');
    if exist(dmd_path, 'dir')
        addpath(genpath(dmd_path), '-end');
    end
    
    
    corrProjectionImage = resizePatch(projPatch, [1920, 1080], -calibParams.tformOffset);
    % corrProjectionImage(corrProjectionImage>0) = 255;
    corrProjectionImage(corrProjectionImage<0) = 0;
    outputImage = int64(corrProjectionImage);
end
