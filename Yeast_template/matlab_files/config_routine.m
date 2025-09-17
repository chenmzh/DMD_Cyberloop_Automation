function [config] = config_routine(imagingFolderName)

    % CONFIGURATION PARAMETERS
    config = [];
    config.deviceFilterBlockFluo = 'FilterTurret1';
    config.deviceFilterBlockProj = 'FilterTurret2';
    config.propertyFilterBlock = 'State';
    config.deviceShutterFluo = 'Turret1Shutter';
    config.deviceShutterProj = 'Turret2Shutter';
    config.propertyShutter = 'State';   
    config.deviceZDrive = 'ZDrive';
    config.propertyZDrive = 'Position';
    config.devicePFSOffset = 'PFSOffset';
    config.propertyPFSOffset = 'Position';
    config.imageFileLocation = imagingFolderName;
    config.sampleNum = 1;
    config.blackImage = zeros(1080,1920);
    config.deviceSpectra = 'Spectra';
    config.propertyBlueEnable = 'Blue_Enable';
    config.propertyBlueIntensity = 'Blue_Level';
    config.propertyCyanEnable = 'Cyan_Enable';
    config.propertyCyanIntensity = 'Cyan_Level';
    config.propertySpectraState = 'State';
    config.deviceCondenser = 'CondenserTurret';
    config.propertyCondenser = 'State';
    
end