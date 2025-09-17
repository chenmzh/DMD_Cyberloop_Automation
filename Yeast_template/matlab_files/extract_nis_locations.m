function [xy] = extract_nis_locations(fileName)

    % GET XY LOCATIONS AND PFS_OFFSET
    data = xml2struct(fileName);
    
    % Filter out only Point locations
    names = fieldnames( data.variant.no_name );
    subStr = 'Point';
    filteredStruct = rmfield( data.variant.no_name, names( find( cellfun( @isempty, strfind( names , subStr)))));
    
    xy.numPositions = numel(fieldnames(filteredStruct));
    xy.coordinates = zeros(xy.numPositions,2);
    xy.pfsOffset = zeros(xy.numPositions,1);
%     xy.location = strings(xy.numPositions,1);
    dataCell = struct2cell(filteredStruct);
    for i=1:xy.numPositions
        xy.coordinates(i,:) = [str2num(dataCell{i}.dXPosition.Attributes.value), ...
                                str2num(dataCell{i}.dYPosition.Attributes.value)];
        xy.pfsOffset(i) = str2num(dataCell{i}.dPFSOffset.Attributes.value);
        xy.zPosition(i) = str2num(dataCell{i}.dZPosition.Attributes.value);
        xy.location{i} = dataCell{i}.strName.Attributes.value;
    end
    data = [];
    
end
