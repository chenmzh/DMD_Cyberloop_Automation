function summary = create_summary(exp_info)
    file_path = exp_info.file_path;
    runtime = exp_info.runtime;
    config_exp = exp_config();
    end_time_stamp = exp_info.end_time_stamp;

    fid = fopen(file_path, 'a');
    
    % Write header
    fprintf(fid, '\n========================================\n');
    fprintf(fid, '        EXPERIMENT SUMMARY REPORT       \n');
    fprintf(fid, '========================================\n\n');
    
    % Basic Information
    fprintf(fid, '--- BASIC INFORMATION ---\n');
    fprintf(fid, 'Experiment Name: %s\n', config_exp.experiment_name);
    fprintf(fid, 'Date: %s\n', config_exp.time_date);
    fprintf(fid, 'Start Time: %s\n', config_exp.time_hour);
    fprintf(fid, 'End Time: %s\n', end_time_stamp);
    fprintf(fid, 'Total Runtime: %.2f minutes (%.2f hours)\n', runtime/60, runtime/3600);
    fprintf(fid, 'Organism: %s\n', config_exp.organism);
    fprintf(fid, 'Strains: %s\n', config_exp.strains);
    fprintf(fid, '\n');
    
    % Microscopy Setup
    fprintf(fid, '--- MICROSCOPY SETUP ---\n');
    fprintf(fid, 'Objective: %s\n', config_exp.objective_type);
    fprintf(fid, 'Magnification: %s\n', config_exp.magnification);
    fprintf(fid, '\n');
    
    % Timing Configuration
    fprintf(fid, '--- TIMING CONFIGURATION ---\n');
    fprintf(fid, 'Initial Delay: %d seconds (%.1f minutes)\n', config_exp.initial_delay, config_exp.initial_delay/60);
    fprintf(fid, 'Period: %d seconds\n', config_exp.Period);
    fprintf(fid, 'Pattern Times (sec): [%s]\n', num2str(config_exp.experiment_pattern_times));
    fprintf(fid, 'Pattern Values: [%s]\n', num2str(config_exp.experiment_pattern_values));
    total_pattern_duration = sum(config_exp.experiment_pattern_times);
    fprintf(fid, 'Total Pattern Duration: %d seconds\n', total_pattern_duration);
    fprintf(fid, '\n');
    
    % Light Parameters
    fprintf(fid, '--- LIGHT PARAMETERS ---\n');
    fprintf(fid, 'Intensity: %.1f\n', config_exp.intensity);
    fprintf(fid, 'Light Normalization: %.1f\n', config_exp.light_normalization);
    fprintf(fid, '\n');
    
    % Imaging Configuration
    fprintf(fid, '--- IMAGING CONFIGURATION ---\n');
    fprintf(fid, 'Number of Channels: %d\n', length(config_exp.imaging.types));
    for i = 1:length(config_exp.imaging.types)
        fprintf(fid, '\nChannel %d: %s\n', i, config_exp.imaging.types{i});
        fprintf(fid, '  - Group: %s\n', config_exp.imaging.groups{i});
        fprintf(fid, '  - Exposure: %d ms\n', config_exp.imaging.exposure{i});
        fprintf(fid, '  - Z-Offsets: [%s] µm\n', num2str(config_exp.imaging.zOffsets{i}));
        fprintf(fid, '  - Condenser: %d\n', config_exp.imaging.condenser{i});
    end
    
    if ~isempty(config_exp.imaging.message)
        fprintf(fid, 'Imaging Notes: %s\n', config_exp.imaging.message);
    end
    fprintf(fid, '\n');
    
    % Statistics
    fprintf(fid, '--- EXPERIMENT STATISTICS ---\n');
    num_cycles = floor(runtime / config_exp.Period);
    fprintf(fid, 'Estimated Number of Cycles: %d\n', num_cycles);
    fprintf(fid, 'Estimated Images per Channel: %d\n', num_cycles);
    total_images = num_cycles * length(config_exp.imaging.types);
    z_stack_total = 0;
    for i = 1:length(config_exp.imaging.zOffsets)
        z_stack_total = z_stack_total + length(config_exp.imaging.zOffsets{i});
    end
    total_images = total_images * z_stack_total / length(config_exp.imaging.types);
    fprintf(fid, 'Total Images Captured: ~%d\n', total_images);
    fprintf(fid, '\n');
    
    % Footer
    fprintf(fid, '--- END OF SUMMARY ---\n');
    fprintf(fid, 'Summary Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, '========================================\n\n');
    
    fclose(fid);
    
    % Create summary structure for return
    summary = struct();
    summary.experiment_name = config_exp.experiment_name;
    summary.date = config_exp.time_date;
    summary.runtime_minutes = runtime/60;
    summary.organism = config_exp.organism;
    summary.num_channels = length(config_exp.imaging.types);
    summary.estimated_cycles = num_cycles;
    summary.total_images = total_images;
    summary.file_path = file_path;
    summary.success = true;
end