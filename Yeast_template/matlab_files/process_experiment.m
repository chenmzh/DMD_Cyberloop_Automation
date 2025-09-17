function is_valid = process_experiment(previous_experiment)
    % 检查输入类型
    if ~(islogical(previous_experiment) || isstring(previous_experiment) || ischar(previous_experiment))
        error('输入类型错误：只接受 false、字符串或空字符串');
    end
    
    % 如果是逻辑类型，必须是 false
    if islogical(previous_experiment) && previous_experiment ~= false
        error('逻辑输入只接受 false');
    end
    
    % 检查条件：不是false且不是空字符串
    is_valid = ~isequal(previous_experiment, false);
    
    % 检查是否为空字符串
    if (isstring(previous_experiment) && isscalar(previous_experiment) && strlength(previous_experiment) == 0) || ...
       (ischar(previous_experiment) && isempty(previous_experiment))
        is_valid = false;
    end

    if is_valid
        disp(['正在处理实验: ', char(string(previous_experiment))]);
        % 这里是后续步骤
    else
        disp('没有有效的实验，跳过处理');
    end
end