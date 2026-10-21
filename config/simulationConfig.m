function config = simulationConfig()
%SIMULATIONCONFIG Shared defaults for the octant and vector demonstration.
config.extent = 8;
config.initialPoint = [-3, 4, 5];
config.componentColor = [0.93, 0.69, 0.28];
config.vectorColor = [0.20, 0.82, 0.78];
config.pointColor = [1.00, 0.42, 0.30];
signs = [1, 1, 1; -1, 1, 1; -1, -1, 1; 1, -1, 1; ...
		 1, 1, -1; -1, 1, -1; -1, -1, -1; 1, -1, -1];
config.inspectionPoints = signs .* abs(config.initialPoint);
config.octantNames = {'Octant I'; 'Octant II'; 'Octant III'; 'Octant IV'; ...
	'Octant V'; 'Octant VI'; 'Octant VII'; 'Octant VIII'};
config.satelliteIds = arrayfun(@(index) sprintf('SAT-%02d', index), ...
	1:size(signs, 1), 'UniformOutput', false);
trailStep = linspace(0, 1, 36)';
config.satelliteTrails = zeros(numel(trailStep), 3, size(signs, 1));
for index = 1:size(signs, 1)
	factors = [0.70 + 0.30 * trailStep + 0.05 * sin(pi * trailStep), ...
		0.70 + 0.30 * trailStep - 0.05 * sin(pi * trailStep), ...
		0.70 + 0.30 * trailStep + 0.04 * sin(2 * pi * trailStep)];
	config.satelliteTrails(:, :, index) = ...
		factors .* abs(config.inspectionPoints(index, :)) .* signs(index, :);
end
config.trailColor = [0.56, 0.71, 0.70];
config.motionAngularFrequency = 0.45;
config.motionAmplitudes = config.inspectionPoints .* [0.72, 0.58, 0.84];
config.trailDuration = 3.0;
config.trailSamples = 42;
config.clockStep = 0.05;
config.velocityColor = [0.96, 0.72, 0.33];
config.velocityDisplayScale = 0.7;
config.positionScaleToMeters = 1000;
config.epsilon0 = 8.8541878128e-12;
config.mu0 = 4 * pi * 1e-7;
config.pointChargeCoulombs = 1e-6;
config.wireCurrentAmps = 1;
config.fieldDisplayLength = 1.1;
config.electricFieldColor = [0.97, 0.48, 0.32];
config.magneticFieldColor = [0.46, 0.72, 0.98];
end