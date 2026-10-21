classdef MotionModel
    %MOTIONMODEL Configurable periodic illustrative motion in Cartesian space.
    methods (Static)
        function [positions, velocities] = evaluate(initialPositions, time, amplitudes, angularFrequency)
            validateattributes(initialPositions, {'numeric'}, ...
                {'real', 'finite', '2d', 'ncols', 3}, mfilename, 'initialPositions');
            validateattributes(time, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'nonnegative'}, mfilename, 'time');
            validateattributes(amplitudes, {'numeric'}, ...
                {'real', 'finite', 'size', size(initialPositions)}, mfilename, 'amplitudes');
            validateattributes(angularFrequency, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive'}, mfilename, 'angularFrequency');

            phase = angularFrequency * time;
            positions = initialPositions .* cos(phase) + amplitudes .* sin(phase);
            velocities = angularFrequency .* ...
                (-initialPositions .* sin(phase) + amplitudes .* cos(phase));
        end
    end
end