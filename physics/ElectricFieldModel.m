classdef ElectricFieldModel
    %ELECTRICFIELDMODEL Electric field of an ideal point charge at the origin.
    methods (Static)
        function [field, defined] = evaluate(positionMeters, chargeCoulombs, epsilon0)
            validateattributes(positionMeters, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3}, mfilename, 'positionMeters');
            validateattributes(chargeCoulombs, {'numeric'}, ...
                {'real', 'finite', 'scalar'}, mfilename, 'chargeCoulombs');
            validateattributes(epsilon0, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive'}, mfilename, 'epsilon0');

            positionMeters = reshape(positionMeters, 1, 3);
            radius = norm(positionMeters);
            defined = radius > 0;
            if ~defined
                field = [NaN, NaN, NaN];
                return;
            end
            field = (chargeCoulombs / (4 * pi * epsilon0)) .* ...
                positionMeters ./ radius^3;
        end
    end
end