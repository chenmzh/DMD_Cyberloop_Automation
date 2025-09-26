function [] = go_to_position_PFS(indx, xy, microscope)


    x = xy.coordinates(indx,1);
    y = xy.coordinates(indx,2);    
    microscope.getStageDevice().setPosition(x,y);
    pause(0.5);
    
end