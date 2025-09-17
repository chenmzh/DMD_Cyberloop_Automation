function [best_nd, best_cyan, actual_intensity] = fn_light_to_cyan(target_intensity)
    % Define the data
    
    cyan_levels = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

    intensities = [
        [0.621, 1.087, 1.990, 2.840, 3.680, 4.460, 5.240, 5.960, 6.670, 7.340, 8.000]*6.25; % Unit: mW. for 4mm x 4mm square. convert to mw/cm2 need to mupltiply 6.25
        [0.068, 0.120, 0.220, 0.313, 0.407, 0.493, 0.579, 0.659, 0.738, 0.811, 0.888]*6.25;
        [0.018, 0.031, 0.058, 0.082, 0.107, 0.130, 0.152, 0.174, 0.195, 0.214, 0.233]*6.25;
    ];

    % Check if target intensity is below minimum
    if target_intensity < min(intensities(3,:))
        best_nd = 2;
        best_cyan = 0;  % Minimum cyan level
        actual_intensity = 0;
        return;
    end

    % Determine the appropriate ND filter
    if target_intensity > max(intensities(2,:))
        best_nd = 0;
    elseif target_intensity > max(intensities(3,:))
        best_nd = 1;
    else
        best_nd = 2;
    end

    % Create a function handle for interpolation
    cyan_to_light = @(x) interp1(cyan_levels, intensities(best_nd + 1, :), x, 'pchip');
    light_to_cyan = @(x) round(interp1(intensities(best_nd + 1, :), cyan_levels, x, 'pchip'));

    % Find the right cyan level
    cyan_level = light_to_cyan(target_intensity);
    best_cyan = round(cyan_level);
    if best_cyan > max(intensities(1,:))
        best_cyan = 100; % the upper limit is 8mW
    end
    % Calculate the actual intensity
    actual_intensity = cyan_to_light(best_cyan);
end

