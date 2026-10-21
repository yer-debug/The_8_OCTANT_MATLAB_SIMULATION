classdef FieldRenderer
    %FIELDRENDERER Draw field vectors at defined sample locations.
    methods (Static)
        function handles = draw(ax, positions, fields, defined, color, displayLength)
            handles = cell(1, nnz(defined));
            handleIndex = 0;
            for index = 1:size(positions, 1)
                if ~defined(index)
                    continue;
                end
                magnitude = norm(fields(index, :));
                if magnitude == 0
                    continue;
                end
                direction = fields(index, :) ./ magnitude;
                handleIndex = handleIndex + 1;
                handles{handleIndex} = quiver3(ax, ...
                    positions(index, 1), positions(index, 2), positions(index, 3), ...
                    direction(1) * displayLength, ...
                    direction(2) * displayLength, ...
                    direction(3) * displayLength, 0, ...
                    'Color', color, 'LineWidth', 1.7, 'MaxHeadSize', 0.65, ...
                    'HandleVisibility', 'off');
            end
        end
    end
end