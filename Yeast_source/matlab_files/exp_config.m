function [config_exp] = exp_config(imagingFolderName)


    % PWM pattent setup

    % Progressive PWM pattern with increasing cycle periods
    cycle_periods = [30, 60, 90, 120, 150, 180, 210, 240, 270, 300]; % seconds
    pwm_duration = 300; % 5 minutes
    off_duration = 1200; % 20 minutes

    times = [];
    values = [];

    for i = 1:length(cycle_periods)
        % Add 20 min off period
        times = [times, off_duration];
        values = [values, 0];
        
        cycle_period = cycle_periods(i);
        
        if cycle_period == 300
            % Constant light for 5 minutes
            times = [times, 300];
            values = [values, 1];
        else
            % Generate PWM with 50% duty cycle
            [pwm_times, pwm_values] = pwm_pattern(pwm_duration, cycle_period/2, cycle_period/2);
            times = [times, pwm_times];
            values = [values, pwm_values];
        end
    end

    % Final 20 min off period
    times = [times, off_duration];
    values = [values, 0];

    times_pwm_pattern = times;
    values_pwm_pattern = values;

    %% CONFIGURATION PARAMETERS
    config_exp = [];
    %% EXPERIMENT SPECIFIC PARAMETERS
    config_exp.experiment_name = 'Yeast_Git';
    config_exp.time_date = '20251002';
    config_exp.time_hour = '112317';
    config_exp.organism = 'Yeast';
    config_exp.objective_type = '40x_oil';
    config_exp.magnification = '40x*1.5=60x';
    config_exp.strains = 'BGE';
    config_exp.initial_delay = 60*10; %% In seconds
    config_exp.experiment_pattern_times = times_pwm_pattern;	
    config_exp.experiment_pattern_values = values_pwm_pattern;
    config_exp.Period = 60;
    config_exp.intensity = 17.3;
    config_exp.light_normalization = 69.2;
    config_exp.imaging.types = {'brightfield','Cy3'};
    config_exp.imaging.groups = {'Channels','Trigger'};
    config_exp.imaging.exposure = {10, 2000};
    config_exp.imaging.zOffsets = {[0], [0]};
    config_exp.imaging.condenser = {5, 5};
    config_exp.imaging.message = ['Testing 5m / 30xK second PWM pattenring with 20m pauses'];
    config_exp.UsingPFS = true;
end
