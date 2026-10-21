classdef VectorEngine
    %VECTORENGINE Basic Cartesian vector calculations for 3-element vectors.
    methods (Static)
        function value = magnitude(vector)
            vector = VectorEngine.validate(vector, 'vector');
            value = sqrt(sum(vector .^ 2));
        end

        function result = add(first, second)
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            result = first + second;
        end

        function result = subtract(first, second)
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            result = first - second;
        end

        function result = scale(vector, scalar)
            vector = VectorEngine.validate(vector, 'vector');
            validateattributes(scalar, {'numeric'}, ...
                {'real', 'finite', 'scalar'}, mfilename, 'scalar');
            result = vector .* scalar;
        end

        function value = dot(first, second)
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            value = sum(first .* second);
        end

        function result = cross(first, second)
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            result = cross(first, second);
        end

        function result = unitVector(vector)
            vector = VectorEngine.validate(vector, 'vector');
            vectorMagnitude = VectorEngine.magnitude(vector);
            if vectorMagnitude == 0
                error('MATLAB:VectorEngine:zeroVector', ...
                    'A zero vector has no defined unit vector.');
            end
            result = vector ./ vectorMagnitude;
        end

        function angles = directionAngles(vector)
            vector = VectorEngine.validate(vector, 'vector');
            vectorMagnitude = VectorEngine.magnitude(vector);
            if vectorMagnitude == 0
                angles = [NaN, NaN, NaN];
                return;
            end
            angles = acosd(vector ./ vectorMagnitude);
        end

        function angle = angleBetween(first, second)
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            firstMagnitude = VectorEngine.magnitude(first);
            secondMagnitude = VectorEngine.magnitude(second);
            if firstMagnitude == 0 || secondMagnitude == 0
                error('MATLAB:VectorEngine:zeroVector', ...
                    'Angle is undefined when either vector is zero.');
            end
            cosine = VectorEngine.dot(first, second) / ...
                (firstMagnitude * secondMagnitude);
            angle = acosd(max(-1, min(1, cosine)));
        end

        function result = isPerpendicular(first, second, tolerance)
            if nargin < 3
                tolerance = 1e-10;
            end
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            tolerance = VectorEngine.validateTolerance(tolerance);
            firstMagnitude = VectorEngine.magnitude(first);
            secondMagnitude = VectorEngine.magnitude(second);
            result = firstMagnitude > 0 && secondMagnitude > 0 && ...
                abs(VectorEngine.dot(first, second)) <= ...
                tolerance * firstMagnitude * secondMagnitude;
        end

        function result = isParallel(first, second, tolerance)
            if nargin < 3
                tolerance = 1e-10;
            end
            first = VectorEngine.validate(first, 'first');
            second = VectorEngine.validate(second, 'second');
            tolerance = VectorEngine.validateTolerance(tolerance);
            firstMagnitude = VectorEngine.magnitude(first);
            secondMagnitude = VectorEngine.magnitude(second);
            result = firstMagnitude > 0 && secondMagnitude > 0 && ...
                VectorEngine.magnitude(VectorEngine.cross(first, second)) <= ...
                tolerance * firstMagnitude * secondMagnitude;
        end
    end

    methods (Static, Access = private)
        function tolerance = validateTolerance(tolerance)
            validateattributes(tolerance, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'nonnegative'}, mfilename, 'tolerance');
        end

        function vector = validate(vector, argumentName)
            validateattributes(vector, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3}, mfilename, argumentName);
            vector = reshape(vector, 1, 3);
        end
    end
end