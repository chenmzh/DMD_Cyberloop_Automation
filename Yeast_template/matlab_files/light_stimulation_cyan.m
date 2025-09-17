function [] = light_stimulation_cyan(config, intensity, fluoBlock, NDfilter, time, microscope)

microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue(num2str(NDfilter));
microscope.getDevice(config.deviceSpectra).getProperty(config.propertySpectraState).setValue('1');
microscope.getDevice(config.deviceSpectra).getProperty(config.propertyCyanIntensity).setValue(num2str(intensity));
microscope.getDevice(config.deviceFilterBlockFluo).getProperty(config.propertyFilterBlock).setValue(num2str(fluoBlock));
if intensity == 0
    microscope.getDevice(config.deviceShutterFluo).getProperty(config.propertyShutter).setValue('0');
    microscope.getDevice(config.deviceSpectra).getProperty(config.propertyCyanEnable).setValue('0');
else
    microscope.getDevice(config.deviceShutterFluo).getProperty(config.propertyShutter).setValue('1');
    microscope.getDevice(config.deviceSpectra).getProperty(config.propertyCyanEnable).setValue('1');
end
pause(time);
microscope.getDevice(config.deviceShutterFluo).getProperty(config.propertyShutter).setValue('0');
microscope.getDevice(config.deviceSpectra).getProperty(config.propertyCyanEnable).setValue('0');
microscope.getDevice(config.deviceSpectra).getProperty(config.propertyCyanIntensity).setValue('0');
microscope.getDevice(config.deviceSpectra).getProperty(config.propertySpectraState).setValue('0');
microscope.getDevice(config.deviceFilterBlockProj).getProperty(config.propertyFilterBlock).setValue('0');

end