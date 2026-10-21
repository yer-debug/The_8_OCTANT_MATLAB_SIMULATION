classdef SimulationClock < handle
    %SIMULATIONCLOCK Timer-backed clock with deterministic manual stepping.
    properties (SetAccess = private)
        Time = 0
        Speed = 1
        IsRunning = false
    end

    properties (Access = private)
        StepSize
        TickFunction
        TimerHandle = []
    end

    methods
        function obj = SimulationClock(stepSize, tickFunction)
            validateattributes(stepSize, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive'}, mfilename, 'stepSize');
            if ~isa(tickFunction, 'function_handle')
                error('MATLAB:SimulationClock:invalidCallback', ...
                    'tickFunction must be a function handle.');
            end
            obj.StepSize = stepSize;
            obj.TickFunction = tickFunction;
        end

        function start(obj)
            if obj.IsRunning
                return;
            end
            if isempty(obj.TimerHandle) || ~isvalid(obj.TimerHandle)
                obj.TimerHandle = timer('ExecutionMode', 'fixedRate', ...
                    'Period', obj.StepSize, 'BusyMode', 'drop', ...
                    'TimerFcn', @(~, ~) obj.onTimer());
            end
            start(obj.TimerHandle);
            obj.IsRunning = true;
        end

        function pause(obj)
            if ~isempty(obj.TimerHandle) && isvalid(obj.TimerHandle) && ...
                    strcmp(obj.TimerHandle.Running, 'on')
                stop(obj.TimerHandle);
            end
            obj.IsRunning = false;
        end

        function step(obj)
            obj.advance();
        end

        function reset(obj)
            obj.pause();
            obj.Time = 0;
            obj.TickFunction(obj.Time);
        end

        function setSpeed(obj, speed)
            validateattributes(speed, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'positive', '<=', 8}, ...
                mfilename, 'speed');
            obj.Speed = speed;
        end

        function delete(obj)
            obj.pause();
            if ~isempty(obj.TimerHandle) && isvalid(obj.TimerHandle)
                delete(obj.TimerHandle);
            end
        end
    end

    methods (Access = private)
        function onTimer(obj)
            obj.advance();
        end

        function advance(obj)
            obj.Time = obj.Time + obj.StepSize * obj.Speed;
            obj.TickFunction(obj.Time);
        end
    end
end