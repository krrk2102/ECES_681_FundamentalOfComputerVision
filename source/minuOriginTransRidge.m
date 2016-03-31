function newCoord = minuOriginTransRidge(trueEndPoints, k, ridgeOrder)
% This function analyze set k-th minutia point as origin and tranform
% points into new coordinate system. It accomodates all other ridge points
% connected to this point.
% 
% Input
%   trueEndPoints: the set of points of reduced minutia points
%   k: assigned number of minutia point
%   ridgeOrder: order of ridge information
% Return
%   newCoord: the transformed coordinates
      
    theta = trueEndPoints(k, 3);
    if theta < 0
        theta1 = 2 * pi + theta;
    else
        theta1 = pi / 2 - theta;
    end
    rotateMatrix = [cos(theta1), -sin(theta1); sin(theta1), cos(theta1)];

    % Locate all the ridge points connecting to the miniutia
    % and transpose them. 
    pathPointK = find(ridgeOrder(:, 3) == k);
    transformimgPoints = ridgeOrder(min(pathPointK) :...
                                        max(pathPointK), 1 : 2)';

    % Translate the minutia position (x,y) to (0,0),
    % and translate all other ridge points according to the basis 
    trickLength = size(transformimgPoints, 2);
    pathStart = trueEndPoints(k, 1 : 2)';
    translatedPointSet = transformimgPoints -...
                            pathStart(:, ones(1, trickLength));

    % Rotate the points to be transformed.
    newCoord = rotateMatrix * translatedPointSet;
      
end