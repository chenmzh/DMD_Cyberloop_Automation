function [config_exp] = exp_config(imagingFolderName)


    % PWM pattent setup

    % Progressive PWM pattern with increasing cycle periods
    
    cycle_total_on_time = [240, 240, 360, 360, 480, 480]; % seconds, total on time
    % cycle_on_time = [30, 60, 120, 180, 240, 300]; % seconds
    
    pwm_duration = 480; % 8 minutes
    off_duration = 600; % 10 minutes, extra off time between different cycle on time.
    % Pulsatile Period
    PP = 30 % 0.5 mins, total on time will be spread out during the pwm_duration
    Frequency = pwm_duration/PP
    On_time_list = cycle_total_on_time/Frequency

    times = [];
    values = [];

    for i = 1:length(cycle_total_on_time)
        
        % Add 20 min off period
        times = [times, off_duration];
        values = [values, 0];
        
        On_time = On_time_list(i);
        if On_time > PP
            On_time = PP
        end
        % Generate PWM with 50% duty cycle
        % [pwm_times, pwm_values] = pwm_pattern(pwm_duration, cycle_period/2, cycle_period/2);
        [pwm_times, pwm_values] = pwm_pattern(pwm_duration, On_time, PP - On_time); % pwm_times return the pattern that spreading the cycle total on time to the pwm period 
        times = [times, pwm_times];
        values = [values, pwm_values];

    end

    % Final 10 min off period
    times = [times, off_duration];
    values = [values, 0];

    times_pwm_pattern = times;
    values_pwm_pattern = values;

    %% CONFIGURATION PARAMETERS
    config_exp = [];
    %% EXPERIMENT SPECIFIC PARAMETERS
    config_exp.experiment_name = 'Yeast_Git';
    config_exp.time_date = '20251010';
    config_exp.time_hour = '123909';
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
    config_exp.imaging.message = ['Test DMD pattern. Background 1.6uW, 2048*0.07um/pixel = 143.36um, 37.6uW - 1.6 = 36uW before, = 0.00175uW/um^2 = 175mW/cm^2, with 50/255, power is 8.73uW, 8.73-1.6 = 7.13uW. normalized to be 34.7mW/cm^2, keep lowering it by 3.4 times. targeting light value is 10mW/cm^2, which is roughly 2uW, add background 1.6 which is 3.6uW. In conclustion, its lowered by 4 times compared with previous setup. Using patterns C:\Users\Localadmin\Desktop\sant_workspace\sample_patterns\checkerboard_fullHD_int8_0_50_1920x1080.png, tested with high duty cycle'];
    config_exp.UsingPFS = true;
end
