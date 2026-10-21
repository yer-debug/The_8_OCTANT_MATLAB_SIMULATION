function tests = testSatelliteVisualization
tests = functiontests(localfunctions);
end

function testSatellitePositionsAndTrailsCoverAllOctants(testCase)
config = simulationConfig();
verifyEqual(testCase, size(config.inspectionPoints), [8, 3]);
verifyEqual(testCase, size(config.satelliteTrails, 2), 3);
verifyEqual(testCase, size(config.satelliteTrails, 3), 8);

for index = 1:8
    [~, ~, isBoundary] = OctantClassifier.classify(config.inspectionPoints(index, :));
    verifyFalse(testCase, isBoundary);
    trail = config.satelliteTrails(:, :, index);
    verifyEqual(testCase, trail(end, :), config.inspectionPoints(index, :), ...
        'AbsTol', 1e-12);
    verifyTrue(testCase, all(sign(trail) == sign(config.inspectionPoints(index, :)), 'all'));
end
end

function testSceneRendersSatellitesAndTogglesTrails(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
cleanup = onCleanup(@() set(groot, 'defaultFigureVisible', previousVisibility));
config = simulationConfig();
figureHandle = figure('Visible', 'off');
closeFigure = onCleanup(@() close(figureHandle));
axesHandle = axes('Parent', figureHandle);
scene = SceneManager(axesHandle, config.extent, config);
scene.setInspectionPoints(config.inspectionPoints, config.satelliteTrails);
scene.selectInspectionPoint(3);
verifyEqual(testCase, scene.SelectedInspectionPoint, 3);
verifyEqual(testCase, numel(findall(axesHandle, 'Type', 'scatter')), 9);

trailLines = findall(axesHandle, 'LineStyle', ':');
verifyEqual(testCase, numel(trailLines), 8);
scene.setTrailsVisible(false);
verifyTrue(testCase, all(strcmp(get(trailLines, 'Visible'), 'off')));
scene.setTrailsVisible(true);
verifyTrue(testCase, all(strcmp(get(trailLines, 'Visible'), 'on')));
end

function testDashboardExposesSatellitesAndTrailToggle(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
main();
window = findall(groot, 'Type', 'figure', 'Name', 'Octant & Vector Dynamics');
cleanup = onCleanup(@() closeDashboard(window, previousVisibility));

selectors = findall(window, 'Style', 'popupmenu');
selector = selectors(arrayfun(@(control) ...
    any(contains(control.String, 'SAT-01')), selectors));
checkboxes = findall(window, 'Style', 'checkbox');
items = selector.String;
verifyEqual(testCase, numel(items), 9);
verifyTrue(testCase, any(contains(items, 'SAT-01')));
verifyTrue(testCase, any(contains(items, 'SAT-08')));
checkboxLabels = arrayfun(@(control) string(control.String), checkboxes);
verifyTrue(testCase, any(contains(lower(checkboxLabels), 'satellite trails')));
end

function closeDashboard(window, previousVisibility)
if ~isempty(window) && isgraphics(window)
    close(window);
end
set(groot, 'defaultFigureVisible', previousVisibility);
end