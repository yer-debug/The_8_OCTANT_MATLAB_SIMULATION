classdef SceneManager < handle
    %SCENEMANAGER Own the static coordinate scene and update its point vector.
    properties (Access = private)
        Axes
        Extent
        Config
        BoundaryHandles = {}
        DynamicHandles = {}
        InspectionMarkers = {}
        InspectionLabels = {}
        TrailHandles = {}
        VelocityHandles = {}
        FieldHandles = {}
        ShowTrails = true
        ShowVelocities = true
        ShowPositionVector = true
    end

    properties (SetAccess = private)
        InspectionPoints = zeros(0, 3)
        SatelliteTrails = zeros(0, 3, 0)
        SelectedInspectionPoint = 0
        CameraMode = 'Global'
    end

    methods
        function obj = SceneManager(ax, extent, config)
            obj.Axes = ax;
            obj.Extent = extent;
            obj.Config = config;
            obj.BoundaryHandles = OctantRenderer.draw(ax, extent);
        end

        function update(obj, point, showComponents)
            validateattributes(point, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3});
            point = reshape(point, 1, 3);
            for index = 1:numel(obj.DynamicHandles)
                currentHandles = obj.DynamicHandles{index};
                currentHandles = currentHandles(isgraphics(currentHandles));
                if ~isempty(currentHandles)
                    delete(currentHandles);
                end
            end
            obj.DynamicHandles = VectorRenderer.draw( ...
                obj.Axes, point, showComponents, obj.Config);
            obj.setPositionVectorVisible(obj.ShowPositionVector);
            obj.setCameraMode(obj.CameraMode, point);
        end

        function setBoundariesVisible(obj, visible)
            validateattributes(visible, {'logical', 'numeric'}, ...
                {'scalar', 'finite'}, mfilename, 'visible');
            visible = logical(visible);
            for index = 1:numel(obj.BoundaryHandles)
                if isgraphics(obj.BoundaryHandles{index})
                    obj.BoundaryHandles{index}.Visible = ...
                        matlab.lang.OnOffSwitchState(visible);
                end
            end
        end

        function setPositionVectorVisible(obj, visible)
            validateattributes(visible, {'logical', 'numeric'}, ...
                {'scalar', 'finite'}, mfilename, 'visible');
            obj.ShowPositionVector = logical(visible);
            if ~isempty(obj.DynamicHandles) && isgraphics(obj.DynamicHandles{1})
                obj.DynamicHandles{1}.Visible = ...
                    matlab.lang.OnOffSwitchState(obj.ShowPositionVector);
            end
        end

        function setCameraMode(obj, mode, selectedPoint)
            if isstring(mode) && isscalar(mode)
                mode = char(mode);
            end
            if ~ischar(mode) || ~ismember(lower(mode), {'global', 'octant'})
                error('MATLAB:SceneManager:invalidCameraMode', ...
                    'Camera mode must be Global or Octant.');
            end
            obj.CameraMode = mode;
            if strcmpi(mode, 'Global')
                validateattributes(selectedPoint, {'numeric'}, ...
                    {'real', 'finite', 'vector', 'numel', 3}, ...
                    mfilename, 'selectedPoint');
                limit = max(obj.Extent, max(abs(selectedPoint)) * 1.15);
                xlim(obj.Axes, [-limit, limit]);
                ylim(obj.Axes, [-limit, limit]);
                zlim(obj.Axes, [-limit, limit]);
                view(obj.Axes, 38, 24);
                return;
            end

            validateattributes(selectedPoint, {'numeric'}, ...
                {'real', 'finite', 'vector', 'numel', 3}, mfilename, 'selectedPoint');
            selectedPoint = reshape(selectedPoint, 1, 3);
            span = max(2.5, max(abs(selectedPoint)) * 0.65);
            xlim(obj.Axes, selectedPoint(1) + [-span, span]);
            ylim(obj.Axes, selectedPoint(2) + [-span, span]);
            zlim(obj.Axes, selectedPoint(3) + [-span, span]);
            azimuth = 38 * sign(selectedPoint(1) * selectedPoint(2));
            if azimuth == 0
                azimuth = 38;
            end
            elevation = 24 * sign(selectedPoint(3));
            if elevation == 0
                elevation = 24;
            end
            view(obj.Axes, azimuth, elevation);
        end

        function setInspectionPoints(obj, points, trails)
            validateattributes(points, {'numeric'}, ...
                {'real', 'finite', '2d', 'ncols', 3}, mfilename, 'points');
            if nargin < 3
                trails = zeros(0, 3, size(points, 1));
            end
            validateattributes(trails, {'numeric'}, ...
                {'real', 'finite', '3d', 'ncols', 3}, mfilename, 'trails');
            if size(trails, 3) ~= size(points, 1)
                error('MATLAB:SceneManager:invalidTrailCount', ...
                    'Provide one trajectory trail for each inspection point.');
            end
            for index = 1:numel(obj.InspectionMarkers)
                marker = obj.InspectionMarkers{index};
                if isgraphics(marker)
                    delete(marker);
                end
                label = obj.InspectionLabels{index};
                if isgraphics(label)
                    delete(label);
                end
            end
            for index = 1:numel(obj.TrailHandles)
                if isgraphics(obj.TrailHandles{index})
                    delete(obj.TrailHandles{index});
                end
            end

            obj.InspectionPoints = points;
            obj.SatelliteTrails = trails;
            obj.SelectedInspectionPoint = 0;
            obj.VelocityHandles = cell(1, size(points, 1));
            obj.InspectionMarkers = cell(1, size(points, 1));
            obj.InspectionLabels = cell(1, size(points, 1));
            for index = 1:size(points, 1)
                [obj.InspectionMarkers{index}, obj.InspectionLabels{index}] = ...
                    SatelliteRenderer.drawMarker(obj.Axes, points(index, :), ...
                    obj.Config.satelliteIds{index});
            end
            obj.TrailHandles = SatelliteRenderer.drawTrails(obj.Axes, trails, ...
                obj.Config.trailColor, true);
            obj.setTrailsVisible(obj.ShowTrails);
        end

        function setTrailsVisible(obj, visible)
            validateattributes(visible, {'logical', 'numeric'}, ...
                {'scalar', 'finite'}, mfilename, 'visible');
            visible = logical(visible);
            obj.ShowTrails = visible;
            for index = 1:numel(obj.TrailHandles)
                if isgraphics(obj.TrailHandles{index})
                    obj.TrailHandles{index}.Visible = matlab.lang.OnOffSwitchState(visible);
                end
            end
        end

        function updateSatelliteState(obj, positions, velocities, trails)
            validateattributes(positions, {'numeric'}, ...
                {'real', 'finite', 'size', size(obj.InspectionPoints)}, ...
                mfilename, 'positions');
            validateattributes(velocities, {'numeric'}, ...
                {'real', 'finite', 'size', size(obj.InspectionPoints)}, ...
                mfilename, 'velocities');
            validateattributes(trails, {'numeric'}, ...
                {'real', 'finite', '3d', 'ncols', 3}, mfilename, 'trails');
            if size(trails, 3) ~= size(positions, 1) || ...
                    size(trails, 1) < 2
                error('MATLAB:SceneManager:invalidTrailCount', ...
                    'Provide at least two trail points for every satellite.');
            end

            obj.InspectionPoints = positions;
            obj.SatelliteTrails = trails;
            for index = 1:size(positions, 1)
                marker = obj.InspectionMarkers{index};
                marker.XData = positions(index, 1);
                marker.YData = positions(index, 2);
                marker.ZData = positions(index, 3);
                obj.InspectionLabels{index}.Position = positions(index, :);

                trail = obj.TrailHandles{index};
                trail.XData = trails(:, 1, index);
                trail.YData = trails(:, 2, index);
                trail.ZData = trails(:, 3, index);

                velocity = velocities(index, :) * obj.Config.velocityDisplayScale;
                if isempty(obj.VelocityHandles{index}) || ...
                        ~isgraphics(obj.VelocityHandles{index})
                    obj.VelocityHandles{index} = quiver3(obj.Axes, ...
                        positions(index, 1), positions(index, 2), positions(index, 3), ...
                        velocity(1), velocity(2), velocity(3), 0, ...
                        'Color', obj.Config.velocityColor, 'LineWidth', 1.3, ...
                        'MaxHeadSize', 0.55, 'HandleVisibility', 'off');
                else
                    arrow = obj.VelocityHandles{index};
                    arrow.XData = positions(index, 1);
                    arrow.YData = positions(index, 2);
                    arrow.ZData = positions(index, 3);
                    arrow.UData = velocity(1);
                    arrow.VData = velocity(2);
                    arrow.WData = velocity(3);
                end
                obj.VelocityHandles{index}.Visible = ...
                    matlab.lang.OnOffSwitchState(obj.ShowVelocities);
            end

            limit = max(obj.Extent, max(abs(positions(:))) * 1.25);
            xlim(obj.Axes, [-limit, limit]);
            ylim(obj.Axes, [-limit, limit]);
            zlim(obj.Axes, [-limit, limit]);
        end

        function setVelocitiesVisible(obj, visible)
            validateattributes(visible, {'logical', 'numeric'}, ...
                {'scalar', 'finite'}, mfilename, 'visible');
            obj.ShowVelocities = logical(visible);
            for index = 1:numel(obj.VelocityHandles)
                if isgraphics(obj.VelocityHandles{index})
                    obj.VelocityHandles{index}.Visible = ...
                        matlab.lang.OnOffSwitchState(obj.ShowVelocities);
                end
            end
        end

        function updateFieldVectors(obj, positions, fields, defined, color)
            obj.clearFieldVectors();
            if ~any(defined)
                return;
            end
            obj.FieldHandles = FieldRenderer.draw(obj.Axes, positions, fields, ...
                defined, color, obj.Config.fieldDisplayLength);
        end

        function clearFieldVectors(obj)
            for index = 1:numel(obj.FieldHandles)
                if isgraphics(obj.FieldHandles{index})
                    delete(obj.FieldHandles{index});
                end
            end
            obj.FieldHandles = {};
        end

        function selectInspectionPoint(obj, index)
            validateattributes(index, {'numeric'}, ...
                {'real', 'finite', 'scalar', 'integer', 'nonnegative'}, ...
                mfilename, 'index');
            if index > size(obj.InspectionPoints, 1)
                error('MATLAB:SceneManager:invalidInspectionIndex', ...
                    'The selected inspection point does not exist.');
            end
            obj.SelectedInspectionPoint = index;
            for markerIndex = 1:numel(obj.InspectionMarkers)
                marker = obj.InspectionMarkers{markerIndex};
                if ~isgraphics(marker)
                    continue;
                end
                if markerIndex == index
                    marker.SizeData = 90;
                    marker.MarkerEdgeColor = [1.00, 0.72, 0.34];
                    marker.LineWidth = 1.8;
                    obj.InspectionLabels{markerIndex}.Color = [1.00, 0.82, 0.53];
                else
                    marker.SizeData = 48;
                    marker.MarkerEdgeColor = [0.12, 0.16, 0.17];
                    marker.LineWidth = 0.8;
                    obj.InspectionLabels{markerIndex}.Color = [0.69, 0.74, 0.75];
                end
            end
        end
    end
end