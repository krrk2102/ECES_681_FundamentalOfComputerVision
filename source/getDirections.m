function [bound, area] = getDirections(image, blockSize)
% This function cacluates the local flow direction within each local block
% of size blockSize * blockSize
%
% Input
%   image: input image for local direction detection.
%   blockSize: size for local detection of blocks.
% Return
%   bound: region of interest bound
%   area: region of interest area


    % Process initialization.
    [numRow, numCol] = size(image);
    blockIndex = zeros(ceil(numRow/blockSize), ceil(numCol/blockSize));
    numRow = floor(numRow / blockSize) * blockSize;
    numCol = floor(numCol / blockSize) * blockSize;
    image = image(1 : numRow, 1 : numCol);

    % Get gradients in 2 directions.
    gradFilter = fspecial('sobel');
    % Gradient towards x axis, or vertical direction.
    verticalGradent = filter2(gradFilter, image);
    % Gradient towards y axis, or horizontal direction.
    gradFilter = gradFilter';
    horizontalGradient = filter2(gradFilter, image);

    % Pre-process for whole image gradients.
    gradientProduct = verticalGradent .* horizontalGradient;
    gradientSquareDiff = (horizontalGradient - verticalGradent) .*...
                            (horizontalGradient + verticalGradent);
    backgroungGradient = (verticalGradent .* verticalGradent) +...
                            (horizontalGradient .* horizontalGradient);

    % Calculate local dominant directio of block.
    for i = 1 : blockSize : numRow
        for j = 1 : blockSize : numCol
            
            % Determine block range.
            blockRowEnd = i + blockSize - 1;
            blockColEnd = j + blockSize - 1;
            
            productSum = sum(sum(gradientProduct(i : blockRowEnd,...
                                                    j : blockColEnd)));
            squareDiffSum = sum(sum(gradientSquareDiff(i : blockRowEnd,...
                                                    j : blockColEnd)));
            bgGradientSum = sum(sum(backgroungGradient(i : blockRowEnd,...
                                                    j : blockColEnd)));

            if bgGradientSum ~= 0 && productSum ~=0
                
                % Process gradient calculation only when block contains
                % useful fingerprint information other than noise.
                gradientLevel = (productSum * productSum + ...
                                    squareDiffSum * squareDiffSum) / ...
                                        (blockSize * blockSize *...
                                            bgGradientSum);

                if gradientLevel > 0.05 
                    
                    % Mark block as non trivial.
                    blockIndex(ceil(i / blockSize), ...
                                        ceil(j / blockSize)) = 1;

                end
            end

        end
    end

    % Post process to extract bound and area of region of interest.
    x = bwlabel(blockIndex, 4);
    % Remove redundant background area.
    y = bwmorph(x, 'close');
    % Remove background noise. 
    area = bwmorph(y, 'open');
    bound = bwperim(area);

end
