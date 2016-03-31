function percent = FpCompare(original, distorted)
% This function accepts bitmap gray scale images of 2 fingerprints and
% analyzes 2 images, computes and exports the percentage of how much those
% 2 fingerprints match to each other.
%
% Input
%   original: it is supposed to be the template of fingerprint
%   distorted: it is supposed to be the fingerprint to be recognized.
% Return
%   percent: the percentage of how 2 fingerprints match to each other

    % Perform inverse affine transformation to align 2 figerprints
    % together.
    distorted = inverseAffineTransform(original, distorted);
    original = cutBackground(original);
    distorted = cutBackground(distorted);
    
    % Extracting minutia information of 2 fingerprints. 
    oriFpInfo = imageAnalysis(original);
    disFpInfo = imageAnalysis(distorted);
    
    % Comparing and evaluating similarity between 2 fingerprints. 
    percent = matchFingerprints(oriFpInfo, disFpInfo);

end

