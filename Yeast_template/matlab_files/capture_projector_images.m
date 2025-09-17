function [] = capture_projector_images(config, xy, posNum, microscope, corrProjectionImage, dmd)
% Capture projector images using existing DMD object
% 
% Parameters:
%   config - microscope configuration
%   xy - position coordinates
%   posNum - position number
%   microscope - microscope object
%   corrProjectionImage - projection pattern to display
%   dmd - initialized DMD object (avoids reinitialization issues)

imaging.types = {'projector'};
imaging.exposure = {50};
imaging.zOffsets = {[0]};
imaging.condenser = {6};
imaging.groups = {'Channels'};
numImagingTypes = length(imaging.types);

camera = microscope.getCameraDevice();
currentZ = str2num(microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).getValue());

for indx=1:numImagingTypes
    for zIndx = 1:numel(imaging.zOffsets{indx})
        
        % Set condenser
        microscope.getDevice(config.deviceCondenser).getProperty(config.propertyCondenser).setValue(num2str('6'));
        
        % Set z value
        microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(currentZ));
        pause(0.5);
        
        % Setup filters and shutters
        % microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str('1'));
        microscope.getDevice(config.deviceFilterBlockFluo).getProperty(config.propertyFilterBlock).setValue(num2str('1'));
        microscope.getDevice(config.deviceShutterFluo).getProperty(config.propertyShutter).setValue('0');
        % microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
        
        % Use existing DMD object instead of creating new one
        if nargin < 6 || isempty(dmd)
            % Fallback: create DMD only if not provided
            fprintf('Warning: DMD not provided, creating new one (may cause issues)\n');
            
            % Try to add path only if needed
            if ~exist('DMD', 'class')
                current_dir = fileparts(mfilename('fullpath'));
                dmd_path = fullfile(current_dir, 'driverDMD');
                if exist(dmd_path, 'dir')
                    addpath(genpath(dmd_path), '-end');
                else
                    error('DMD driver path not found: %s', dmd_path);
                end
            end
            
            dmd = DMD;
            dmd.definePattern;
            dmd.setMode(3);
        end
        
        % Display projection pattern
        dmd.display(corrProjectionImage);
        % microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');
        
        % Take image
        imageEvent = camera.makeImage(imaging.groups{indx}, imaging.types{indx}, imaging.exposure{indx});
        imageType = ['uint', mat2str(8 * imageEvent.getBytesPerPixel())];
        matlabImage = reshape(typecast(imageEvent.getImageData(), imageType), imageEvent.getWidth(), imageEvent.getHeight())';
        
        % Flip dimensions if necessary
        if imageEvent.isTransposeY()
            matlabImage = flipud(matlabImage);
        end
        if imageEvent.isTransposeX()
            matlabImage = fliplr(matlabImage);
        end
        if imageEvent.isSwitchXY()
            matlabImage = matlabImage';
        end
        
        % Save captured image
        imwrite(matlabImage, [config.imageFileLocation filesep num2str(posNum, '%01d') '_' imaging.types{indx} '_z' num2str(zIndx) '_t' num2str(config.sampleNum, '%06d') '.tif']);
        
        % Cleanup variables
        imageEvent = [];
        imageType = [];
        matlabImage = [];
        
        % Reset shutters and filters
        microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
        microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0');
    end
end



end