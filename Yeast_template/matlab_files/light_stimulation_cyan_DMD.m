function [] = light_stimulation_cyan_DMD(config, NDfilter, time, microscope, corrProjectionImage, dmd)
% Light stimulation using DMD projection with existing DMD object
% 
% Parameters:
%   config - microscope configuration
%   NDfilter - ND filter setting
%   time - illumination duration
%   microscope - microscope object
%   corrProjectionImage - projection pattern
%   dmd - initialized DMD object (avoids reinitialization issues)

% Set filter block
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str('1'));

% Ensure projection shutter is closed initially
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');

% Use existing DMD object instead of creating new one
if nargin < 6 || isempty(dmd)
    error('DMD object must be provided to avoid reinitialization errors');
end

% Display the projection pattern
dmd.display(corrProjectionImage);

% Open projection shutter to start illumination
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('1');

% Wait for the specified illumination time
pause(time);

% Close projection shutter to end illumination
microscope.getDevice(config.deviceShutterProj).getProperty(config.propertyShutter).setValue('0');

% Reset filter block
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0');



end