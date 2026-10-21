function tests = testVectorEngine
tests = functiontests(localfunctions);
end

function testCalculatesMagnitude(testCase)
verifyEqual(testCase, VectorEngine.magnitude([-3, 4, 5]), sqrt(50), ...
    'AbsTol', 1e-12);
end

function testPerformsVectorArithmetic(testCase)
verifyEqual(testCase, VectorEngine.add([1, 2, 3], [4, 5, 6]), [5, 7, 9]);
verifyEqual(testCase, VectorEngine.subtract([4, 5, 6], [1, 2, 3]), [3, 3, 3]);
verifyEqual(testCase, VectorEngine.dot([1, 2, 3], [4, 5, 6]), 32);
verifyEqual(testCase, VectorEngine.scale([1, -2, 3], -2), [-2, 4, -6]);
end

function testCrossProduct(testCase)
verifyEqual(testCase, VectorEngine.cross([1, 0, 0], [0, 1, 0]), [0, 0, 1]);
verifyEqual(testCase, VectorEngine.cross([0, 1, 0], [1, 0, 0]), [0, 0, -1]);
verifyEqual(testCase, VectorEngine.cross([-1, 0, 0], [0, 1, 0]), [0, 0, -1]);
end

function testUnitVectorInEveryOctant(testCase)
points = [1, 1, 1; -1, 1, 1; -1, -1, 1; 1, -1, 1; ...
          1, 1, -1; -1, 1, -1; -1, -1, -1; 1, -1, -1];
for index = 1:size(points, 1)
    unit = VectorEngine.unitVector(points(index, :));
    verifyEqual(testCase, VectorEngine.magnitude(unit), 1, 'AbsTol', 1e-12);
    verifyEqual(testCase, sign(unit), sign(points(index, :)));
end
end

function testCalculatesDirectionAngles(testCase)
angles = VectorEngine.directionAngles([1, 0, 0]);
verifyEqual(testCase, angles, [0, 90, 90], 'AbsTol', 1e-12);
end

function testZeroVectorHasUndefinedDirection(testCase)
verifyTrue(testCase, all(isnan(VectorEngine.directionAngles([0, 0, 0]))));
verifyError(testCase, @() VectorEngine.unitVector([0, 0, 0]), ...
    'MATLAB:VectorEngine:zeroVector');
verifyError(testCase, @() VectorEngine.angleBetween([0, 0, 0], [1, 0, 0]), ...
    'MATLAB:VectorEngine:zeroVector');
verifyFalse(testCase, VectorEngine.isParallel([0, 0, 0], [1, 0, 0]));
verifyFalse(testCase, VectorEngine.isPerpendicular([0, 0, 0], [1, 0, 0]));
end

function testAngleAndRelationships(testCase)
verifyEqual(testCase, VectorEngine.angleBetween([1, 0, 0], [0, 1, 0]), ...
    90, 'AbsTol', 1e-12);
verifyEqual(testCase, VectorEngine.angleBetween([1, 0, 0], [-1, 0, 0]), ...
    180, 'AbsTol', 1e-12);
verifyTrue(testCase, VectorEngine.isPerpendicular([1, 0, 0], [1e-12, 1, 0]));
verifyFalse(testCase, VectorEngine.isPerpendicular([1, 0, 0], [1e-5, 1, 0]));
verifyTrue(testCase, VectorEngine.isParallel([1, 2, 3], [-2, -4, -6]));
verifyFalse(testCase, VectorEngine.isParallel([1, 0, 0], [0, 1, 0]));
end

function testRejectsInvalidVector(testCase)
verifyError(testCase, @() VectorEngine.magnitude([1, 2]), ...
    'MATLAB:VectorEngine:incorrectNumel');
verifyError(testCase, @() VectorEngine.cross([1, 2], [3, 4, 5]), ...
    'MATLAB:VectorEngine:incorrectNumel');
verifyError(testCase, @() VectorEngine.scale([1, 2, 3], [2, 3]), ...
    'MATLAB:VectorEngine:expectedScalar');
verifyError(testCase, @() VectorEngine.isParallel([1, 0, 0], [1, 0, 0], -1), ...
    'MATLAB:VectorEngine:expectedNonnegative');
end