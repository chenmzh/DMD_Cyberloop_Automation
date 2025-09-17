function saveAllFigures(figHandles, figNames)
% saveAllFigures - 保存多个图形到img文件夹
%
% 语法:
%   saveAllFigures(figHandles, figNames)
%
% 输入:
%   figHandles - 图形句柄的数组 [f1, f2, ...]
%   figNames   - 与图形句柄对应的文件名的字符串数组 ["name1", "name2", ...] 或 ['name1', 'name2', ...]
%
% 例子:
%   f1 = figure; plot(rand(10));
%   f2 = figure; bar(rand(5));
%   saveAllFigures([f1, f2], ["random_plot", "random_bar"]);
%

    % 确保figHandles和figNames长度一致
    if length(figHandles) ~= length(figNames)
        error('图形句柄数量与文件名数量不匹配');
    end
    
    % 检查img文件夹是否存在，如果不存在则创建
    if ~exist('img', 'dir')
        mkdir('img');
        disp('创建了新的img文件夹');
    else
        disp('img文件夹已存在');
    end
    
    % 遍历所有图形句柄并保存
    for i = 1:length(figHandles)
        fig = figHandles(i);
        name = figNames(i);
        
        % 使用figure句柄确保当前图形是活动的
        figure(fig);
        
        % 构建完整的文件路径
        filePath = fullfile('img', char(name));
        
        % 保存为PNG
        saveas(fig, [filePath '.png']);
        disp(['保存图片: ' filePath '.png']);
        
        % 保存为PDF
        print(fig, '-dpdf', filePath);
        disp(['保存PDF: ' filePath '.pdf']);
        
        % 保存为高分辨率PNG
        print(fig, '-dpng', '-r300', [filePath '_highres.png']);
        disp(['保存高分辨率PNG: ' filePath '_highres.png']);
        
        % 保存为MATLAB图形文件
        saveas(fig, [filePath '.fig']);
        disp(['保存MATLAB图形文件: ' filePath '.fig']);
    end
    
    disp('所有图形已成功保存到img文件夹');
end