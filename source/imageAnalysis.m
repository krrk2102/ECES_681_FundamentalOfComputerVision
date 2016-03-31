function FpInfo = imageAnalysis(image)
% This function accepts an image contains the fingerprint with minimal
% possible backgrounds, then processes and analysis the image, exports
% fingerprint minutia points and ridge information at last.
%
% Input
%   image: input properly sized fingerprint image
% Return
%   FpInfo: analysis result, minutia and ridge information of the finger
%           print

    % Filtering the image noise.
    image = uint8(filter2(fspecial('average', 3), image));
    image = medfilt2(image);
    
    % Enhance ridges of fingerprint and convert figureprint to black-white
    % image. 
    image = fftEnhance(image, 0.2);
    image = toBwFingerPrints(image, 32);
    
    % Calculates region of interest, and remove unrelated background and
    % noise by blocks.
    blockSize = 16;
    [RoiBound, RoiArea] = getDirections(image, blockSize);
    [image, ~, RoiArea] = getROI(image, RoiBound, RoiArea);
    
    % Thining ridges of fingerprints, and remove small islands and branches
    % which are likely to be caused by noise and error.
    image = im2double(bwmorph(image, 'thin', Inf));
    image = im2double(bwmorph(image, 'clean'));
    image = im2double(bwmorph(image, 'hbreak'));
    image = im2double(bwmorph(image, 'spur'));
    
    % Extracting minutia points. 
    [endList, branchList, ridgeOrder, ridgeWidth] = ...
                        markMinutia(image, RoiArea, blockSize);
    % Remove redundant and fake minutia points. 
    [pathMap, trueEnd] = removeFakeMinutia(image,...
                        endList, branchList, ridgeOrder, ridgeWidth);
    
    % Exports integrated fingerprint information
    FpInfo = [trueEnd; pathMap];

end

