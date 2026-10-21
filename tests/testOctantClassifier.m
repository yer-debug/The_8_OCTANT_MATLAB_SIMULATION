function tests = testOctantClassifier
tests = functiontests(localfunctions);
end

function testClassifiesAllEightOctants(testCase)
points = [1, 1, 1; -1, 1, 1; -1, -1, 1; 1, -1, 1; ...
          1, 1, -1; -1, 1, -1; -1, -1, -1; 1, -1, -1];
expected = {'Octant I'; 'Octant II'; 'Octant III'; 'Octant IV'; ...
            'Octant V'; 'Octant VI'; 'Octant VII'; 'Octant VIII'};

for index = 1:size(points, 1)
    [octant, ~, isBoundary] = OctantClassifier.classify(points(index, :));
    verifyEqual(testCase, octant, expected{index});
    verifyFalse(testCase, isBoundary);
end
end

function testIdentifiesCoordinatePlaneBoundaries(testCase)
boundaryPoints = [0, 2, -1; 2, 0, -1; 2, -1, 0; 0, 0, 0];
for index = 1:size(boundaryPoints, 1)
    [octant, ~, isBoundary] = OctantClassifier.classify(boundaryPoints(index, :));
    verifyEqual(testCase, octant, 'Boundary');
    verifyTrue(testCase, isBoundary);
end
end

function testReportsCoordinateSigns(testCase)
[~, signText] = OctantClassifier.classify([-3, 4, 5]);
verifyEqual(testCase, signText, '(-, +, +)');
end

function testRejectsInvalidPoint(testCase)
verifyError(testCase, @() OctantClassifier.classify([1, 2]), ...
    'MATLAB:OctantClassifier:incorrectNumel');
end