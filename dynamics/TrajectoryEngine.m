classdef TrajectoryEngine
    %TRAJECTORYENGINE Sample an illustrative model over a recent time window.
    methods (Static)
        function trails = sample(initialPositions, time, duration, sampleCount, ...
                amplitudes, angularFrequency)
            validateattributes(duration, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive'}, mfilename, 'duration');
            validateattributes(sampleCount, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'integer', '>=', 2}, ...
                mfilename, 'sampleCount');
            sampleTimes = linspace(max(0, time - duration), time, sampleCount);
            trails = zeros(sampleCount, 3, size(initialPositions, 1));
            for sampleIndex = 1:sampleCount
                positions = MotionModel.evaluate(initialPositions, ...
                    sampleTimes(sampleIndex), amplitudes, angularFrequency);
                trails(sampleIndex, :, :) = reshape(positions.', 1, 3, []);
            end
        end
    end
end