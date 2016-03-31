function [endPointList, branchPointList, ridgeOrderMap, ridgeWidth] = ...
                                markMinutia(image, RoiArea, blockSize)
% This function analyze fingerprint image, and find minutia information 
% including end points, branch points, ridge order and finger print ridge
% width.
%
% Input
%   image: input fingerprint image
%   inArea: ROI area information map
%   blockSize: size of information processing by blocks
% Return
%   endPointList: vector of end points coordinates of fingerprint
%   branchPointList: vector of branch points coordinates of fingerprint
%   ridgeOrderMap: an matrix containing order of ridges
%   edgeWidth: a variable indicating fingerprint edge width


    % Initialize variables.
    [ridgeOrderMap, totalRidgeNum] = bwlabel(image); 
    ridgeWidth = getRidgeWidth(image, RoiArea);
    endPointList = [];
    branchPointList = [];

    % Analyze minutia points by ridges.
    for n = 1 : totalRidgeNum
        
        [rowPos, colPos] = find(ridgeOrderMap == n);
        ridgeInfo = [rowPos, colPos];
        ridgeLength = size(ridgeInfo, 1);

        for x = 1 : ridgeLength
            
            i = ridgeInfo(x, 1);
            j = ridgeInfo(x, 2);

            if RoiArea(ceil(i / blockSize), ceil(j / blockSize)) == 1          
                
                neigborCount = sum(sum(image(i - 1 : i + 1, j - 1 : j + 1)));
                neigborCount = neigborCount - 1;

                if neigborCount == 1 
                    % Mark current point as end point if no adjacent 
                    % white pixels. 
                    endPointList =[endPointList; [i,j]];
                elseif neigborCount == 3
                    % Process of potential branch points.
                    block = image(i - 1 : i + 1, j - 1 : j + 1);
                    block(2, 2) = 0;
                    [ridgeRow, ridgeCol] = find(block == 1);
%                     t = [abr, bbr];

                    % Add branch points.
                    if isempty(branchPointList)
                        branchPointList = [branchPointList; [i, j]];
                    else   
                        for p = 1 : 3
                            violatePoints =...
                                find(...
                                (branchPointList(:, 1) == (ridgeRow(p) - 2 + i)) &...
                                (branchPointList(:, 2) == (ridgeCol(p) - 2 + j)), 1);
                            
                            if ~isempty(violatePoints)
                                p = 4;
                                break;
                            end
                        end

                        if p == 3
                            branchPointList = [branchPointList; [i, j]];
                        end
                    end
                    
                end	
            end
            
        end
    end

end