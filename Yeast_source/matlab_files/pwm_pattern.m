function [times, values] = pwm_pattern(duration, light_on_time, light_off_time)
    % PWM_PATTERN Generate a PWM pattern for a given duration
    %
    % Inputs:
    %   duration - Total duration of PWM pattern (seconds)
    %   light_on_time - Duration of light ON per cycle (seconds)
    %   light_off_time - Duration of light OFF per cycle (seconds)
    %
    % Outputs:
    %   times - Array of time durations
    %   values - Array of light values (0 or 1)
    
    cycle_period = light_on_time + light_off_time;
    
    if cycle_period >= duration
        % If cycle is longer than duration, just do constant light
        times = duration;
        values = 1;
    else
        % Calculate number of complete cycles
        num_cycles = floor(duration / cycle_period);
        
        % Generate complete cycles
        times = repmat([light_on_time, light_off_time], 1, num_cycles);
        values = repmat([1, 0], 1, num_cycles);
        
        % Add remaining time if any
        remaining_time = duration - (num_cycles * cycle_period);
        if remaining_time > 0
            times = [times, remaining_time];
            values = [values, 1]; % Start with light on
        end
    end
end