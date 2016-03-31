function derivatives = FindNthDers_2D(curve, N)
% This function calculates derivative of input curve, from 0th derivative
% to the Nth. 
%
% Input
%   curve: input points consisting the curve
%   N: denote number of derivatives
% Return
%   derivatives: result

    derivatives = cell(N + 1, 1);
    if curve(1, :) ~= curve(size(curve, 1), :)
        numPts = size(curve, 1);
        curve(numPts + 1, :) = curve(1, :);
    else
        numPts = size(curve, 1) - 1;
    end
    
    for i = 1 : N + 1
        derivatives{i} = zeros(numPts + 1, 2);
    end
    dx = zeros(numPts + 1, 1);
    dy = zeros(numPts + 1, 1);
    derivatives{1} = curve;
    for i = 2 : N + 1
        x = derivatives{i - 1}(:, 1);
        y = derivatives{i - 1}(:, 2);
        for j = 1 : numPts
            xx = x(rem(j, numPts) + 1) - x(j);
            yy = y(rem(j, numPts) + 1) - y(j);
            dx(j) = xx;
            dy(j) = yy;
            if isnan(dx(j)) || isnan(dy(j))
                disp(['The ', num2str(i-1), '~', num2str(N),...
                            ' order derivative does NOT exist!']);
                return;
            end
        end
        dx(j + 1) = dx(1);
        dy(j + 1) = dy(1);
        derivatives{i}(:, 1) = dx;
        derivatives{i}(:, 2) = dy;
    end
end
