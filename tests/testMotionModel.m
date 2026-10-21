function tests = testMotionModel
tests = functiontests(localfunctions);
end

function testInitialStateAndAnalyticVelocity(testCase)
config = simulationConfig();
[positions, velocities] = MotionModel.evaluate(config.inspectionPoints, 0, ...
    config.motionAmplitudes, config.motionAngularFrequency);
verifyEqual(testCase, positions, config.inspectionPoints, 'AbsTol', 1e-12);
verifyEqual(testCase, velocities, ...
    config.motionAngularFrequency .* config.motionAmplitudes, 'AbsTol', 1e-12);

sampleTime = 0.73;
delta = 1e-6;
before = MotionModel.evaluate(config.inspectionPoints, sampleTime - delta, ...
    config.motionAmplitudes, config.motionAngularFrequency);
after = MotionModel.evaluate(config.inspectionPoints, sampleTime + delta, ...
    config.motionAmplitudes, config.motionAngularFrequency);
[~, analyticVelocity] = MotionModel.evaluate(config.inspectionPoints, sampleTime, ...
    config.motionAmplitudes, config.motionAngularFrequency);
finiteDifference = (after - before) ./ (2 * delta);
verifyEqual(testCase, analyticVelocity, finiteDifference, 'AbsTol', 1e-8);
end

function testMotionCrossesOctantBoundaries(testCase)
config = simulationConfig();
time = 3 * pi / (2 * config.motionAngularFrequency);
positions = MotionModel.evaluate(config.inspectionPoints, time, ...
    config.motionAmplitudes, config.motionAngularFrequency);
verifyEqual(testCase, sign(positions), -sign(config.inspectionPoints));
for index = 1:size(positions, 1)
    [initialOctant, ~, initialBoundary] = ...
        OctantClassifier.classify(config.inspectionPoints(index, :));
    [currentOctant, ~, currentBoundary] = OctantClassifier.classify(positions(index, :));
    verifyFalse(testCase, initialBoundary || currentBoundary);
    verifyNotEqual(testCase, currentOctant, initialOctant);
end
verifyTrue(testCase, all(isfinite(positions), 'all'));
end

function testTrajectorySamplesEndAtCurrentPosition(testCase)
config = simulationConfig();
time = 2.4;
trails = TrajectoryEngine.sample(config.inspectionPoints, time, ...
    config.trailDuration, config.trailSamples, config.motionAmplitudes, ...
    config.motionAngularFrequency);
positions = MotionModel.evaluate(config.inspectionPoints, time, ...
    config.motionAmplitudes, config.motionAngularFrequency);
verifyEqual(testCase, size(trails), ...
    [config.trailSamples, 3, size(config.inspectionPoints, 1)]);
verifyEqual(testCase, squeeze(trails(end, :, :))', positions, 'AbsTol', 1e-12);
startTime = max(0, time - config.trailDuration);
startPositions = MotionModel.evaluate(config.inspectionPoints, startTime, ...
    config.motionAmplitudes, config.motionAngularFrequency);
verifyEqual(testCase, squeeze(trails(1, :, :))', startPositions, 'AbsTol', 1e-12);
end

function testClockStepSpeedAndReset(testCase)
callbackFigure = figure('Visible', 'off');
cleanup = onCleanup(@() close(callbackFigure));
setappdata(callbackFigure, 'lastTick', NaN);
clock = SimulationClock(0.1, ...
    @(time) setappdata(callbackFigure, 'lastTick', time));
clockCleanup = onCleanup(@() delete(clock));

clock.setSpeed(2);
clock.step();
verifyEqual(testCase, clock.Time, 0.2, 'AbsTol', 1e-12);
verifyEqual(testCase, getappdata(callbackFigure, 'lastTick'), 0.2, 'AbsTol', 1e-12);
clock.step();
verifyEqual(testCase, clock.Time, 0.4, 'AbsTol', 1e-12);
clock.reset();
verifyEqual(testCase, clock.Time, 0);
verifyFalse(testCase, clock.IsRunning);
verifyEqual(testCase, getappdata(callbackFigure, 'lastTick'), 0);
end

function testSceneUpdatesSatelliteAndVelocityGraphics(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
cleanup = onCleanup(@() set(groot, 'defaultFigureVisible', previousVisibility));
config = simulationConfig();
figureHandle = figure('Visible', 'off');
figureCleanup = onCleanup(@() close(figureHandle));
axesHandle = axes('Parent', figureHandle);
scene = SceneManager(axesHandle, config.extent, config);
scene.setInspectionPoints(config.inspectionPoints, config.satelliteTrails);

time = 0.8;
[positions, velocities] = MotionModel.evaluate(config.inspectionPoints, time, ...
    config.motionAmplitudes, config.motionAngularFrequency);
trails = TrajectoryEngine.sample(config.inspectionPoints, time, ...
    config.trailDuration, config.trailSamples, config.motionAmplitudes, ...
    config.motionAngularFrequency);
scene.updateSatelliteState(positions, velocities, trails);
markers = findall(axesHandle, 'Type', 'scatter');
satelliteMarkers = markers(arrayfun(@(marker) marker.SizeData == 48, markers));
verifyEqual(testCase, numel(satelliteMarkers), 8);
markerX = arrayfun(@(marker) marker.XData, satelliteMarkers);
expectedX = positions(:, 1);
verifyEqual(testCase, sort(markerX(:)), sort(expectedX(:)));
arrows = findall(axesHandle, 'Type', 'quiver');
verifyEqual(testCase, numel(arrows), 8);
verifyTrue(testCase, all(isfinite([arrows.UData])));
scene.setVelocitiesVisible(false);
verifyTrue(testCase, all(strcmp(get(arrows, 'Visible'), 'off')));
end

function testDashboardExposesPlaybackControls(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
main();
window = findall(groot, 'Type', 'figure', 'Name', 'Octant & Vector Dynamics');
cleanup = onCleanup(@() closeDashboard(window, previousVisibility));
buttons = findall(window, 'Style', 'pushbutton');
buttonLabels = get(buttons, 'String');
verifyTrue(testCase, all(ismember({'Play'; 'Pause'; 'Reset'; 'Step'}, buttonLabels)));
verifyEqual(testCase, numel(findall(window, 'Style', 'slider')), 1);
end

function testRejectsInvalidMotionInputs(testCase)
config = simulationConfig();
verifyError(testCase, @() MotionModel.evaluate(config.inspectionPoints, -1, ...
    config.motionAmplitudes, config.motionAngularFrequency), ...
    'MATLAB:MotionModel:expectedNonnegative');
verifyError(testCase, @() TrajectoryEngine.sample(config.inspectionPoints, 1, ...
    config.trailDuration, 1, config.motionAmplitudes, ...
    config.motionAngularFrequency), 'MATLAB:TrajectoryEngine:notGreaterEqual');

clock = SimulationClock(0.1, @(~) []);
cleanup = onCleanup(@() delete(clock));
verifyError(testCase, @() clock.setSpeed(0), ...
    'MATLAB:SimulationClock:expectedPositive');
end

function closeDashboard(window, previousVisibility)
if ~isempty(window) && isgraphics(window)
    close(window);
end
set(groot, 'defaultFigureVisible', previousVisibility);
end