function modify_config(json_file, parameter_path, new_value)
    % 修改JSON配置文件中的特定参数
    % 
    % 使用示例:
    % modify_config('config.json', 'control.left_pid.kp', 10)
    % modify_config('config.json', 'control.baseline_light', 50)
    % modify_config('config.json', 'projection.debug_mode', true)
    
    try
        % 读取JSON文件
        fid = fopen(json_file, 'r');
        if fid == -1
            error('Cannot open file: %s', json_file);
        end
        raw_text = fread(fid, inf, 'char=>char')';
        fclose(fid);
        
        % 解析JSON
        config = jsondecode(raw_text);
        
        % 分解参数路径
        path_parts = strsplit(parameter_path, '.');
        
        % 递归设置值
        config = set_nested_value(config, path_parts, new_value);
        
        % 写回JSON文件（格式化输出）
        if exist('jsonencode', 'builtin')
            % For newer MATLAB versions, try PrettyPrint if available
            try
                json_text = jsonencode(config, 'PrettyPrint', true);
            catch
                % Fallback for older MATLAB
                json_text = jsonencode(config, 'ConvertInfAndNaN', false);
                % Format manually for readability
                json_text = format_json_string(json_text);
            end
        else
            error('jsonencode function not available');
        end
        fid = fopen(json_file, 'w');
        if fid == -1
            error('Cannot write to file: %s', json_file);
        end
        fwrite(fid, json_text, 'char');
        fclose(fid);
        
        fprintf('✅ Successfully updated %s = %s in %s\n', parameter_path, mat2str(new_value), json_file);
        
    catch ME
        fprintf('❌ Error: %s\n', ME.message);
        rethrow(ME);
    end
end

function struct_out = set_nested_value(struct_in, path_parts, value)
    % 递归设置嵌套结构体字段的值
    struct_out = struct_in;
    
    if length(path_parts) == 1
        % 基本情况：直接设置值
        field_name = path_parts{1};
        struct_out.(field_name) = value;
    else
        % 递归情况：继续深入到下一层
        field_name = path_parts{1};
        remaining_path = path_parts(2:end);
        
        % 确保字段存在
        if ~isfield(struct_out, field_name)
            struct_out.(field_name) = struct();
        end
        
        % 递归调用
        struct_out.(field_name) = set_nested_value(struct_out.(field_name), remaining_path, value);
    end
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