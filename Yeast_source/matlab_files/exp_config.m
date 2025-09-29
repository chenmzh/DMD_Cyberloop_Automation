function [config_exp] = exp_config(imagingFolderName)

    %% CONFIGURATION PARAMETERS
    config_exp = [];
    %% EXPERIMENT SPECIFIC PARAMETERS
    config_exp.experiment_name = 'Yeast_Git';
    config_exp.time_date = '20250929';
    config_exp.time_hour = '121809';
    config_exp.organism = 'Yeast';
    config_exp.objective_type = '40x_oil';
    config_exp.magnification = '40x*1.5=60x';
    config_exp.strains = 'GE';
    config_exp.initial_delay = 60*20; %% In seconds
    config_exp.experiment_pattern_times = repmat([1200,10,1800,20,1800,30,1800,40,1800,50,1800,60,3200],1,1);
    config_exp.experiment_pattern_values = repmat([0,1,0,1,0,1,0,1,0,1,0,1,0],1,1);
    config_exp.Period = 120;
    config_exp.intensity = 17.3;
    config_exp.light_normalization = 69.2;
    config_exp.imaging.types = {'brightfield','Cy3'};
    config_exp.imaging.groups = {'Channels','Trigger'};
    config_exp.imaging.exposure = {10, 2000};
    config_exp.imaging.zOffsets = {[0], [0]};
    config_exp.imaging.condenser = {5, 5};
    config_exp.imaging.message = ['shorter patterns to test limitation, with new 3-D printed plate holder, add PFS function and specific capturing function for implementation, PFS enabled, with new strain'];
    config_exp.UsingPFS = true;
end
