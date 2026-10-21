function report = run_validation()
%RUN_VALIDATION Run project tests and MATLAB Code Analyzer reproducibly.
projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

testResults = runtests(fullfile(projectRoot, 'tests'));
assertSuccess(testResults);

sourceFiles = dir(fullfile(projectRoot, '**', '*.m'));
analyzerFindings = struct('file', {}, 'id', {}, 'message', {}, ...
    'line', {}, 'column', {});
for fileIndex = 1:numel(sourceFiles)
    filePath = fullfile(sourceFiles(fileIndex).folder, sourceFiles(fileIndex).name);
    findings = checkcode(filePath, '-id');
    for findingIndex = 1:numel(findings)
        analyzerFindings(end + 1) = struct( ...
            'file', strrep(filePath, [projectRoot, filesep], ''), ...
            'id', findings(findingIndex).id, ...
            'message', findings(findingIndex).message, ...
            'line', findings(findingIndex).line, ...
            'column', findings(findingIndex).column); %#ok<AGROW>
    end
end

if ~isempty(analyzerFindings)
    details = strings(1, numel(analyzerFindings));
    for findingIndex = 1:numel(analyzerFindings)
        finding = analyzerFindings(findingIndex);
        details(findingIndex) = sprintf('%s:%d [%s] %s', ...
            finding.file, finding.line, finding.id, finding.message);
    end
    error('OCTANT_VECTOR_DYNAMICS:CodeAnalyzerFindings', ...
        'MATLAB Code Analyzer reported findings:\n%s', strjoin(details, newline));
end

report = struct();
report.projectRoot = projectRoot;
report.matlabVersion = version;
report.testCount = numel(testResults);
report.passed = sum([testResults.Passed]);
report.failed = sum([testResults.Failed]);
report.incomplete = sum([testResults.Incomplete]);
report.analyzerFindingCount = numel(analyzerFindings);
report.analyzerFindings = analyzerFindings;

fprintf('Validation passed: %d/%d tests; Code Analyzer clean. MATLAB %s.\n', ...
    report.passed, report.testCount, report.matlabVersion);
end