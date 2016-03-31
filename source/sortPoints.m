function [newX, newY] = sortPoints(x, y)
% This function put the point that has max sum of x and y coordinates at
% the first, while relative order of points are maintained. 
%
% Input
%   x: x coordinates of input points
%   y: y coordinates of input points
% Return
%   newX: updated order of x coordinates of points
%   newY: updated order of y coordinates of points

    newX = x;
    newY = y;
    
    % Get position of points with max sum of x and y coordinates.
    sum = x + y;
    sum(end - 1, :) = [];
    [~, sumIndex] = sort(sum, 'descend');
    startIndex = sumIndex(1, 1);
    
    % Copy and reserve relative order among points. 
    for i = 1 : size(sum, 1)
        
        newX(i, :) = x(startIndex, :);
        newY(i, :) = y(startIndex, :);
        startIndex = rem(startIndex, size(sum, 1)) + 1;
        
    end
    
    newX(end, :) = newX(1, :);
    newY(end, :) = newY(1, :);

end

