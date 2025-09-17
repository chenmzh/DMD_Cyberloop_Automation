function [config_exp] = exp_config(imagingFolderName) 
 
    % CONFIGURATION PARAMETERS 
    config_exp = []; 
    % EXPERIMENT SPECIFIC PARAMETERS 
    config_exp.experiment_name = 'test'; 
    config_exp.time_date = '20250917'; 
    config_exp.time_hour = '173933'; 
    config_exp.organism = 'organism'; 
    config_exp.objective_type = 'objective_type'; 
    config_exp.magnification = 'magnification'; 
    config_exp.strains = 'strains'; 
    config_exp.initial_delay = 60*0; % In seconds
    config_exp.experiment_pattern_times = [20, 20, 20, 20, 20] * 60 ;
    config_exp.experiment_pattern_values = [0, 1, 0, 1, 0];
    config_exp.Period = 120;
    config_exp.intensity = 17.3;
    config_exp.light_normalization = 69.2;
    config_exp.imaging.types = {'brightfield','Cy3'};
    config_exp.imaging.groups = {'Channels','Trigger'};
    config_exp.imaging.exposure = {10, 2000};
    config_exp.imaging.zOffsets = {[0,-0.5,+0.5], [0]};
    config_exp.imaging.condenser = {5, 5};
end 
