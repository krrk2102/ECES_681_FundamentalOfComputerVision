function [bwImage] = toBwFingerPrints(image, blockSize)
% This image converts input gray scale finger print image to
% black-white image. It automatically determines an appropriate
% gray scale threshold by blocks to provide clearest output. 
%
% Input
%   image: input grayscale image for convertion
%   blockSize: image conversion performed block by block, whose
%              sizes are assigned by this input
% Return
%   bwImage: the black-white finger print image converted
%            fromt input gray scale image

    % Determine converted image size.
    [numRow, numCol] = size(image);
    newRow = floor(numRow / blockSize) * blockSize;
    newCol = floor(numCol / blockSize) * blockSize;
    
    bwImage = zeros(newRow, newCol);

    % Start image conversion by pre-set block size.
    for i = 1 : blockSize : newRow
        for j = 1 : blockSize : newCol
            
            % Determine block range.
            blockRowEnd = i + blockSize - 1;
            blockColEnd = j + blockSize - 1;
            
            % Pre-set starting value of gray scale threshold to block mean
            % value. 
            avgThreshold = mean2(image(i : blockRowEnd, j : blockColEnd));
            % Lower threshold by 20 percent.
            avgThreshold = 0.8 * avgThreshold;
            
            % Ridges will be black, while original ridges are white. So
            % greater values in original image will be set to 0, or black. 
            bwImage(i : blockRowEnd, j : blockColEnd) = ...
                    image(i : blockRowEnd,j : blockColEnd) < avgThreshold;

        end
    end

end