function main()
%MAIN Launch the interactive 3D octant and vector demonstration.
projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));
config = simulationConfig();

window = figure('Name', 'Octant & Vector Dynamics', 'NumberTitle', 'off', ...
    'Color', [0.075, 0.09, 0.105], 'Position', [100, 100, 1120, 720]);
plotAxes = axes('Parent', window, 'Units', 'normalized', ...
    'Position', [0.045, 0.30, 0.64, 0.64]);
scene = SceneManager(plotAxes, config.extent, config);
scene.setInspectionPoints(config.inspectionPoints, config.satelliteTrails);

panel = uipanel('Parent', window, 'Units', 'normalized', ...
    'Position', [0.72, 0.08, 0.25, 0.86], 'Title', 'VECTOR INSPECTOR', ...
    'ForegroundColor', [0.87, 0.89, 0.86], 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'FontWeight', 'bold');
uicontrol(panel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.08, 0.88, 0.84, 0.045], 'String', 'VECTOR COMPONENTS  [Vx, Vy, Vz]', ...
    'BackgroundColor', [0.11, 0.13, 0.14], 'ForegroundColor', [0.68, 0.75, 0.74], ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold');

coordinateFields = gobjects(1, 3);
axisNames = {'Vx', 'Vy', 'Vz'};
for index = 1:3
    yPosition = 0.81 - (index - 1) * 0.065;
    uicontrol(panel, 'Style', 'text', 'Units', 'normalized', ...
        'Position', [0.08, yPosition, 0.16, 0.05], 'String', axisNames{index}, ...
        'BackgroundColor', [0.11, 0.13, 0.14], ...
        'ForegroundColor', [0.85, 0.87, 0.83], 'HorizontalAlignment', 'left');
    coordinateFields(index) = uicontrol(panel, 'Style', 'edit', ...
        'Units', 'normalized', 'Position', [0.28, yPosition, 0.63, 0.052], ...
        'String', num2str(config.initialPoint(index)), 'BackgroundColor', [0.18, 0.21, 0.22], ...
        'ForegroundColor', [0.96, 0.94, 0.88], 'Callback', @editCoordinate);
end

uicontrol(panel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.08, 0.59, 0.84, 0.04], 'String', 'SELECT SATELLITE', ...
    'BackgroundColor', [0.11, 0.13, 0.14], 'ForegroundColor', [0.68, 0.75, 0.74], ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold');
selectionItems = [{'Custom point'}; strcat(config.satelliteIds(:), ...
    {'  |  '}, config.octantNames)];
selection = uicontrol(panel, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.08, 0.54, 0.84, 0.05], 'String', selectionItems, ...
    'Value', find(all(config.inspectionPoints == config.initialPoint, 2), 1) + 1, ...
    'BackgroundColor', [0.18, 0.21, 0.22], ...
    'ForegroundColor', [0.96, 0.94, 0.88], 'Callback', @selectPoint);
componentsToggle = uicontrol(panel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.08, 0.47, 0.84, 0.045], 'String', 'Vector components', ...
    'Value', 1, 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'ForegroundColor', [0.88, 0.89, 0.84], 'Callback', @updateScene);
boundariesToggle = uicontrol(panel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.08, 0.425, 0.84, 0.045], 'String', 'Octant boundaries', ...
    'Value', 1, 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'ForegroundColor', [0.88, 0.89, 0.84], 'Callback', @updateBoundaries);
scene.setBoundariesVisible(logical(boundariesToggle.Value));
positionToggle = uicontrol(panel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.08, 0.38, 0.84, 0.045], 'String', 'Position vector', ...
    'Value', 1, 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'ForegroundColor', [0.88, 0.89, 0.84], 'Callback', @updatePositionVisibility);
scene.setPositionVectorVisible(logical(positionToggle.Value));
trailsToggle = uicontrol(panel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.08, 0.335, 0.84, 0.045], 'String', 'Satellite trails', ...
    'Value', 1, 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'ForegroundColor', [0.88, 0.89, 0.84], 'Callback', @updateTrails);
scene.setTrailsVisible(logical(trailsToggle.Value));
velocityToggle = uicontrol(panel, 'Style', 'checkbox', 'Units', 'normalized', ...
    'Position', [0.08, 0.29, 0.84, 0.045], 'String', 'Velocity vectors', ...
    'Value', 1, 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'ForegroundColor', [0.88, 0.89, 0.84], 'Callback', @updateVelocities);
scene.setVelocitiesVisible(logical(velocityToggle.Value));
uicontrol(panel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.08, 0.24, 0.84, 0.035], 'String', 'FIELD MODEL', ...
    'BackgroundColor', [0.11, 0.13, 0.14], 'ForegroundColor', [0.68, 0.75, 0.74], ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold');
fieldSelector = uicontrol(panel, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.08, 0.195, 0.84, 0.045], ...
    'String', {'Off', 'Point charge: electric field', 'Infinite +Z wire: magnetic field'}, ...
    'Value', 1, 'BackgroundColor', [0.18, 0.21, 0.22], ...
    'ForegroundColor', [0.96, 0.94, 0.88], 'Callback', @updateSimulationNow);
uicontrol(panel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.08, 0.125, 0.84, 0.035], 'String', 'CAMERA VIEW', ...
    'BackgroundColor', [0.11, 0.13, 0.14], 'ForegroundColor', [0.68, 0.75, 0.74], ...
    'HorizontalAlignment', 'left', 'FontWeight', 'bold');
uicontrol(panel, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.08, 0.075, 0.84, 0.05], ...
    'String', {'Global view', 'Selected octant'}, 'Value', 1, ...
    'BackgroundColor', [0.18, 0.21, 0.22], ...
    'ForegroundColor', [0.96, 0.94, 0.88], 'Callback', @updateCamera);
dataPanel = uipanel('Parent', window, 'Units', 'normalized', ...
    'Position', [0.045, 0.13, 0.64, 0.14], 'Title', 'SELECTED OBJECT DATA', ...
    'ForegroundColor', [0.87, 0.89, 0.86], 'BackgroundColor', [0.11, 0.13, 0.14], ...
    'FontWeight', 'bold');
inspector = uicontrol(dataPanel, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.02, 0.04, 0.96, 0.78], 'String', '', ...
    'BackgroundColor', [0.11, 0.13, 0.14], 'ForegroundColor', [0.91, 0.92, 0.87], ...
    'HorizontalAlignment', 'left', 'FontName', 'FixedWidth', 'FontSize', 9);

uicontrol(window, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.045, 0.035, 0.08, 0.065], 'String', 'Play', ...
    'Callback', @playSimulation);
uicontrol(window, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.135, 0.035, 0.08, 0.065], 'String', 'Pause', ...
    'Callback', @pauseSimulation);
uicontrol(window, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.225, 0.035, 0.08, 0.065], 'String', 'Reset', ...
    'Callback', @resetSimulation);
uicontrol(window, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.315, 0.035, 0.08, 0.065], 'String', 'Step', ...
    'Callback', @stepSimulation);
uicontrol(window, 'Style', 'slider', 'Units', 'normalized', ...
    'Position', [0.43, 0.045, 0.15, 0.04], 'Min', 0.25, 'Max', 4, ...
    'Value', 1, 'SliderStep', [0.05, 0.25], 'Callback', @changeSpeed);
speedLabel = uicontrol(window, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.59, 0.035, 0.08, 0.06], 'String', '1.00x', ...
    'BackgroundColor', [0.075, 0.09, 0.105], 'ForegroundColor', [0.91, 0.92, 0.87], ...
    'FontName', 'FixedWidth', 'FontSize', 10);
timeLabel = uicontrol(window, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.67, 0.035, 0.08, 0.06], 'String', 't = 0.00 s', ...
    'BackgroundColor', [0.075, 0.09, 0.105], 'ForegroundColor', [0.91, 0.92, 0.87], ...
    'FontName', 'FixedWidth', 'FontSize', 9);
clock = SimulationClock(config.clockStep, @updateSimulation);
window.CloseRequestFcn = @closeDashboard;

initialTrails = TrajectoryEngine.sample(config.inspectionPoints, 0, ...
    config.trailDuration, config.trailSamples, config.motionAmplitudes, ...
    config.motionAngularFrequency);
[currentPositions, currentVelocities] = MotionModel.evaluate( ...
    config.inspectionPoints, 0, config.motionAmplitudes, ...
    config.motionAngularFrequency);
scene.updateSatelliteState(currentPositions, currentVelocities, initialTrails);
updateScene([], []);

    function updateScene(~, ~)
        point = zeros(1, 3);
        for fieldIndex = 1:3
            point(fieldIndex) = str2double(coordinateFields(fieldIndex).String);
        end
        if any(~isfinite(point))
            set(inspector, 'String', 'Enter a finite number for each coordinate.');
            return;
        end

        scene.update(point, logical(componentsToggle.Value));
        [octant, signText, isBoundary] = OctantClassifier.classify(point);
        pointMagnitude = VectorEngine.magnitude(point);
        if pointMagnitude == 0
            directionText = 'undefined at origin';
        else
            angles = VectorEngine.directionAngles(point);
            directionText = sprintf('(%5.1f, %5.1f, %5.1f) deg', angles);
        end
        if isBoundary
            locationText = 'BOUNDARY';
        else
            locationText = upper(octant);
        end
        selectedSatellite = selection.Value - 1;
        if selectedSatellite > 0
            objectText = config.satelliteIds{selectedSatellite};
            selectedVelocity = currentVelocities(selectedSatellite, :);
            velocityDetails = sprintf(['VELOCITY\nVx: %+8.3f\nVy: %+8.3f\nVz: %+8.3f\n' ...
                'Speed: %.4f'], selectedVelocity(1), selectedVelocity(2), ...
                selectedVelocity(3), VectorEngine.magnitude(selectedVelocity));
        else
            objectText = 'CUSTOM POINT';
            velocityDetails = 'VELOCITY\nnot defined for custom point';
        end
        fieldDetails = selectedFieldDetails(point, selectedSatellite);
        details = sprintf(['OBJECT: %s | t=%.2f s\nPOS [km] X:%+.3f Y:%+.3f Z:%+.3f\n' ...
            'REGION: %s %s | |r|=%.3f km\nDIR: %s\n%s\n%s'], ...
            objectText, clock.Time, point(1), point(2), point(3), ...
            locationText, signText, pointMagnitude, directionText, velocityDetails, fieldDetails);
        set(inspector, 'String', details);
    end

    function selectPoint(source, ~)
        selectedValue = source.Value;
        if selectedValue == 1
            scene.selectInspectionPoint(0);
            return;
        end
        pointIndex = selectedValue - 1;
        point = currentPositions(pointIndex, :);
        for fieldIndex = 1:3
            coordinateFields(fieldIndex).String = num2str(point(fieldIndex));
        end
        scene.selectInspectionPoint(pointIndex);
        updateScene([], []);
        scene.selectInspectionPoint(pointIndex);
    end

    function updateTrails(source, ~)
        scene.setTrailsVisible(logical(source.Value));
    end

    function updateBoundaries(source, ~)
        scene.setBoundariesVisible(logical(source.Value));
    end

    function updatePositionVisibility(source, ~)
        scene.setPositionVectorVisible(logical(source.Value));
    end

    function updateCamera(source, ~)
        if source.Value == 1
            scene.setCameraMode('Global', currentPositions(1, :));
        else
            selectedSatellite = selection.Value - 1;
            if selectedSatellite > 0
                cameraPoint = currentPositions(selectedSatellite, :);
            else
                cameraPoint = [str2double(coordinateFields(1).String), ...
                    str2double(coordinateFields(2).String), ...
                    str2double(coordinateFields(3).String)];
            end
            scene.setCameraMode('Octant', cameraPoint);
        end
    end

    function editCoordinate(~, ~)
        selection.Value = 1;
        scene.selectInspectionPoint(0);
        updateScene([], []);
    end

    function updateVelocities(source, ~)
        scene.setVelocitiesVisible(logical(source.Value));
    end

    function updateSimulation(time)
        [currentPositions, currentVelocities] = MotionModel.evaluate( ...
            config.inspectionPoints, time, config.motionAmplitudes, ...
            config.motionAngularFrequency);
        currentTrails = TrajectoryEngine.sample(config.inspectionPoints, time, ...
            config.trailDuration, config.trailSamples, config.motionAmplitudes, ...
            config.motionAngularFrequency);
        scene.updateSatelliteState(currentPositions, currentVelocities, currentTrails);
        updateFields();
        timeLabel.String = sprintf('t = %.2f s', time);
        selectedSatellite = selection.Value - 1;
        if selectedSatellite > 0
            point = currentPositions(selectedSatellite, :);
            for fieldIndex = 1:3
                coordinateFields(fieldIndex).String = sprintf('%.4f', point(fieldIndex));
            end
            scene.selectInspectionPoint(selectedSatellite);
        end
        updateScene([], []);
    end

    function playSimulation(~, ~)
        clock.start();
    end

    function pauseSimulation(~, ~)
        clock.pause();
    end

    function resetSimulation(~, ~)
        clock.reset();
        scene.selectInspectionPoint(max(0, selection.Value - 1));
    end

    function stepSimulation(~, ~)
        clock.step();
    end

    function changeSpeed(source, ~)
        clock.setSpeed(source.Value);
        speedLabel.String = sprintf('%.2fx', source.Value);
    end

    function closeDashboard(source, ~)
        delete(clock);
        delete(source);
    end

    function updateSimulationNow(~, ~)
        updateSimulation(clock.Time);
    end

    function updateFields()
        mode = fieldModeName(fieldSelector.Value);
        if strcmp(mode, 'Off')
            scene.clearFieldVectors();
            return;
        end
        positionsMeters = currentPositions .* config.positionScaleToMeters;
        [fieldValues, defined] = FieldVectorEngine.evaluate(mode, positionsMeters, config);
        if strcmp(mode, 'Electric')
            color = config.electricFieldColor;
        else
            color = config.magneticFieldColor;
        end
        scene.updateFieldVectors(currentPositions, fieldValues, defined, color);
    end

    function details = selectedFieldDetails(point, selectedSatellite)
        mode = fieldModeName(fieldSelector.Value);
        if strcmp(mode, 'Off')
            details = 'FIELD: off';
            return;
        end
        if selectedSatellite > 0
            fieldPosition = currentPositions(selectedSatellite, :) .* ...
                config.positionScaleToMeters;
        else
            fieldPosition = point .* config.positionScaleToMeters;
        end
        [field, defined] = FieldVectorEngine.evaluate(mode, fieldPosition, config);
        if ~defined
            details = sprintf('%s FIELD: undefined at source', upper(mode));
            return;
        end
        magnitude = VectorEngine.magnitude(field);
        if strcmp(mode, 'Electric')
            units = 'N/C';
        else
            units = 'T';
        end
        details = sprintf('%s [SI] (%+.3g, %+.3g, %+.3g) %s | %.3g %s', ...
            upper(mode), field(1), field(2), field(3), units, magnitude, units);
    end

    function mode = fieldModeName(value)
        modes = {'Off', 'Electric', 'Magnetic'};
        mode = modes{value};
    end
end