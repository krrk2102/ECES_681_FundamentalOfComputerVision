function [theta, paths1, paths2, paths3] = ...
                    getLocalTheta(image, startPoint, ridgeWidth)
% This function calculates the angle of local direction of each block. 
%
% Input
%   image: input fingerprint image
%   startPoint: point to start angle calculation
%   ridgeWidth: number of pixels of ridge width
% Return
%   theta: angle of local direction
%   path1: path of current ridge

    paths1 =[];
    paths2 =[];
    paths3 =[];

    path = [];
	path = startPoint(1, 1 : 2);
    theta = [];
         
    if startPoint(3) == 0
         for p = 1 : ridgeWidth
            
            [cur, ~] = size(path);
            i = path(cur, 1);
            j = path(cur, 2);
            
            block = image(i - 1 : i + 1, j - 1 : j + 1);
            block(2, 2) = 0;

            if cur > 1
                block(2 - path(cur, 1) + path(cur - 1, 1), ...
                            2 - path(cur, 2) + path(cur - 1,2)) = 0;
            end

            [rowPos, colPos] = find(block);
            interPoint = [rowPos, colPos];
            [neighbors,~] = size(interPoint);

            if neighbors == 1
                path(cur + 1, 1) = interPoint(1, 1) - 2 + path(cur, 1);
                path(cur + 1, 2) = interPoint(1, 2) - 2 + path(cur, 2);
            else
                break;
            end
        end
         
	    [path_length, ~] = size(path);			
        paths1 = path;
        
		meanVals = sum(path);
            
        meanXVals = meanVals(1) / path_length;
		meanYVals = meanVals(2) / path_length;

		theta = atan2((meanXVals - path(1, 1)), (meanYVals - path(1, 2)));
            
    elseif startPoint(3) == 1
        
   		path = [];
        i = startPoint(1);
        j = startPoint(2);
        path(1, :) = [i, j];
            
        block = image(i - 1 : i + 1, j - 1 : j + 1);
        block(2, 2) = 0;
        [rowPos, colPos] = find(block);
        interPoint = [rowPos, colPos];
        [neighbors, ~] = size(interPoint);
            
        if neighbors == 3
            for s = 1 : 3
      
                path(2, 1) = interPoint(s, 1) - 2 + path(1, 1);
                path(2, 2) = interPoint(s, 2) - 2 + path(1, 2);
      
                for p = 1 : ridgeWidth
            
                    [cur, ~] = size(path);
                    i = path(cur, 1);
                    j = path(cur, 2);
            
                    block = image(i - 1 : i + 1, j - 1 : j + 1);
                    block(2, 2) = 0;
            
                    if cur > 1
                        block(2 - path(cur, 1) + path(cur - 1, 1),...
                               2 - path(cur, 2) +  path(cur - 1, 2)) = 0;
                    end
                    
                    [rowPos, colPos] = find(block);
                    tmpPoint = [rowPos, colPos];
                    [neighbors, ~] = size(tmpPoint);
                                    
                    if neighbors == 1
                        path(cur + 1, 1) = tmpPoint(1, 1) - 2 + path(cur, 1);
                        path(cur + 1, 2) = tmpPoint(1, 2) - 2 + path(cur, 2);
                    else
                        break;
                    end
                end   
         
                [path_length, ~] = size(path);			
                meanVals = sum(path);
                meanXVals = meanVals(1) / path_length;
                meanYVals = meanVals(2) / path_length;
         
                theta = [theta; atan2((meanXVals - path(1, 1)),...
                                            (meanYVals - path(1, 2)))];
         
                if s == 1
                    paths1 = path(2 : path_length, :);
                elseif s == 2
                    paths2 = path(2 : path_length, :);
                elseif s == 3
                    paths3 = path(2 : path_length, :);
                end
         
                path(2 : path_length, :) = [];
            end
        end

    end
    
end



            
            

