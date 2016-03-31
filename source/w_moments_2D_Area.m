function [ma, co] = w_moments_2D_Area(derivatives, j)
% This function calculates the affine transformation matrix coefficients
% and moments.
%
% Input
%   derivatives: input derivatives from 0th to Nth order
%   j: denominated jth order of derivative used
% Return
%   ma: moments coefficients
%   co: affine transform coefficients

    ma = zeros(2, 2);
    numPts = length(derivatives{1});
    % the highest order of derivatives we have
    HoD = size(derivatives, 1) - 1; 
    if j > HoD
        disp([ num2str(j), ...
            'th kind kernel requires ', num2str(j), ...
            'th order derivatives, the highest order now is only ', ...
            num2str(HoD), '!' ]);
        return;
    end
    
    x = derivatives{1}(:, 1);
    y = derivatives{1}(:, 2);
    
    for i = 1 : numPts
        
        A = [derivatives{j}(i, 1), derivatives{j + 1}(i, 1);...
             derivatives{j}(i, 2), derivatives{j + 1}(i, 2) ];
        w = nthroot(abs(det(A)), 2 * j - 1);
        ma(1, 1) = ma(1, 1) + w;
        ma(2, 1) = ma(2, 1) + x(i) * w;
        ma(1, 2) = ma(1, 2) + y(i) * w;
        
    end
    
    if ma(1, 1) ~= 0
        co = [ma(2, 1) / ma(1, 1), ma(1, 2) / ma(1, 1)];
    else
        co = [0, 0];
    end
    
end