function ic = fetch_previous_state(file_name)
% Get the last time point value out
% ic is 24 by 10 matrix for 24 samples and 10 internal variables here
% for test
% file_name = "D:\MC\data\fluro_20230503_4x_patient_in_the_loop\microscope_images_20230503T150843\dynamic_picture\t000218output_data";
load(file_name)
num = length(matrices);
elements = size(matrices{2,1},2);
ic = zeros(num, elements);
for i = 1:size(matrices,2)
    temp = matrices{2,i};
%     i
    if isempty(temp)
        ic(i,:) = zeros(1,elements);
    else
        ic(i,:) = temp(end,:);
    end
end

% display(i)


