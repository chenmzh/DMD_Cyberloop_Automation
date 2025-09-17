function [xy] = light_intensity_on_one_location(sample_numbers, fixed_position, poffset)
% Input light intensity
% Poffset is 7574 for the experiment
% Output a structure with a fixed positino and light intensity
length_light_intensity = sample_numbers;

xy.numPositions = length_light_intensity;
xy.coordinates = zeros(xy.numPositions,2);
xy.pfsOffset = zeros(xy.numPositions,1);

for i=1:xy.numPositions
    xy.coordinates(i,:) = fixed_position;
    xy.pfsOffset(i) = poffset;
end


end