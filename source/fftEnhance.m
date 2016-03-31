function enhancedImage = fftEnhance(image, factor)
% This function enhances input image, i.e., amplifies white 
% ridges of finger prints to prevent fractions affecting
% recognition results. 
%
% Input
%   image: original image before enhancement
%   factor: the power to amplify white ridges
% Return
%   enhancedImage: enhanced image

    % Convert image to double variables, and block by 32 * 32 size.
    image = 255 - double(image);
    blockSize = 32;
    [numRow, numCol] = size(image);

    newRow = floor(numRow / blockSize) * blockSize;
    newCol = floor(numCol / blockSize) * blockSize;

    enhancedImage = zeros(newRow,newCol);

    % Start image enhancement block by block.
    for i = 1 : blockSize : newRow
        for j = 1 : blockSize : newCol
            
            % Determine block range.
            blockRowEnd = i + blockSize - 1;
            blockColEnd = j + blockSize - 1;
            
            % Perform FFT transform and enhance dominant coefficients.
            fftBlock = fft2(image(i : blockRowEnd, j : blockColEnd));
            fftFactor = abs(fftBlock) .^ factor;
            block = abs(ifft2(fftBlock .* fftFactor));

            maxVal = max(block(:));
            
            if maxVal == 0
                maxVal = 1;
            end

            % Normalize block values.
            block = block ./ maxVal;
            enhancedImage(i : blockRowEnd, j : blockColEnd) = block;
            
        end
    end

    % Convert double data back to unsigned 8-bit maps.
    enhancedImage = enhancedImage * 255;
    enhancedImage = histeq(uint8(enhancedImage));
    
end