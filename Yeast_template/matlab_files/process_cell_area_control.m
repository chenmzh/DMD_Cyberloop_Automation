function pattern_collection = process_cell_area_control(segmentation_folder, n_well, sample_num, config_file)
% Complete cell area control processing with PID control and DMD pattern generation
% Replaces the Python script functionality with MATLAB implementation
%
% Inputs:
%   segmentation_folder - folder containing segmentation images
%   n_well - number of wells
%   sample_num - current sample number
%   config_file - path to configuration JSON file
%
% Outputs:
%   pattern_collection - cell array containing DMD patterns for each well

    % Load configuration
    config = load_config_json(config_file);
    if isempty(config)
        error('Failed to load configuration file: %s', config_file);
    end
    


    % Extract configuration parameters
    output_dir = config.output.output_dir;
    left_setpoint = config.control.left_setpoint;
    right_setpoint = config.control.right_setpoint;
    baseline_light = config.control.baseline_light;
    light_normalization = config.control.light_normalization;
    normalize = config.processing.normalize;

    % Initiate Log file

    logfile = fullfile(output_dir,'matlab_progress.log');

    % Initialize pattern collection
    pattern_collection = cell(1, n_well);
    
    if usejava('desktop')
        fprintf('Processing cell area control for %d wells at sample %d\n', n_well, sample_num);
    end
    
    for i = 1:n_well

        % message = sprintf('%s - 第 %d 次迭代', datestr(now), i);
        % loglocally(logfile, message)

        % Construct segmentation image filename
        seg_filename = sprintf('%d_brightfield_z1_t%06d.tif', i, sample_num);
        seg_path = fullfile(segmentation_folder, seg_filename);
        
        fprintf('Debug: Processing well %d, looking for file: %s\n', i, seg_path);
        
        if exist(seg_path, 'file')
            fprintf('Debug: Segmentation file found for well %d\n', i);
            % Read mask and calculate cell densities
            [left_density, right_density, image_shape] = read_mask_and_calculate_densities(seg_path, normalize);
            
            if ~isempty(left_density) && ~isempty(right_density)
                fprintf('Debug: Densities calculated - L=%.4f, R=%.4f\n', left_density, right_density);
                if sample_num == 1
                    start_experiment = true;
                    % Initialize PID controllers for this well
                else
                    start_experiment = false;
                end
                left_pid = init_pid_controller(config.control.left_pid, left_setpoint, config.control.output_limits,start_experiment);
                right_pid = init_pid_controller(config.control.right_pid, right_setpoint, config.control.output_limits,start_experiment);
                % Load previous PID states if available
                if ~start_experiment
                    [left_pid, right_pid] = load_pid_states(left_pid, right_pid, i, output_dir, sample_num);
                end
                % Calculate light values using PID control
                [left_light, left_pid] = update_pid_controller(left_pid, left_density, baseline_light);
                [right_light, right_pid] = update_pid_controller(right_pid, right_density, baseline_light);
                
                % Suppress output in headless mode
                if usejava('desktop')
                    fprintf('Well %d: L_density=%.4f, R_density=%.4f, L_light=%.2f, R_light=%.2f\n', ...
                            i, left_density, right_density, left_light, right_light);
                end
                
                % Create light control image
                light_image = create_light_control_image(left_light, right_light, image_shape, light_normalization);
                
                % Save light control image
                output_name = sprintf('%d_brightfield_z1_t%06d.tif', i, sample_num);
                output_path = fullfile(output_dir, output_name);
                save_light_image(light_image, output_path);
                
                % Save PID states with updated prev_error for next iteration
                save_pid_states(left_pid, right_pid, i, sample_num, output_dir, left_density, right_density, left_light, right_light);
                

                % Generate DMD projection pattern
                fprintf('Debug: About to generate DMD projection for well %d\n', i);

                dmd_pattern = projector_image_transform(light_image);
                pattern_collection{i} = dmd_pattern;
                
                % Save DMD projection pattern
                dmd_output_dir = fullfile(output_dir, 'dmd_projection');
                if ~exist(dmd_output_dir, 'dir')
                    mkdir(dmd_output_dir);
                end
                dmd_filename = sprintf('%d_dmd_projection_t%06d.png', i, sample_num);
                dmd_output_path = fullfile(dmd_output_dir, dmd_filename);
                imwrite(uint8(dmd_pattern), dmd_output_path);
                
                fprintf('✅ DMD projection saved: %s\n', dmd_filename);

                
            else
                fprintf('Warning: Failed to process densities for well %d\n', i);
                pattern_collection{i} = zeros(1080, 1920, 'int64');
            end
        else
            fprintf('Warning: Segmentation image not found for well %d: %s\n', i, seg_path);
            pattern_collection{i} = zeros(1080, 1920, 'int64');
        end
            
    end
    
    if usejava('desktop')
        fprintf('Completed cell area control processing for %d wells\n', n_well);
    end

end



function config = load_config_json(config_file)
    fid = fopen(config_file, 'r');
    if fid == -1
        config = [];
        return;
    end
    raw_text = fread(fid, inf, 'char=>char')';
    fclose(fid);
    config = jsondecode(raw_text);
end

function [left_density, right_density, image_shape] = read_mask_and_calculate_densities(mask_path, normalize)
% Read mask image and calculate cell densities for left and right halves
    mask = imread(mask_path);
    if isempty(mask)
        left_density = [];
        right_density = [];
        image_shape = [];
        return;
    end
    
    % Convert to grayscale if needed
    if size(mask, 3) == 3
        mask = rgb2gray(mask);
    end
    
    [height, width] = size(mask);
    image_shape = [height, width];
    
    % Split into left and right halves
    left_half = mask(:, 1:floor(width/2));
    right_half = mask(:, floor(width/2)+1:end);
    
    % Calculate non-zero pixels (cell areas)
    left_area = sum(left_half(:) > 0);
    right_area = sum(right_half(:) > 0);
    
    if normalize
        % Calculate total pixels in each half
        left_total_pixels = numel(left_half);
        right_total_pixels = numel(right_half);
        
        % Normalize by total pixels (cell density)
        left_density = left_area / left_total_pixels;
        right_density = right_area / right_total_pixels;
    else
        left_density = left_area;
        right_density = right_area;
    end
        
end

function pid = init_pid_controller(pid_params, setpoint, output_limits,start_experiment)
% Initialize PID controller structure
    pid.kp = pid_params.kp;
    pid.ki = pid_params.ki;
    pid.kd = pid_params.kd;
    pid.setpoint = setpoint;
    pid.output_limits = output_limits;
    if start_experiment
        pid.prev_error = 0;
        pid.error = 0;
        pid.integral = 0;
    end
end

function [output, pid] = update_pid_controller(pid, current_value, baseline_light, dt)
% Update PID controller and return output
    if nargin < 4
        dt = 1.0;
    end
    pid.prev_error = pid.error;

    pid.error = current_value - pid.setpoint; % Negative if current value larger than setpoints
    
    pid.integral = pid.integral + pid.error * dt;
    derivative = (pid.error - pid.prev_error) / dt;
    integral_maximum = pid.output_limits(2)*2/3/pid.ki; % Set th limit for integral term.

    if pid.integral > integral_maximum
        pid.integral = integral_maximum;
    end  

    if pid.integral < 0
        pid.integral = 0;
    end

    % For light inhibition:
    % - Current density > setpoint (positive error) → need more light to inhibit growth
    % - Current density < setpoint (negative error) → need less light to prompt growth
    pid_output = pid.kp * pid.error + pid.ki * pid.integral + pid.kd * derivative;
    
    % Subtract  baseline: positive error increase light, negative error decrease light
    output =  pid_output - baseline_light;
    
    % Apply output limits
    output = max(pid.output_limits(1), min(pid.output_limits(2), output));

end

function light_image = create_light_control_image(left_light, right_light, image_shape, light_normalization)
% Create light control image from controller outputs
    height = image_shape(1);
    width = image_shape(2);
    light_image = zeros(height, width, 'uint8');
    
    % Normalize light values: convert from mW/cm^2 to 0-255 range
    left_normalized = round((left_light / light_normalization) * 255);
    right_normalized = round((right_light / light_normalization) * 255);
    
    % Clamp to valid range
    left_normalized = max(0, min(255, left_normalized));
    right_normalized = max(0, min(255, right_normalized));
    
    % Apply normalized values to respective halves
    light_image(:, 1:floor(width/2)) = left_normalized;
    light_image(:, floor(width/2)+1:end) = right_normalized;
end

function save_light_image(light_image, output_path)
% Save light control image
    try
        output_dir = fileparts(output_path);
        if ~exist(output_dir, 'dir')
            mkdir(output_dir);
        end
        imwrite(light_image, output_path);
    catch ME
        fprintf('Error saving light image: %s\n', ME.message);
    end
end

function [left_pid, right_pid] = load_pid_states(left_pid, right_pid, sequence, output_dir, sample_num)
    state_dir = fullfile(output_dir, 'pid_states');
    history_file = fullfile(state_dir, sprintf('pid_history_%d.json', sequence));

    if exist(history_file, 'file')
        fid = fopen(history_file, 'r');
        raw_text = fread(fid, inf, 'char=>char')';
        fclose(fid);
        history_data = jsondecode(raw_text);
        
        if ~isempty(history_data)
            % Get the latest record
            latest_record = history_data(end);
            
            % Load left PID state
            if isfield(latest_record, 'left_state')
                left_pid.prev_error = latest_record.left_state.prev_error;
                left_pid.error = latest_record.left_state.error;
                left_pid.integral = latest_record.left_state.integral;
            end
            
            % Load right PID state
            if isfield(latest_record, 'right_state')
                right_pid.prev_error = latest_record.right_state.prev_error;
                right_pid.error = latest_record.right_state.error; 
                right_pid.integral = latest_record.right_state.integral;
            end
            
            if usejava('desktop')
                fprintf('Loaded PID states for well %d\n', sequence);
            end
        end
    end
end

function save_pid_states(left_pid, right_pid, sequence, frame, output_dir, left_value, right_value, left_light, right_light)
        state_dir = fullfile(output_dir, 'pid_states');
        if ~exist(state_dir, 'dir')
            mkdir(state_dir);
        end
        
        % Create history record
        history_record.sequence = sequence;
        history_record.frame = frame;
        history_record.timestamp = now;
        history_record.left_state.current_value = left_value;
        history_record.left_state.setpoint = left_pid.setpoint;
        history_record.left_state.error = left_pid.error;
        history_record.left_state.prev_error = left_pid.prev_error;
        history_record.left_state.integral = left_pid.integral;
        history_record.left_state.light_output = left_light;
        history_record.left_state.kp = left_pid.kp;
        history_record.left_state.ki = left_pid.ki;
        history_record.left_state.kd = left_pid.kd;
        
        history_record.right_state.current_value = right_value;
        history_record.right_state.setpoint = right_pid.setpoint;
        history_record.right_state.error = right_pid.error;
        history_record.right_state.prev_error = right_pid.prev_error;
        history_record.right_state.integral = right_pid.integral;
        history_record.right_state.light_output = right_light;
        history_record.right_state.kp = right_pid.kp;
        history_record.right_state.ki = right_pid.ki;
        history_record.right_state.kd = right_pid.kd;
        
        % Save to sequence-specific history file
        history_file = fullfile(state_dir, sprintf('pid_history_%d.json', sequence));
        
        % Load existing history if it exists
        history_data = [];
        if exist(history_file, 'file')
            try
                fid = fopen(history_file, 'r');
                raw_text = fread(fid, inf, 'char=>char')';
                fclose(fid);
                history_data = jsondecode(raw_text);
            catch
                history_data = [];
            end
        end
        
        % Convert to cell array if needed for appending
        if isempty(history_data)
            history_data = {history_record};
        else
            % if ~iscell(history_data)
            %     history_data = {history_data};
            % end
            % history_data{end+1} = history_record;
                 % Always work with struct arrays, not cell arrays
            if iscell(history_data)
                % Convert cell array back to struct array
                temp_data = [];
                for j = 1:length(history_data)
                    if j == 1
                        temp_data = history_data{j};
                    else
                        temp_data(end+1) = history_data{j};
                    end
                end
                history_data = temp_data;
            end
            % Append new record to struct array
            history_data(end+1) = history_record;
        end
        
        % Save updated history with proper formatting
        try
            json_text = jsonencode(history_data, 'PrettyPrint', true);
        catch
            json_text = jsonencode(history_data, 'ConvertInfAndNaN', false);
            % Format manually for readability
            json_text = format_json_string(json_text);
        end
        fid = fopen(history_file, 'w');
        fwrite(fid, json_text, 'char');
        fclose(fid);

end

function formatted_json = format_json_string(json_str)
    % Simple JSON formatting function for better readability
    formatted_json = json_str;
    
    % Add actual newlines and indentation (not literal \n)
    newline_char = char(10); % Actual newline character
    
    formatted_json = strrep(formatted_json, '{', ['{' newline_char '  ']);
    formatted_json = strrep(formatted_json, '}', [newline_char '}']);
    formatted_json = strrep(formatted_json, ',', [',' newline_char '  ']);
    formatted_json = strrep(formatted_json, ':[', [':' newline_char '    [']);
    formatted_json = strrep(formatted_json, ']', [newline_char '  ]']);
    
    % Fix over-indentation issues
    formatted_json = strrep(formatted_json, [newline_char '  ' newline_char '}'], [newline_char '}']);
    formatted_json = strrep(formatted_json, [newline_char '  ]'], [newline_char ']']);
end

function loglocally(logfile,message)
        logfid = fopen(logfile, 'a');  % 'a' 表示追加模式
        fprintf(logfid, message);
        fclose(logfid);
end

