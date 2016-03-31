function ridgeWidth = getRidgeWidth(image, RoiArea)
% This function interprets width of ridges in fingerprints.
%
% Input
%   image: input fingerprint image
%   RoiArea: area information of region of interest
% Return
%   ridgeWidth: interpreted width

    % Initialize information. 
    [numRow, numCol] = size(image);
    areaByRow = sum(RoiArea);
    RoiRows = find(areaByRow > 0);
    upper = min(RoiRows);
    bottom = max(RoiRows);
    i = round(numRow / 5);
    horizontalSum = 0;

    % Analyze horizontal average ridge width. 
    for k = 1 : 4
        horizontalSum = horizontalSum + ...
                            sum(image(k * i, 16 * upper : 16 * bottom));
    end
    
    horizontalAverage = 64 * (bottom - upper) / horizontalSum;

    % Initializatio again. 
    areaByCol = sum(RoiArea, 2);
    RoiCols = find(areaByCol > 0);
    left = min(RoiCols);
    right = max(RoiCols);
    i = round(numCol / 5);
    verticalSum = 0;

    % Analyze vertical average ridge width. 
    for k=1:4
        verticalSum = verticalSum + ...
                            sum(image(16 * left : 16 * right, k * i));
    end
    
    % Calculate overall average ridge width. 
    verticalAverage = 64 * (right - left) / verticalSum;
    ridgeWidth = round((verticalAverage + horizontalAverage) / 2);

end