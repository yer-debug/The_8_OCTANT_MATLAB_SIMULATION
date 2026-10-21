classdef FieldVectorEngine
    %FIELDVECTORENGINE Evaluate supported electromagnetic models at many points.
    methods (Static)
        function [fields, defined] = evaluate(mode, positionsMeters, config)
            if isstring(mode) && isscalar(mode)
                mode = char(mode);
            end
            if ~ischar(mode)
                error('MATLAB:FieldVectorEngine:invalidMode', ...
                    'mode must be Off, Electric, or Magnetic.');
            end
            validateattributes(positionsMeters, {'numeric'}, ...
                {'real', 'finite', '2d', 'ncols', 3}, mfilename, 'positionsMeters');

            fields = zeros(size(positionsMeters));
            defined = true(size(positionsMeters, 1), 1);
            for index = 1:size(positionsMeters, 1)
                switch lower(mode)
                    case 'off'
                        fields(index, :) = [NaN, NaN, NaN];
                        defined(index) = false;
                    case 'electric'
                        [fields(index, :), defined(index)] = ...
                            ElectricFieldModel.evaluate(positionsMeters(index, :), ...
                            config.pointChargeCoulombs, config.epsilon0);
                    case 'magnetic'
                        [fields(index, :), defined(index)] = ...
                            MagneticFieldModel.evaluate(positionsMeters(index, :), ...
                            config.wireCurrentAmps, config.mu0);
                    otherwise
                        error('MATLAB:FieldVectorEngine:invalidMode', ...
                            'mode must be Off, Electric, or Magnetic.');
                end
            end
        end
    end
end