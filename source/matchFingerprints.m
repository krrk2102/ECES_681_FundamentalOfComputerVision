function matchPercentage = matchFingerprints(FPinfo1, FPinfo2)
% This function calculates percentage of how 2 input fingerprints match to
% each other. 
%
% Input
%   FPinfo1: minutia points and ridge map information of fingerprint 1, and
%            it is supposed to be a N * 3 matrix
%   FPinfo2: minutia points and ridge map information of fingerprint 2, and
%            it is supposed to be a N * 3 matrix
% Return
%   matchPercentage: double variable indicating percentage of how 2
%                    fingerprint images matches

    % Decompose the template file into minutia and ridge matrixes seperately
    edgeWidth = 10;
    if or(isempty(FPinfo1), isempty(FPinfo2))
        matchPercentage = -1;
    else
        
        FpSize1 = size(FPinfo1, 1);
        minuPoints1 = FPinfo1(FpSize1, 3);
        trueEndPoints1 = FPinfo1(1 : minuPoints1, :);
        ridgeMap1= FPinfo1(minuPoints1 + 1 : FpSize1, :);

        FpSize2 = size(FPinfo2, 1);
        minuPoints2 = FPinfo2(FpSize2, 3);
        trueEndPoints2 = FPinfo2(1 : minuPoints2, :);
        ridgeMap2 = FPinfo2(minuPoints2 + 1 : FpSize2, :);

        numMinuPts1 = minuPoints1;
        numMinuPts2 = minuPoints2;
        maxMatchingInfo = zeros(1, 3);

        for i1 = 1 : numMinuPts1

            % Calculate the similarities between ridgeMap1 and ridgeMap2
            % and choose the current two minutia as origins and adjust 
            % other minutia based on the origin minutia.
            newCoord1 = minuOriginTransRidge(trueEndPoints1, i1, ridgeMap1);
            for i2 = 1 : numMinuPts2

                newCoord2 = minuOriginTransRidge(trueEndPoints2,...
                                                        i2, ridgeMap2);
                % Choose the minimum ridge length
                ridgeLengths = min(size(newCoord1, 2),size(newCoord2, 2));
                % Compare the similarity certainty of two ridge
                pairRidges = newCoord1(1, 1 : ridgeLengths) .*...
                                        newCoord2(1, 1 : ridgeLengths);
                pairSquare = pairRidges .* pairRidges;
                pairSqSum = sum(pairSquare);

                ridgeSimilarity = 0;
                if pairSqSum > 0
                    ridgeSimilarity = sum(pairRidges) / (pairSqSum .^ 5);
                end

                if ridgeSimilarity > 0.8
                    % Transform all the minutia in 2 fingerprints by
                    % the reference pair of minutia points.
                    fullCoord1 = minuOriginTransAll(trueEndPoints1, i1);
                    fullCoord2 = minuOriginTransAll(trueEndPoints2, i2);

                    minuNum1 = size(fullCoord1, 2);
                    minuNum2 = size(fullCoord2, 2);
                    coordRange = edgeWidth;
                    numMatchPts = 0;

                    % If two minutia are within a box with width and height
                    % of 20, and they have small direction variation pi/3
                    % then regard them as matched pair.
                    for i = 1 : minuNum1 
                        for j = 1 : minuNum2  
                            if (abs(fullCoord1(1, i) - fullCoord2(1, j))...
                                < coordRange && abs(fullCoord1(2, i) -...
                                    fullCoord2(2, j)) < coordRange)
                                angle = abs(fullCoord1(3, i) -...
                                                fullCoord2(3, j));
                                if or(angle < pi / 3, abs(angle - pi)...
                                                            < pi / 6)
                                    numMatchPts = numMatchPts + 1;     
                                    break;
                                end
                            end 
                        end
                    end

                    % Get the largest matching score
                    curMatchingPts = numMatchPts;
                    if curMatchingPts > maxMatchingInfo(1, 1);
                        maxMatchingInfo(1, 1) = curMatchingPts;
                        maxMatchingInfo(1, 2) = i1;
                        maxMatchingInfo(1, 3) = i2;
                    end

                end
            end
        end

        matchPercentage = maxMatchingInfo(1, 1) * 100 / numMinuPts1;
    end

end