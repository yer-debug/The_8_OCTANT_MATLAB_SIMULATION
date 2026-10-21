classdef OctantClassifier
    %OCTANTCLASSIFIER Classify points in Cartesian space by coordinate signs.
    methods (Static)
        function [octant, signText, isBoundary] = classify(point)
            validateattributes(point, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3}, mfilename, 'point');
            point = reshape(point, 1, 3);
            signs = repmat('0', 1, 3);
            signs(point > 0) = '+';
            signs(point < 0) = '-';
            signText = sprintf('(%c, %c, %c)', signs(1), signs(2), signs(3));

            isBoundary = any(point == 0);
            if isBoundary
                octant = 'Boundary';
                return;
            end

            patterns = ['+++'; '-++'; '--+'; '+-+'; ...
                        '++-'; '-+-'; '---'; '+--'];
            names = {'Octant I'; 'Octant II'; 'Octant III'; 'Octant IV'; ...
                     'Octant V'; 'Octant VI'; 'Octant VII'; 'Octant VIII'};
            octant = names{find(all(patterns == signs, 2), 1)};
        end
    end
end