classdef MagneticFieldModel
    %MAGNETICFIELDMODEL Magnetic field of an ideal infinite wire along +Z.
    methods (Static)
        function [field, defined] = evaluate(positionMeters, currentAmps, mu0)
            validateattributes(positionMeters, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3}, mfilename, 'positionMeters');
            validateattributes(currentAmps, {'numeric'}, ...
                {'real', 'finite', 'scalar'}, mfilename, 'currentAmps');
            validateattributes(mu0, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive'}, mfilename, 'mu0');

            positionMeters = reshape(positionMeters, 1, 3);
            radiusSquared = positionMeters(1)^2 + positionMeters(2)^2;
            defined = radiusSquared > 0;
            if ~defined
                field = [NaN, NaN, NaN];
                return;
            end
            coefficient = mu0 * currentAmps / (2 * pi * radiusSquared);
            field = coefficient .* [-positionMeters(2), positionMeters(1), 0];
        end
    end
end