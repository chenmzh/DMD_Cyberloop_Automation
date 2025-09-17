function [] = go_to_position(indx, xy, microscope)

    % change index to correct one here
    % for example"A01" to "A10" then "B01" to "B10"
    x = xy.coordinates(indx,1);
    y = xy.coordinates(indx,2);    
    z = xy.zPosition(indx);
    microscope.getStageDevice().setPosition(x,y);
    pause(1.5);
    microscope.getDevice('ZDrive').getProperty('Position').setValue(z);
    pause(0.5);
end