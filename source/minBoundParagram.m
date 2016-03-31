function [boundX, boundY] = minBoundParagram(x, y)
% This function calculates a minimal boundary parallelogram of input curve.
%
% Input
%   x: x coordinates of input curve points
%   y: y coordinates of input curve points
% Return
%   boundX: x coordinates of boundary vertices
%   boundY: y coordinates of boundary vertices

    % Preprocess data
    x = x(:);
    y = y(:);

    % Not many error checks to worry about
    n = length(x);
    if n~=length(y)
        error('x and y must be the same sizes')
    end

    % Start out with the convex hull of the points to
    % reduce the problem dramatically. Note that any
    % points in the interior of the convex hull are
    % never needed, so we drop them.
    if n>3
        edges = convhull(x,y);

        % Exclude those points inside the hull as not relevant
        % also sorts the points into their convex hull as a
        % closed polygon

        x = x(edges(1:(end-1)));
        y = y(edges(1:(end-1)));

        % Probably fewer points now, unless the points are fully convex
        nedges = length(x) - 1;

    elseif n > 1
        % n must be 2 or 3
        nedges = n;
        x(end+1) = x(1);
        y(end+1) = y(1);
    else
        % n must be 0 or 1
        nedges = n;
    end

    % Now we must find the bounding parallelogram of those
    % that remain.

    % Special case: small numbers of points. If we trip any
    % of these cases, then we are done, so return.
    switch nedges
        case 0
            % Empty begets empty
            boundX = [];
            boundY = [];
            area = [];
            perimeter = [];
            return
        case 1
            % With one point, the rect is simple.
            boundX = repmat(x, 1, 5);
            boundY = repmat(y, 1, 5);
            area = 0;
            perimeter = 0;
            return
        case 2
            % Only two points. also simple.
            boundX = x([1 2 2 1 1]);
            boundY = y([1 2 2 1 1]);
            area = 0;
            perimeter = 2*sqrt(diff(x) .^ 2 + diff(y) .^ 2);
            return
    end
    % 3 or more points.

    % We will need a 2x2 rotation matrix through an angle theta
    Rmat = @(theta) [cos(theta) sin(theta); -sin(theta) cos(theta)];

    % Get the angle of each edge of the hull polygon.
    nx = length(x);
    ind1 = 1 : nx;
    ind2 = circshift(ind1, [0, -1]);
    edgeangles = atan2(y(ind2) - y(ind1), x(ind2) - x(ind1));
    % Move the angle to be in [0,pi).
    edgeangles = mod(edgeangles, pi);

    % Now just check each edge of the convex hull
    nang = length(edgeangles);
%     area = inf;
%     perim = inf;
    met = inf;
    xy = [x, y];
    
    for i = 1 : nang
        % Line that defines the base of the parallelogram
        p1 = xy(i, :);

        % We will rotate and translate the points so this
        % edge lies on the x axis. The rotation matrix is...
        rot = Rmat(-edgeangles(i));
        xyr = (xy - repmat(p1, nx, 1)) * rot;

        % The height of the parallelogram is
        if max(xyr(:, 2)) >= max(-xyr(:, 2))
            pgheight = max(xyr(:, 2));
        else
            pgheight = min(xyr(:, 2));
        end

        % Rotate everything, but keep the angles in the interval [0,pi)
        anglesr = mod(edgeangles - edgeangles(i), pi);

        % What are the smallest and largest possible angles of the
        % remaining edges? This will define the limits of where the
        % secondary sides of the bounding parallelogram may lie.
        anglesr(i) = [];
        anglesr(anglesr == 0) = [];
        anglebounds = [min(anglesr), max(anglesr)];

        % Use fminbnd to search over the family of parallelograms with
        % the given base.
        sideang = fminbnd(@(ang) pgramObject(ang, xyr, pgheight),...
                                    anglebounds(1), anglebounds(2));

        % Get the final parallelogram
        [pmin, amin, pgxy] = pgramObject(sideang, xyr, pgheight);
        M_i = amin;

        % A new metric value for the current interval.
        if M_i < met
            % Keep this one
            met = M_i;
%             area = amin;
%             perim = pmin;

            % recover the parallelogram in the original coordinate system
            pgxy = pgxy * rot' + repmat(p1, 5, 1);

            boundX = pgxy(:, 1);
            boundY = pgxy(:, 2);
        end
    end


        % Sub function to generate object
        % =================================================================
        function [perim,area,pgxy] = pgramObject(angle, xyr, pgHeight)
        %  For a given angle (in radians) computes the bounding
        %  parallelogram where the base is assumed to lie on the
        %  x axis. Thus the upper face must be parallel to the x axis.
        % angle will always be in the open interval (0,pi)

            % The vector that points along the sides will be
            sidevec = [cos(angle), sin(angle)];

            % For this value of ang, what is the normal vector to
            % that side of the parallelogram? It always points in
            % the positive x direction, by the way it is constructed.
            nvec = [sin(angle); -cos(angle)];

            % What is the left most point that a side will hit against?
            % The rightmost? get that information from a dot product of
            % the points with the normal vector of the sides.
            dp = xyr * nvec;
            leftmost = min(dp);
            rightmost = max(dp);

            % A point on the line that contains the left side of the
            % parallelogram is 
            leftpoint = leftmost * nvec.';

            % And the right hand side line passes through this point.
            rightpoint = rightmost * nvec.';

            % We can define each line by the parametric equations
            % Pleft(t) = leftpoint + t*sidevec
            % Pright(t) = rightpoint + s*sidevec
            % 
            % now find the values of s and t, such that those lines
            % intersect the x axis (thus y == 0)
            t0 = -leftpoint(2) ./ sidevec(2);
            s0 = -rightpoint(2) ./ sidevec(2);

            % The actual x axis intercepts are at
            x1 = leftpoint(1) + t0*sidevec(1);
            x2 = rightpoint(1) + s0*sidevec(1);

            % The length of a side of the parallelogram is given by the
            % definition of the trig function from triangle sides.
            sidelength = pgHeight ./ cos(pi / 2 - angle);
            baselength = abs(x2 - x1);

            % So the perimeter of the parallellogram is given by
            perim = 2 * (abs(sidelength) + baselength);

            % Do not have to do these unless necessary
            if nargout > 1
                % The area is also trivial to compute, as
                area = abs(pgHeight)*baselength;

                % And the vertices of the parallelogram are
                pgxy = [[x1, 0]; [x2, 0]; ...
                        [x2, 0] + sidelength * sidevec;...
                        [x1, 0] + sidelength * sidevec;...
                        [x1, 0]];

            end

        end

end