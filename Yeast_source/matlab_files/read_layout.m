

function [Output,Size] = read_layout(layout_folder)
configFile = fullfile(layout_folder,"layout.xlsx");


%% Check sheet elements

Sheet_name_list= {'Period','Intensity','Illumination_time','Pattern_name'};
Data_type = {'numeric','numeric','numeric','string'};
Sheet_number = numel(Sheet_name_list);
Data = cell(Sheet_number,1);

for i = 1:Sheet_number
    if strcmp(Data_type{i},'numeric')
        Data{i} = readmatrix(configFile, 'Sheet',Sheet_name_list{i});

    %     if anynan(Data{i}) % from MATLAB 2022a
    %     if sum(isnan(Data{i}),'all')
    %         error("NaN in sheet %s",Sheet_name_list{i})
    %     end
        Data{i}(isnan(Data{i})) = 0;
    elseif strcmp(Data_type{i},'string')
        Data{i} = readcell(configFile, 'Sheet',Sheet_name_list{i});
        for row = 1:size(Data{i}, 1)
            for col = 1:size(Data{i}, 2)
                if isnumeric(Data{i}{row, col})
                   Data{i}{row, col} = string(Data{i}{row, col});
                end
            end
        end
    end
end

% Check sheet size
for i = 1:Sheet_number
    for j = i+1:Sheet_number
        if isequal(size(Data{i}),size(Data{j}))
        else
            error("Dimension of sheet %s and sheet %s not match",Sheet_name_list{i},Sheet_name_list{j})
        end
    end
end

%% Process to variables

Size = size(Data{1});

Output = cell(Sheet_number,1);
% reshape
for i = 1 :Sheet_number
    Output{i} = reshape(Data{i}',[1,Size(1)*Size(2)]); % reshape rowsize, 
    % for example from [1,2,3;4,5,6] to [1,2,3,4,5,6]
end


end
