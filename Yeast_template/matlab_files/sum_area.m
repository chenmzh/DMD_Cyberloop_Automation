function output_value = sum_area(dataframe)
% this function read the dataframe  and output the
% area ratio. channel index: 1 is brightfield, 2 is cy3 ,3 is cy5
channel_index = 1;
bright_subdata = dataframe((dataframe(:,5) == channel_index),:); % 1 is brightfield when the chennels is all
% Exclude the background index
bright_subdata_exclude_background = bright_subdata((bright_subdata(:,6) ~= 0),:); % The 6 index is not 0, which is the background
Area = sum(bright_subdata_exclude_background(:,8));% the area;
total_area = sum(bright_subdata(:,8));
Area_ratio = Area/total_area;
output_value = Area_ratio;
end