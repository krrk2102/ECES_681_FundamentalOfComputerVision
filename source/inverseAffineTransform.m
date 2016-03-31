function recovered = inverseAffineTransform(original, distorted)
% This function compares original image and distorted image, and tries to 
% find inverse affine transform matrix.
%
% Input
%   original: original image
%   distorted: distorted image
% Return
%   recovered: recovered image from distorted image by inverse affine
%              transform


    % Pre-processing 2 images and get boundaries of fingerprints. 
    recovered = distorted;
    original = histeq(original);
    distorted = histeq(distorted);

    original = edge(original, 'canny');
    distorted = edge(distorted, 'canny');

    % Get boundaries of 2 fingerprints.
    chOri = bwconvhull(original);
    chDis = bwconvhull(distorted);

    bOri = bwboundaries(chOri);
    bDis = bwboundaries(chDis);

    % Retrieve minimal bound parallelogram of 2 fingerprints.
    [pyOri, pxOri] = minBoundParagram(bOri{1}(:, 1), bOri{1}(:, 2));
    [pyDis, pxDis] = minBoundParagram(bDis{1}(:, 1), bDis{1}(:, 2));

    [pxOri, pyOri] = sortPoints(pxOri, pyOri);
    [pxDis, pyDis] = sortPoints(pxDis, pyDis);

    % Calculate moments of 2 boundaries respectively. 
    Curve = [pxOri, pyOri];
    Curve_T = [pxDis, pyDis];

    % Weighted Moments.
    Curve_mean = mean(Curve);
    Curve_T_mean = mean(Curve_T);
    N = 3;
    % The first row of Ders is the 0th order derivative.
    derivatives = FindNthDers_2D(Curve, N); 
    transformedDrivatives = FindNthDers_2D(Curve_T, N); 
    CO = zeros(N, 2);
    COT = zeros(N, 2);
    
    for i = 1 : N
        
        [~, CO(i,:)] = w_moments_2D_Area(derivatives, i);
        [~, COT(i,:)] = w_moments_2D_Area(transformedDrivatives, i);
        
    end
    
    % Find L & t
    L = CO \ COT;
    t = Curve_T_mean - Curve_mean * L;

    % Performing inverse affine transformation.
    affineMatrix = [L, zeros(2, 1); t, 1];
    iAffine2d = invert(affine2d(affineMatrix));
    tForm = maketform('affine', iAffine2d.T);
    bgColor = double(recovered(1, 1));
    recovered = imtransform(recovered, tForm, 'FillValues', bgColor);

end

