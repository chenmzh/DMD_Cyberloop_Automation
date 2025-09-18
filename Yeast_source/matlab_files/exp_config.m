function [config_exp] = exp_config(imagingFolderName)

    %% CONFIGURATION PARAMETERS
    config_exp = [];
    %% EXPERIMENT SPECIFIC PARAMETERS
    config_exp.experiment_name = 'Yeast_Git_testcase';
    config_exp.time_date = '20250917';
    config_exp.time_hour = '180011';
    config_exp.organism = 'Yeast';
    config_exp.objective_type = '40x_oil';
    config_exp.magnification = '40x*1.5=60x';
    config_exp.strains = 'strains';
    config_exp.initial_delay = 60*0; %% In seconds
    config_exp.experiment_pattern_times = [20, 20, 20, 20, 20] * 1 ;
    config_exp.experiment_pattern_values = [0, 1, 0, 1, 0];
    config_exp.Period = 30;
    config_exp.intensity = 17.3;
    config_exp.light_normalization = 69.2;
    config_exp.imaging.types = {'brightfield','Cy3'};
    config_exp.imaging.groups = {'Channels','Trigger'};
    config_exp.imaging.exposure = {10, 2000};
    config_exp.imaging.zOffsets = {[0,-0.5,+0.5], [0]};
    config_exp.imaging.condenser = {5, 5};
end
