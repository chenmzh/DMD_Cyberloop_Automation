% path_new = "D:\MC\data\fluro_20230313_4x_new_strain_close_loop_third_trial_disturbance_rejection\microscope_images_20230317T132855\data";
% path_old = "D:\MC\data\fluro_20230313_4x_new_strain_close_loop_third_trial_disturbance_rejection\microscope_images_20230316T125841\data";
% E:\MC\data\cell_death_20240825_Cygentig_10x_faster_data_collection\microscope_images_20240826T180207\data
root_folder = "E:\MC\data";
experiment = "cell_death_20250509_Cygentig_6x_snapshot_96_well";
trial_list = ["microscope_images_20250509T150230"];
% root_folder = "Y:\khammash\MC\microscope\CyGenTiG";
% experiment = "cell_death_20250321_Cygentig_6x_closed_loop_high_gain";
% trial_list = ["microscope_images_20250324T115137"];

open_loop = true;
len_list = length(trial_list);
area = [];
Intensity = []; 
error = [];

setpoint_1 = 0.15;

if ~open_loop
    for i = 1:len_list
    path = fullfile(root_folder,experiment,trial_list(i),"data");
    error_tmp = load(fullfile(path,"acc_error_log.mat")).acc_error_log;
    area_tmp =load(fullfile(path,"area_log.mat")).area_log;
    Intensity_tmp = load(fullfile(path,"Intensity_log.mat")).Intensity_log;
    if i == 1   
        area = [area;area_tmp];
        Intensity = [Intensity;Intensity_tmp];
        error = [error; error_tmp];
    else
        area = [area;area_tmp(2:end,:)];
        Intensity = [Intensity;Intensity_tmp(2:end,:)];
        error = [error; error_tmp(2:end,:)];
    end
    end
    
else
    for i = 1:len_list
    path = fullfile(root_folder,experiment,trial_list(i),"data");
    area_tmp =load(fullfile(path,"area_log.mat")).area_log;
    if i == 1   
        area = [area;area_tmp];
        
    else
        area = [area;area_tmp(2:end,:)];
        
    end
    end
end


%% Heatmap 
reshaped_data = reshape(area, 12, 8)';

% Create a heatmap
f1 = figure;
heatmap(reshaped_data);
title('Heatmap of whole 96 well plate layout');
xlabel('Columns');
ylabel('Rows');

selected_area = reshaped_data([2:7],[3:11]);
f2 = figure;
heatmap(selected_area);
title('selected data excluding outer range and extra 0 light region');
xlabel('Columns');
ylabel('Rows');

% column_means = mean(selected_area, 1); % mean of each column
% x_values = [1500, 1280, 960, 640, 320, 160, 80, 40, 0] * 6.25/1000; % convert to mW/cm2
% 
% light_blue = [0.6, 0.8, 1.0]; % RGB值 - 更浅的蓝色
% light_blue_marker = [0.5, 0.7, 0.9]; % 稍微深一点的浅蓝色
% % 绘制均值曲线
% f3 = figure;
% plot(x_values, column_means, 'o-', 'LineWidth', 2, 'MarkerFaceColor', light_blue, 'Color', light_blue_marker);
% title('Area vs Light intensity after 20 hrs illumination with DiYA2');
% xlabel('Light intensity (mW/cm²)');
% ylabel('area');
% 
% % 添加数据标签
% for i = 1:length(x_values)
%     if x_values(i) > 0.25 % add label only if larger than 0.025
%         text(x_values(i), column_means(i), sprintf('%.3f', x_values(i)), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
%     end
% end
column_means = mean(selected_area, 1); % mean of each column
column_sd = std(selected_area, 0, 1); % standard deviation of each column

x_values = [1500, 1280, 960, 640, 320, 160, 80, 40, 0] * 6.25/1000; % convert to mW/cm2
light_blue = [0.6, 0.8, 1.0]; % RGB值 - 更浅的蓝色

light_green_edge = [0.5, 0.5, 0.5]; % grey

% 创建更大的图形
f3 = figure;
% 设置图形大小（单位：像素）
set(f3, 'Position', [100, 100, 1000, 800]); % 宽1000像素，高800像素

hold on;

% 先绘制误差线 - 使用浅绿色
e = errorbar(x_values, column_means, column_sd, 'LineStyle', 'none', 'Color', light_green_edge, 'LineWidth', 1.5);
% 设置误差线上下横线的宽度
e.CapSize = 15;

% 再绘制主曲线 - 保持蓝色
p = plot(x_values, column_means, 'o-', 'LineWidth', 2, 'MarkerFaceColor', light_blue, 'Color', light_blue, 'MarkerSize', 10);

% 设置图表标题和标签 - 增加字体大小但不加粗
title('Area vs Light intensity after 20 hrs illumination with DiYA2', 'FontSize', 16);
xlabel('Light intensity (mW/cm²)', 'FontSize', 14);
ylabel('Area', 'FontSize', 14);
grid on;
% 
% % 添加数据标签 - 使用常规字体而非粗体
% for i = 1:length(x_values)
%     if x_values(i) > 0.25 % add label only if larger than 0.025
%         text(x_values(i), column_means(i)+0.5*column_sd(i), sprintf('%.3f', x_values(i)), ...
%             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
%             'FontSize', 11);
%     end
% end

% 增加轴上数字的字体大小，但保持默认字体粗细
set(gca, 'FontSize', 12);

% 添加图例
legend({'Standard deviation', 'Mean area'}, 'Location', 'best', 'FontSize', 12);

% 优化轴范围，增加边距
current_ylim = ylim;
ylim([current_ylim(1)*0.95, current_ylim(2)*1.15]); % 顶部增加15%的空间

% 保持边框默认样式
box on;
% 不设置LineWidth，使用默认值

hold off;
%% Save figure
fig_list = [f1,f2,f3];
fig_name_list = ["whole_plate","selected_region","dose_response_curve"];
saveAllFigures(fig_list,fig_name_list);

%% Plot every 12 samples



mean_area = mean(area,2);
plot_time = ((1: length(mean_area))/6)';

figure
for i = 1:8
%     if i == 2
%         subplot(2,2,2)
%         plot(log(Intensity(2:end,(2:6)+6*(i-1))))
%         legend("Location","best")
%         title("Intensity")
%     else
        subplot(2,4,i)
        plot(plot_time,area(:,i))
        yline(setpoint_1, '--r'); % Dashed red line at y = 0.5 with label
        legend("Location","best")
        title("area")
        ylim([0,0.3])



end

set(gcf, 'Position', [100, 100, 1200, 900]); 
saveas(gcf,fullfile(path,'area.png'))


figure
for i = 1:8
        plot(plot_time, area)
        hold on
        title("area")
        ylim([0,0.3])


    % ylim([0,0.7])
end
yline(setpoint_1, '--r'); % Dashed red line at y = 0.5 with label
hold off
set(gcf, 'Position', [100, 100, 1200, 900]); 

saveas(gcf,fullfile(path,'area_overview.png'))



% Plot the mean and sd as error bar
color1 = [0.2, 0.7, 0.8]; % 浅蓝绿色用于误差阴影
color2 = [0.0, 0.4, 0.65]; % 深蓝色用于数据点
color3 = [0.9, 0.3, 0.3]; % 醒目的红色用于参考线
mean_area = mean(area,2);
std_area = std(area,0,2);
plot_time = ((1: length(mean_area))/6)';

figure
% shadow to present sd
h1 = fill([plot_time', fliplr(plot_time')], [mean_area' + std_area', fliplr(mean_area' - std_area')], color1 ,'FaceAlpha',0.3, 'EdgeColor', 'none');
hold on;
h2 = scatter(plot_time, mean_area, 20, color2, 'filled', 'MarkerFaceAlpha', 0.8);
plot(plot_time, mean_area, 'Color', color2, 'LineWidth', 1.2);
grid on;
title("Area Over Time", 'FontSize', 14, 'FontWeight', 'bold')
xlabel('Time (hours)', 'FontSize', 12);
ylabel('Area', 'FontSize', 12);
ylim([0, 0.3])

% 方法1：使用handle捕获yline返回值
h3 = yline(setpoint_1, '-', 'Color', color3, 'LineWidth', 1.5); 
legend([h1, h2, h3], 'SD Range', 'Mean', 'Set point', "Location", "best", 'FontSize', 10)

% % 方法2：手动创建参考线和图例
% plot([min(plot_time), max(plot_time)], [0.15, 0.15], '-', 'Color', color3, 'LineWidth', 1.5);
% legend('SD Range', 'Mean', 'Set point', "Location", "best", 'FontSize', 10)

set(gcf, 'Position', [100, 100, 1200, 900]);
set(gca, 'FontSize', 11);
saveas(gcf, fullfile(path, 'mean_error_area.png'))




if ~open_loop
figure
for i = 1:8
%     if i == 2
%         subplot(2,2,2)
%         plot(log(Intensity(2:end,(2:6)+6*(i-1))))
%         legend("Location","best")
%         title("Intensity")
%     else
        subplot(2,4,i)
        plot(plot_time,error(2:end,i))
        legend("Location","best")
        title("acc\_error")


end
set(gcf, 'Position', [100, 100, 1200, 900]); 
saveas(gcf,fullfile(path,'total_error.png'))



figure
for i = 1:8
%     if i == 2
%         subplot(2,2,2)
%         plot(log(Intensity(2:end,(2:6)+6*(i-1))))
%         legend("Location","best")
%         title("Intensity")
%     else
        subplot(2,4,i)
        plot(plot_time,Intensity(2:end,i))
        legend("Location","best")
        title("Intensity")

end
set(gcf, 'Position', [100, 100, 1200, 900]); 

saveas(gcf,fullfile(path,'intensity.png'))


end


%% 

figure
plot(Intensity(2:end,[1,7]))
legend("Location","best")

figure
plot(area(2:end,1:12))
legend("Location","best")


figure
for i = 1:4
%     if i == 2
%         subplot(2,2,2)
%         plot(log(Intensity(2:end,(2:6)+6*(i-1))))
%         legend("Location","best")
%         title("Intensity")
%     else
        subplot(2,2,i)
        plot(log(Intensity(2:end,(1:6)+6*(i-1))))
        legend("Location","best")
        title("Intensity_log")
%     end

    % ylim([0,0.7])
end

% Intensity = 800*Intensity; % Convert to glucose (mg/dl)

% Intensity = 80/0.15*Intensity; % Convert to glucose (mg/dl)
figure
for i = 1:4
%     if i == 2
%         subplot(2,2,2)
%         plot(Intensity(2:end,(2:6)+6*(i-1)))
%         legend("Location","best")
%         title("Intensity")
%     else
        subplot(2,2,i)
        plot(Intensity(2:end,(1:6)+6*(i-1)))
        legend("Location","best")
        title("Intensity")
%     end

    % ylim([0,0.7])
end

figure
for i = 1:4
%     if i == 2
%         subplot(2,2,2)
%         plot(fluro(2:end,(2:6)+6*(i-1)))
%         legend("Location","best")
%         title("fluro")
%     else
        subplot(2,2,i)
        plot(area(2:end,(1:6)+6*(i-1)))
        legend("Location","best")
        title("fluro")
%     end

end


%
% fluro_new =load(fullfile(path_new,"fluro_log.mat")).fluro_log;
% fluro_old =load(fullfile(path_old,"fluro_log.mat")).fluro_log;
% Intensity_new =load(fullfile(path_new,"Intensity_log.mat")).Intensity_log;
% Intensity_old =load(fullfile(path_old,"Intensity_log.mat")).Intensity_log;
% 
% fluro_all = [fluro_old;fluro_new];
% Intensity_all = [Intensity_old;Intensity_new(2:end,:)];
% 
% % fluro_all = [fluro_old;fluro_new];
% % Intensity_all = [Intensity_old;Intensity_new];
% Intensity_all_log = log(Intensity_all);
% 
% figure
% subplot(2,2,1)
% plot(Intensity_all_log(:,(1:6)))
% legend
% subplot(2,2,2)
% plot(Intensity_all_log(:,(1:6)+6))
% legend
% subplot(2,2,3)
% plot(Intensity_all_log(:,(1:6)+12))
% legend
% subplot(2,2,4)
% plot(Intensity_all_log(:,(1:6)+18))
% legend
% title("Log_Light")
% 
% 
% figure
% subplot(2,2,1)
% plot(Intensity_all(:,(1:6)))
% legend
% subplot(2,2,2)
% plot(Intensity_all(:,(1:6)+6))
% legend
% subplot(2,2,3)
% plot(Intensity_all(:,(1:6)+12))
% legend
% subplot(2,2,4)
% plot(Intensity_all(:,(1:6)+18))
% legend
% title("Light")
% 
% figure
% subplot(2,2,1)
% plot(fluro_all(:,(1:6)))
% legend
% subplot(2,2,2)
% plot(fluro_all(:,(1:6)+6))
% legend
% subplot(2,2,3)
% plot(fluro_all(:,(1:6)+12))
% legend
% subplot(2,2,4)
% plot(fluro_all(:,(1:6)+18))
% legend
% title("Fluroscence")
