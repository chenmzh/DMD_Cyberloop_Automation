function newImage = resizePatch(patch, targetSize, offset) %offset is in (x,y), integers
% Function description: this function places a small patch image onto a larger image of
% targetSize at the position specified by offset. The newImage has a
% black background.

    x0 = offset(1);
    y0 = offset(2);
    patchHeight = size(patch,1);
    patchWidth = size(patch,2);
    targetWidth = targetSize(1);
    targetHeight = targetSize(2);
    
    % Error checking
    % check if patch size is smaller than targetSize
    if patchHeight*patchWidth > targetHeight*targetWidth
        error('Error. \nTarget size is smaller than input patch. Image patch cannot be resized!')
    end
    
    % check if patch will fall outside targetSize area
    if (x0>=targetWidth) || (y0>=targetHeight) || ((patchWidth+x0)<=0) || ((patchHeight+y0)<=0)
        error('Error. \nImage patch will fall outside target area with offset!')
    end
    
    % crop out patch region that falls out of targetSize
    patchXmin = abs(min(0, x0))+1;
    patchXmax = min(targetWidth-x0, patchWidth);
    croppedWidth = patchXmax - patchXmin + 1;
    patchYmin = abs(min(0, y0))+1;
    patchYmax = min(targetHeight-y0, patchHeight);
    croppedHeight = patchYmax - patchYmin + 1;
    
    croppedPatch = imcrop(patch, [patchXmin patchYmin croppedWidth croppedHeight]);

    % find out area in target to replace with croppedPatch
    x0Target = max(x0+1, 1);
    y0Target = max(y0+1, 1);
    
    if length(size(patch)) > 2
        newImage = zeros(targetHeight, targetWidth, 3);
        newImage(y0Target:(y0Target+croppedHeight), x0Target:(x0Target+croppedWidth-1), :) = croppedPatch;
    else
        newImage = zeros(targetHeight, targetWidth);
        newImage(y0Target:(y0Target+croppedHeight-1), x0Target:(x0Target+croppedWidth-1)) = croppedPatch;
    end
    
    %figure(1)
    %imshow(newImage)
end