function [config_exp] = exp_config(imagingFolderName)

    %% CONFIGURATION PARAMETERS
    config_exp = [];
    %% EXPERIMENT SPECIFIC PARAMETERS
    config_exp.experiment_name = 'Yeast_Git_';
    config_exp.time_date = '20250918';
    config_exp.time_hour = '132618';
    config_exp.organism = 'Yeast';
    config_exp.objective_type = '40x_oil';
    config_exp.magnification = '40x*1.5=60x';
    config_exp.strains = 'Nuclear translocation';
    config_exp.initial_delay = 60*20; %% In seconds
    config_exp.experiment_pattern_times = repmat([5,15],1,9)*60;
    config_exp.experiment_pattern_values = repmat([1,0],1,9);
    config_exp.Period = 120;
    config_exp.intensity = 17.3;
    config_exp.light_normalization = 69.2;
    config_exp.imaging.types = {'brightfield','Cy3'};
    config_exp.imaging.groups = {'Channels','Trigger'};
    config_exp.imaging.exposure = {10, 2000};
    config_exp.imaging.zOffsets = {[0], [0]};
    config_exp.imaging.condenser = {5, 5};
    config_exp.imaging.message = ['Testing the shorter pattern with higher frequency, with 5 mins illumination and 15 mins darkness,\n ' ...
    ' Still use the GUI so intensity does not make sense, set it to 50/255'];
end
