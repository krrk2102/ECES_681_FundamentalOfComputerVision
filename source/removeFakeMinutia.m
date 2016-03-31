function [pathMap, realEndList] =...
                        removeFakeMinutia(image, allEndPoints,...
                                allBranchPoints, ridgeOrders, ridgeWidth)
% This function examines and removes fake minutia points.
%
% Input
%   image: fingerprint image
%   allEndPoints: end points list generated from minutia extraction
%                 function
%   allBranchPoints: branch points list generated from minutia
%                    extraction fucntion
%   ridgeOrders: a list recording order of ridges
%   ridgeWidth: number of pixels of average ridge width
% Return
%   pathMap: paths of ridges
%   realEndList: end points list of reduced minutia points

    realEndList = [];
    pathMap = [];

    allEndPoints(:, 3) = 0;
    allBranchPoints(:, 3) = 1;

    minutiaeList = [allEndPoints; allBranchPoints];
    pointList = minutiaeList;
    [numMinutia, ~] = size(minutiaeList);
    potentialList = [];

    % Calculate potential minutia points.
    for i = 1 : numMinutia - 1
        for j = i + 1 : numMinutia
            
            edge = ((minutiaeList(i, 1) - minutiaeList(j, 1)) ^ 2 +...
                    (minutiaeList(i, 2) - minutiaeList(j, 2)) ^ 2) ^ 0.5;
            if edge < ridgeWidth
                potentialList = [potentialList; [i, j]];
            end
        end
    end

    % Examine and remove redundant or fake minutia points.
    [numPotential, ~] = size(potentialList);
    for i = 1 : numPotential
        
        numType = minutiaeList(potentialList(i, 1), 3) +...
                            minutiaeList(potentialList(i, 2), 3);
        if numType == 1
            % Build pairs of branch and end points.
            if ridgeOrders(minutiaeList(potentialList(i, 1), 1), ...
                    minutiaeList(potentialList(i, 1), 2)) ==...
                    ridgeOrders(minutiaeList(potentialList(i, 2), 1),...
                    minutiaeList(potentialList(i, 2), 2))
                pointList(potentialList(i, 1), 1 : 2) = [-1, -1];
                pointList(potentialList(i, 2), 1 : 2) = [-1, -1];
            end

        elseif numType == 2
            
            if ridgeOrders(minutiaeList(potentialList(i, 1), 1), ...
                    minutiaeList(potentialList(i, 1), 2)) ==...
                    ridgeOrders(minutiaeList(potentialList(i, 2), 1),...
                    minutiaeList(potentialList(i, 2), 2))
                pointList(potentialList(i, 1), 1 : 2) = [-1, -1];
                pointList(potentialList(i, 2), 1 : 2) = [-1, -1];
            end

        elseif numType == 0
            % Build end points to end points pairs.
            minutiaP1 = minutiaeList(potentialList(i, 1), 1 : 3);
            minutiaP2 = minutiaeList(potentialList(i, 2), 1 : 3);

            if ridgeOrders(minutiaP1(1), minutiaP1(2)) ~=...
                            ridgeOrders(minutiaP2(1), minutiaP2(2))

                [thetaP1, pathP1, ~, ~] = getLocalTheta(image, ...
                                                minutiaP1, ridgeWidth); 
                [thetaP2, pathP2, ~, ~] = getLocalTheta(image, ...
                                                minutiaP2, ridgeWidth); 

                % End points too close will be removed.
                thetaC = atan2((pathP1(1, 1) - pathP2(1, 1)), ...
                                            (pathP1(1, 2) - pathP2(1, 2)));
                angleAB = abs(thetaP1 - thetaP2);
                angleAC = abs(thetaP1 - thetaC);

                if ((or(angleAB < pi / 3, abs(angleAB - pi) < pi / 3))...
                                            && (or(angleAC < pi / 3, ...
                                            abs(angleAC - pi) < pi / 3)))  
                    pointList(potentialList(i, 1), 1 : 2) = [-1, -1];
                    pointList(potentialList(i, 2), 1 : 2) = [-1, -1];
                end
            % Ridges too short will be removed. 
            elseif  ridgeOrders(minutiaP1(1), minutiaP1(2)) ==...
                            ridgeOrders(minutiaP2(1), minutiaP2(2))        
                pointList(potentialList(i, 1), 1 : 2) = [-1, -1];
                pointList(potentialList(i, 2), 1 : 2) = [-1, -1];

            end
        end
    end

    for i = 1 : numMinutia
        if pointList(i, 1 : 2) ~= [-1, -1]
            
            if pointList(i, 3) == 0
                [thetaI, pathI, ~, ~] = getLocalTheta(image,...
                                            pointList(i, :), ridgeWidth);
                if size(pathI, 1) >= ridgeWidth
                    realEndList = [realEndList; ...
                                    pointList(i , 1 : 2), thetaI];
                    [pointID, ~] = size(realEndList);
                    pathI(:, 3) = pointID;
                    pathMap = [pathMap; pathI];
                end
            else
                [thetaI, path1, path2, path3] = getLocalTheta(image,...
                                            pointList(i, :), ridgeWidth);
                if size(path1, 1) >= ridgeWidth &&...
                                size(path2, 1) >= ridgeWidth &&...
                                    size(path3, 1) >= ridgeWidth

                    realEndList = [realEndList;...
                                    path1(1, 1 : 2), thetaI(1)];
                    [pointID, ~] = size(realEndList);
                    path1(:, 3) = pointID;
                    pathMap = [pathMap; path1];

                    realEndList = [realEndList;...
                                    path2(1, 1 : 2), thetaI(2)];
                    path2(:, 3) = pointID + 1;
                    pathMap = [pathMap; path2];

                    realEndList = [realEndList;...
                                    path3(1, 1 : 2), thetaI(3)];
                    path3(:, 3) = pointID + 2;
                    pathMap = [pathMap; path3];

                end
            end
        end
    end
    
end