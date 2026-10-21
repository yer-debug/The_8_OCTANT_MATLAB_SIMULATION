function tests = testDashboardControls
tests = functiontests(localfunctions);
end

function testVisibilityControlsAndCameraModes(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
main();
window = findall(groot, 'Type', 'figure', 'Name', 'Octant & Vector Dynamics');
cleanup = onCleanup(@() closeDashboard(window, previousVisibility));

axesHandle = findall(window, 'Type', 'axes');
checkboxes = findall(window, 'Style', 'checkbox');
boundaryToggle = findControl(checkboxes, 'Octant boundaries');
positionToggle = findControl(checkboxes, 'Position vector');
componentToggle = findControl(checkboxes, 'Vector components');
trailToggle = findControl(checkboxes, 'Satellite trails');
velocityToggle = findControl(checkboxes, 'Velocity vectors');

boundaryToggle.Value = 0;
boundaryToggle.Callback(boundaryToggle, []);
surfaces = findall(axesHandle, 'Type', 'surface');
verifyTrue(testCase, all(strcmp(get(surfaces, 'Visible'), 'off')));
boundaryToggle.Value = 1;
boundaryToggle.Callback(boundaryToggle, []);
verifyTrue(testCase, all(strcmp(get(surfaces, 'Visible'), 'on')));

positionToggle.Value = 0;
positionToggle.Callback(positionToggle, []);
config = simulationConfig();
quivers = findall(axesHandle, 'Type', 'quiver');
positionArrows = quivers(arrayfun(@(arrow) isequal(arrow.Color, config.vectorColor), quivers));
verifyGreaterThanOrEqual(testCase, numel(positionArrows), 1);
verifyTrue(testCase, all(strcmp(get(positionArrows, 'Visible'), 'off')));
positionToggle.Value = 1;
positionToggle.Callback(positionToggle, []);
quivers = findall(axesHandle, 'Type', 'quiver');
positionArrows = quivers(arrayfun(@(arrow) isequal(arrow.Color, config.vectorColor), quivers));
verifyTrue(testCase, all(strcmp(get(positionArrows, 'Visible'), 'on')));

componentToggle.Value = 0;
componentToggle.Callback(componentToggle, []);
componentLines = findall(axesHandle, 'Type', 'line', 'LineStyle', '--');
verifyEmpty(testCase, componentLines);

trailToggle.Value = 0;
trailToggle.Callback(trailToggle, []);
trails = findall(axesHandle, 'Type', 'line', 'LineStyle', ':');
verifyTrue(testCase, all(strcmp(get(trails, 'Visible'), 'off')));
velocityToggle.Value = 0;
velocityToggle.Callback(velocityToggle, []);
quivers = findall(axesHandle, 'Type', 'quiver');
velocityArrows = quivers(arrayfun(@(arrow) isequal(arrow.Color, config.velocityColor), quivers));
verifyFalse(testCase, any(strcmp(get(velocityArrows, 'Visible'), 'on')));

selectors = findall(window, 'Style', 'popupmenu');
cameraSelector = findControl(selectors, 'Selected octant');
cameraSelector.Value = 2;
cameraSelector.Callback(cameraSelector, []);
focusedXLimits = axesHandle.XLim;
verifyLessThan(testCase, diff(focusedXLimits), 16);
cameraSelector.Value = 1;
cameraSelector.Callback(cameraSelector, []);
verifyEqual(testCase, axesHandle.XLim, [-8, 8], 'AbsTol', 1e-12);
end

function control = findControl(controls, expectedText)
control = controls(arrayfun(@(candidate) ...
    any(strcmp(candidate.String, expectedText)), controls));
end

function closeDashboard(window, previousVisibility)
if ~isempty(window) && isgraphics(window)
    close(window);
end
set(groot, 'defaultFigureVisible', previousVisibility);
end