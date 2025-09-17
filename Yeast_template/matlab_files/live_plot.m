% live_plot('D:\Timothy\20220620_DYN\microscope_images_20220622T164600\result.csv')

function [] = live_plot(results_location)

position_index = 1;
time_index = 4;
channel_index = 5;

value_index = 6;
area_index = 7;

data = readmatrix(results_location);

positions = unique(data(:, position_index));
time = unique(data(:, time_index));
channels = unique(data(:, channel_index));

tiledlayout(max(channels), 1);

for c = 1:length(channels)
    
    c_ind = data(:, channel_index) == channels(c);
    sub1_data = data(c_ind, :);
            
    nexttile;
    for p = 1:length(positions)
        
        p_ind = sub1_data(:, position_index) == positions(p);
        sub2_data = sub1_data(p_ind, :);
        
%       mean(sub2_data(:, 5) ./ sub2_data(:, 6));
%       cells = unique(sub2_data(:, 4));
        
        m_data = zeros(length(time), 1);
        
        for t = 1:length(time)
            t_ind = sub2_data(:, time_index) == time(t);
            
            sub3_data = sub2_data(t_ind, :);
            
            m_data(t) = mean(sub3_data(:, value_index) ./ sub3_data(:, area_index));
        end
        
        plot(time, m_data,'-o');
        hold on;
    end
end