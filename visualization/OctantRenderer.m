classdef OctantRenderer
    %OCTANTRENDERER Draw coordinate planes and identify the eight octants.
    methods (Static)
        function handles = draw(ax, extent)
            handles = cell(1, 14);
            handleIndex = 0;
            gridValues = [-extent, extent];
            [first, second] = meshgrid(gridValues, gridValues);
            hold(ax, 'on');
            handleIndex = handleIndex + 1;
            handles{handleIndex} = surf(ax, zeros(size(first)), first, second, ...
                'FaceColor', [0.42, 0.62, 0.67], 'FaceAlpha', 0.08, ...
                'EdgeColor', 'none', 'HandleVisibility', 'off');
            handleIndex = handleIndex + 1;
            handles{handleIndex} = surf(ax, first, zeros(size(first)), second, ...
                'FaceColor', [0.78, 0.62, 0.38], 'FaceAlpha', 0.08, ...
                'EdgeColor', 'none', 'HandleVisibility', 'off');
            handleIndex = handleIndex + 1;
            handles{handleIndex} = surf(ax, first, second, zeros(size(first)), ...
                'FaceColor', [0.48, 0.65, 0.48], 'FaceAlpha', 0.08, ...
                'EdgeColor', 'none', 'HandleVisibility', 'off');

            plot3(ax, [-extent, extent], [0, 0], [0, 0], ...
                'Color', [0.94, 0.40, 0.34], 'LineWidth', 1.5);
            plot3(ax, [0, 0], [-extent, extent], [0, 0], ...
                'Color', [0.32, 0.78, 0.52], 'LineWidth', 1.5);
            plot3(ax, [0, 0], [0, 0], [-extent, extent], ...
                'Color', [0.38, 0.64, 0.95], 'LineWidth', 1.5);
            scatter3(ax, 0, 0, 0, 34, [0.92, 0.91, 0.85], 'filled', ...
                'HandleVisibility', 'off');

            labels = {'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'};
            signs = [1, 1, 1; -1, 1, 1; -1, -1, 1; 1, -1, 1; ...
                     1, 1, -1; -1, 1, -1; -1, -1, -1; 1, -1, -1];
            for index = 1:numel(labels)
                position = signs(index, :) * (0.62 * extent);
                handleIndex = handleIndex + 1;
                handles{handleIndex} = text(ax, position(1), position(2), position(3), ...
                    ['OCTANT ', labels{index}], 'Color', [0.70, 0.74, 0.77], ...
                    'FontSize', 9, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center', 'HandleVisibility', 'off');
            end
            handles = handles(1:handleIndex);

            xlabel(ax, 'X', 'Color', [0.94, 0.40, 0.34]);
            ylabel(ax, 'Y', 'Color', [0.32, 0.78, 0.52]);
            zlabel(ax, 'Z', 'Color', [0.38, 0.64, 0.95]);
            xlim(ax, [-extent, extent]);
            ylim(ax, [-extent, extent]);
            zlim(ax, [-extent, extent]);
            axis(ax, 'equal');
            grid(ax, 'on');
            box(ax, 'on');
            ax.Color = [0.075, 0.09, 0.105];
            ax.XColor = [0.72, 0.76, 0.78];
            ax.YColor = [0.72, 0.76, 0.78];
            ax.ZColor = [0.72, 0.76, 0.78];
            ax.GridColor = [0.36, 0.40, 0.42];
            ax.GridAlpha = 0.28;
            view(ax, 38, 24);
        end
    end
end