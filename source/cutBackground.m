function shrinked = cutBackground(image)
% This function calculates a rectangle boundary of input fingerprint area.
%
% Input
%   image: original input image
% Return
%   shrinked: output fingerprint with minimal background possible. 

    original = image;
    image = histeq(image);
    % Binarization of image, then get its boundary.
    level = graythresh(image);
    image = ~im2bw(image, level);
    image = bwconvhull(image);
    
    boundary = bwboundaries(image);
    [x, y] = minBoundParagram(boundary{1}(:, 1), boundary{1}(:, 2));
    % Get the minimal rectangle vertices. 
    minX = max(1, floor(min(x)));
    maxX = min(size(image, 1), floor(max(x)));
    minY = max(1, floor(min(y)));
    maxY = min(size(image, 2), floor(max(y)));
    
    % Cut image.
    shrinked = original(minX : maxX, minY : maxY);

end

