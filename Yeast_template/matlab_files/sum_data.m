function output_value = sum_data(dataframe,channel_index)
% this function read the dataframe and the channel index and output the
% total value of area. channel index: 1 is brightfield, 2 is cy3 ,3 is cy5

bright_subdata = dataframe((dataframe(:,5) == channel_index),:); % 1 is brightfield when the chennels is all
% Exclude the background index
bright_subdata_exclude_background = bright_subdata((bright_subdata(:,6) ~= 0),:); % The 6 index is not 0, which is the background
total_value = sum(bright_subdata_exclude_background(:,7));% the total values of selected channel;
output_value = total_value;
end