function [] = grid_imaging(xy_positions, index, config, imaging, microscope)

n = imaging.n_subimages;
field_diagonal = imaging.field_diagonal;

if n == 1
    step = 0;
else
    step = field_diagonal / (sqrt(2) * (n - 1));
end

x = xy_positions.coordinates(index, 1) - field_diagonal / (sqrt(2) * 2);
y = xy_positions.coordinates(index, 2) - field_diagonal / (sqrt(2) * 2);

disp(x)
disp(y)

for i_y = 0:(n - 1)
    for i_x = 0:(n - 1)
        x_im = round(x + i_x * step);
        y_im = round(y + i_y * step);
        
        microscope.getStageDevice().setPosition(x_im, y_im);
        pause(2);
        z = xy_positions.zPosition(index);
        microscope.getDevice('ZDrive').getProperty('Position').setValue(z);
        pause(0.5);
%         microscope.getDevice('PFS').getProperty('FocusMaintenance').setValue('On');
%         pause(1);
        
        pos_index = [num2str(index) '.' num2str(i_x + 1)  num2str(i_y + 1)];
        capture_images(config, imaging, xy_positions, pos_index, microscope);
    end
end
