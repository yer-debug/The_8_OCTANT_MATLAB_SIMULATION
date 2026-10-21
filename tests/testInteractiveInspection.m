function tests = testInteractiveInspection
tests = functiontests(localfunctions);
end

function testPresetSelectionAndCustomEditing(testCase)
previousVisibility = get(groot, 'defaultFigureVisible');
set(groot, 'defaultFigureVisible', 'off');
main();
window = findall(groot, 'Type', 'figure', 'Name', 'Octant & Vector Dynamics');
cleanup = onCleanup(@() closeTestWindow(window, previousVisibility));

selectors = findall(window, 'Style', 'popupmenu');
selector = selectors(arrayfun(@(control) ...
    any(contains(control.String, 'SAT-01')), selectors));
coordinateFields = findall(window, 'Style', 'edit');
textControls = findall(window, 'Style', 'text', 'FontName', 'FixedWidth');
inspector = textControls(arrayfun(@isInspectorControl, textControls));
verifyEqual(testCase, numel(selector), 1);
verifyEqual(testCase, numel(coordinateFields), 3);
verifyEqual(testCase, numel(inspector), 1);

selector.Value = 4;
selector.Callback(selector, []);
selectedCoordinates = cellfun(@(value) str2double(value), ...
    get(coordinateFields, 'String'));
verifyTrue(testCase, all(ismember([-3, -4, 5], selectedCoordinates)));
verifyEqual(testCase, selector.Value, 4);
inspectorText = joinInspectorText(inspector.String);
verifyTrue(testCase, any(contains(inspectorText, 'OCTANT III')));

coordinateFields(1).String = '9';
coordinateFields(1).Callback(coordinateFields(1), []);
verifyEqual(testCase, selector.Value, 1);
inspectorText = joinInspectorText(inspector.String);
verifyTrue(testCase, any(contains(inspectorText, '+9.000')));
end

function result = isInspectorControl(control)
value = control.String;
if iscell(value)
    value = value{1};
end
result = ischar(value) && size(value, 1) > 1 && ...
    strncmp(strtrim(value(1, :)), 'OBJECT:', 7);
end

function text = joinInspectorText(value)
if iscell(value)
    text = value;
else
    text = cellstr(value);
end
end

function closeTestWindow(window, previousVisibility)
if ~isempty(window) && isgraphics(window)
    close(window);
end
set(groot, 'defaultFigureVisible', previousVisibility);
end