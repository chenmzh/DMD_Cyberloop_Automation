function [] = capture_images(config, imaging, xy, posNum, microscope,current_pattern)

numImagingTypes = length(imaging.types);
camera = microscope.getCameraDevice();

% % the following 2 are commented before
% microscope.getDevice(config.devicePFSOffset).getProperty(config.propertyPFSOffset).setValue(num2str(xy.pfsOffset(posNum)));
% pause(0.5);


currentZ = str2num(microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).getValue());

for indx=1:numImagingTypes
    for zIndx = 1:numel(imaging.zOffsets{indx})
        
        
        % Set condenser
        microscope.getDevice(config.deviceCondenser).getProperty(config.propertyCondenser).setValue(num2str(imaging.condenser{indx}));
        
        % Set z value
        microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(num2str(currentZ+imaging.zOffsets{indx}(zIndx)));
        pause(0.5);
        
        % Take image
        
        % set shuttle state to desired 
        if current_pattern == 1 
            if strcmp(imaging.types{indx}, 'projector_capturing')
                microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');
            elseif strcmp(imaging.types{indx}, 'Cy3')
                microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');
            end
        end
        %     if current_pattern == 1 && strcmp(imaging.types{indx}, 'projector_capturing')
        % microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');   
        % end
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
        imwrite(matlabImage, fullfile(config.imageFileLocation, [num2str(posNum, '%01d') '_' imaging.types{indx} '_z' num2str(zIndx) '_t' num2str(config.sampleNum, '%06d') '.tif']));
        imageEvent = [];
        imageType = [];
        matlabImage = [];
        
    end
end

% Bring back to original z
% microscope.getDevice(config.deviceZDrive).getProperty(config.propertyZDrive).setValue(currentZ);

end