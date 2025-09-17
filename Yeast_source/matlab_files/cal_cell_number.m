function number = cal_cell_number(dataframe)


% this function read the dataframe  and output the number of cells
% channel index: 1 is brightfield, 2 is cy3 ,3 is cy5
channel_index = 1;
bright_subdata = dataframe((dataframe(:,5) == channel_index),:); % 1 is brightfield when the chennels is all
% Exclude the background index
bright_subdata_exclude_background = bright_subdata((bright_subdata(:,6) ~= 0),:); % The 6 index is not 0, which is the background

number = length(unique(bright_subdata_exclude_background(:,6)));% the area;
% total_area = sum(bright_subdata(:,8));
% Area_ratio = Area/total_area;
% output_value = Area_ratio;
end
