function [RoiImage, RoiBound, RoiArea] = getROI(image, inBound, inArea)
% This functio removes background from input image, return a subset image
% which only contains figureprint content. 
%
% Input
%   image: input image with ROI and background
%   inBound: input image with bound information
%   inArea: input image ROI area information
% Return
%   RoiImage: new image without background
%   RoiBound: new boundary only for ROI
%   RoiArea: new area information only for ROI

    % Initialize variables.
    [numRow, numCol] = size(image);
    imageMask = zeros(numRow, numCol);

    % Get boundaries of image processing area.
    horizontalDir = sum(inBound);
    RoiCol = find(horizontalDir > 0);
    left = min(RoiCol);
    right = max(RoiCol);
    verticalDir = sum(inBound');
    RoiRow = find(verticalDir > 0);
    upper = min(RoiRow);
    bottom = max(RoiRow);

    % Calculate image mask to remove pixels out of region of interest.
    for i = upper : bottom
        for j = left : right
            
            % Mark mask corresponding to content area as 1. 
            if inBound(i, j) == 1
                imageMask(16 * i - 15 : 16 * i, 16 * j - 15 : 16 * j) = 1;
            elseif inArea(i, j) == 1 && inBound(i, j) ~= 1
                imageMask(16 * i - 15 : 16 * i, 16 * j - 15 : 16 * j) = 1;
            end
            
        end 
    end

    % Calculate the image only contains ROI content.
    image = image .* imageMask;
    RoiImage = image(16 * upper - 15 : 16 * bottom,...
                        16 * left - 15 : 16 * right);

    RoiBound = inBound(upper : bottom, left : right);
    RoiArea = inArea(upper : bottom, left : right);

    % Calculate inner ROI area.
    RoiArea = im2double(RoiArea) - im2double(RoiBound);

end
