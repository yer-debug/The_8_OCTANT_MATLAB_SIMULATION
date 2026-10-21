function tests = testFieldModels
tests = functiontests(localfunctions);
end

function testPointChargeFieldDirectionAndMagnitude(testCase)
epsilon0 = 8.8541878128e-12;
radius = 2.5;
[field, defined] = ElectricFieldModel.evaluate([radius, 0, 0], 3e-9, epsilon0);
expectedMagnitude = 3e-9 / (4 * pi * epsilon0 * radius^2);
verifyTrue(testCase, defined);
verifyEqual(testCase, field, [expectedMagnitude, 0, 0], ...
    'RelTol', 1e-12);

negativeField = ElectricFieldModel.evaluate([0, 0, -radius], -3e-9, epsilon0);
verifyGreaterThan(testCase, negativeField(3), 0);
end

function testPointChargeSingularityAndZeroCharge(testCase)
[singularField, defined] = ElectricFieldModel.evaluate([0, 0, 0], 1e-6, 8.854e-12);
verifyFalse(testCase, defined);
verifyTrue(testCase, all(isnan(singularField)));
[zeroField, defined] = ElectricFieldModel.evaluate([2, -1, 5], 0, 8.854e-12);
verifyTrue(testCase, defined);
verifyEqual(testCase, zeroField, [0, 0, 0]);
end

function testInfiniteWireRightHandRuleAndAxisSingularity(testCase)
mu0 = 4 * pi * 1e-7;
[field, defined] = MagneticFieldModel.evaluate([0.5, 0, 4], 2, mu0);
verifyTrue(testCase, defined);
verifyEqual(testCase, field, [0, mu0 * 2 / (2 * pi * 0.5), 0], ...
    'RelTol', 1e-12);
[singularField, defined] = MagneticFieldModel.evaluate([0, 0, -10], 2, mu0);
verifyFalse(testCase, defined);
verifyTrue(testCase, all(isnan(singularField)));
end

function testBatchEngineConvertsKmAndFlagsSingularities(testCase)
config = simulationConfig();
positionsKm = [1, 0, 0; 0, 2, 0; 0, 0, 0];
positionsMeters = positionsKm .* config.positionScaleToMeters;
[fields, defined] = FieldVectorEngine.evaluate('Electric', positionsMeters, config);
verifyEqual(testCase, defined, [true; true; false]);
verifyTrue(testCase, fields(1, 1) > 0);
verifyTrue(testCase, fields(2, 2) > 0);
verifyTrue(testCase, all(isnan(fields(3, :))));

[offFields, offDefined] = FieldVectorEngine.evaluate('Off', positionsMeters, config);
verifyFalse(testCase, any(offDefined));
verifyTrue(testCase, all(isnan(offFields), 'all'));
verifyError(testCase, @() FieldVectorEngine.evaluate('unknown', positionsMeters, config), ...
    'MATLAB:FieldVectorEngine:invalidMode');
end

function testFieldRendererSkipsUndefinedPoints(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
cleanup = onCleanup(@() set(groot, 'defaultFigureVisible', previousVisibility));
figureHandle = figure('Visible', 'off');
figureCleanup = onCleanup(@() close(figureHandle));
axesHandle = axes('Parent', figureHandle);
handles = FieldRenderer.draw(axesHandle, [0, 0, 0; 1, 0, 0], ...
    [NaN, NaN, NaN; 1, 0, 0], [false; true], [1, 0, 0], 1);
verifyEqual(testCase, numel(handles), 1);
verifyEqual(testCase, numel(findall(axesHandle, 'Type', 'quiver')), 1);
end

function testModelsRejectInvalidInputs(testCase)
verifyError(testCase, @() ElectricFieldModel.evaluate([1, 2], 1, 8.854e-12), ...
    'MATLAB:ElectricFieldModel:incorrectNumel');
verifyError(testCase, @() ElectricFieldModel.evaluate([1, 0, 0], 1, 0), ...
    'MATLAB:ElectricFieldModel:expectedPositive');
verifyError(testCase, @() MagneticFieldModel.evaluate([1, 0, 0], 1, -1), ...
    'MATLAB:MagneticFieldModel:expectedPositive');
end

function testDashboardProvidesFieldModeAndInspector(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
main();
window = findall(groot, 'Type', 'figure', 'Name', 'Octant & Vector Dynamics');
cleanup = onCleanup(@() closeDashboard(window, previousVisibility));
selectors = findall(window, 'Style', 'popupmenu');
fieldSelector = selectors(arrayfun(@(control) ...
    any(contains(control.String, 'Point charge')), selectors));
fieldSelector.Value = 2;
fieldSelector.Callback(fieldSelector, []);
textControls = findall(window, 'Style', 'text', 'FontName', 'FixedWidth');
inspector = textControls(arrayfun(@isInspector, textControls));
lines = cellstr(inspector.String);
verifyTrue(testCase, any(contains(lines, 'ELECTRIC [SI]')));
end

function result = isInspector(control)
value = control.String;
if iscell(value)
    value = value{1};
end
result = ischar(value) && size(value, 1) > 1 && ...
    strncmp(strtrim(value(1, :)), 'OBJECT:', 7);
end

function closeDashboard(window, previousVisibility)
if ~isempty(window) && isgraphics(window)
    close(window);
end
set(groot, 'defaultFigureVisible', previousVisibility);
end