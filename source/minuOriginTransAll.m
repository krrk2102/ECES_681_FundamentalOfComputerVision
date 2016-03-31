function newCoord = minuOriginTransAll(trueEndPoints, k)
% Similar to minuOriginTransRidge, this function computes a new coordinates
% system by setting kth end points as origin, and accomodates all other
% minutia points.
%
% Input
%   trueEndPoints: coordinates of reduced end points
%   k: denominated number of end point used as new origin
% Return
%   newCoord: the transformed new coordinate system


    theta = trueEndPoints(k, 3);
    if theta <0
        theta1 = 2 * pi + theta;
    else
        theta1 = pi / 2 - theta;
    end

    rotateMatrix = [cos(theta1), -sin(theta1), 0;...
                    sin(theta1), cos(theta1), 0;...
                    0, 0, 1 ];
    transformingPoints = trueEndPoints';
    trickLength = size(transformingPoints, 2);
    
    pathBegin = trueEndPoints(k, :)';
    translatedPointSet = transformingPoints - ...
                            pathBegin(:, ones(1, trickLength));
    newCoord = rotateMatrix * translatedPointSet;

    for i = 1 : trickLength
        if or(newCoord(3, i) > pi, newCoord(3, i) < -pi)
            newCoord(3, i) = 2 * pi - sign(newCoord(3, i)) * newCoord(3, i);
        end
    end

end	