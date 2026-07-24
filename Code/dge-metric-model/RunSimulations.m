% RunSimulations is a MATLAB script to run scenarios stored in
% ModelSimulationandCalibration<Number of Subsectors>Sectorsand<Number of
% Regions>Regions.xlsx workbook. The DGE_Model.mod file is changed
% in the script.

repoRoot = fileparts(mfilename('fullpath'));
oldPwd = pwd;
cleanupObj = onCleanup(@() cd(oldPwd));
cd(repoRoot);
setup_paths();
%% Specify scenario names (grouped)
lSteadyState = false;

scenarioGroups = struct();

% Core reference scenarios
scenarioGroups.Reference = {...
   'Baseline', ...
   'NZ',...
    };

% Energy-efficiency scenarios
scenarioGroups.EE = {...
    'EE_Directive10', ...
    'EE_Directive10_NoBESS', ...
    'EE_PDP8_PV_BESS_NoBESS',...
    };

% Green-finance scenarios on PDP8 baseline
scenarioGroups.GF_PDP8 = {...
    'PDP8_GF_A', ...  % Green Finance: Balanced   (WACF 6.43%)
    'PDP8_GF_B', ...  % Green Finance: Market-led (WACF 7.37%)
    'PDP8_GF_C'};     % Green Finance: Public-led (WACF 5.07%)

% Green-finance scenarios on NZ baseline
scenarioGroups.GF_NZ = {...
    'NZ_GF_A', ...
    'NZ_GF_B', ...
    'NZ_GF_C'};

% NZ sensitivity / policy variants
scenarioGroups.NZ_Sensitivity = {...
    'NZ_constEE', ...
    'NZ_constInt', ...
    'NZ_constEEInt',...
    'NZ_subsidy',...
    };

% Temporary import-amount shock scenario
scenarioGroups.ImportShock = {...
    % 'EnergyCrisis',...
    'EnergyCrisisLonger'};


% Select which groups to run.
% Default group set:
activeScenarioGroups = {'ImportShock'};%, 'EE', 'GF_PDP8', 'GF_NZ', 'NZ_Sensitivity', 'ImportShock'};

% Optional override via environment variable, e.g.:
%   set DGE_SCENARIO_GROUPS=Reference,GF_NZ
envGroups = strtrim(getenv('DGE_SCENARIO_GROUPS'));
if ~isempty(envGroups)
    activeScenarioGroups = strtrim(strsplit(envGroups, ','));
end

casScenarioNames = {};
for iGroup = 1:numel(activeScenarioGroups)
    groupName = activeScenarioGroups{iGroup};
    if ~isfield(scenarioGroups, groupName)
        error('RunSimulations:UnknownScenarioGroup', ...
            'Unknown scenario group "%s". Check activeScenarioGroups.', groupName);
    end
    casScenarioNames = [casScenarioNames scenarioGroups.(groupName)]; %#ok<AGROW>
end

if isempty(casScenarioNames)
    error('RunSimulations:NoScenariosSelected', ...
        'No scenarios selected. Add at least one group to activeScenarioGroups.');
end

% Define sector strucutre
sSubsecstart = '[1, 2, 4, 5]';                 
sSubsecend =   '[1, 3, 4, 5]';

% sSubsecstart = '[1]';                 
% sSubsecend =   '[1]';
sClimRegional = '["tas"]';
sClimNational = '["tas"]';
sTargetBase = '1';
%% Define number of regions
sRegions = '1';
%% Execute dynare to run the model
if isoctave()
    error('Octave is currently not supported please use Matlab 2019 or above')
end

timestart = tic;

%% Define additonal specification of the version of the model for sensitivity analysis.
sWorkbookCalibration = ['ExcelFiles/ModelCalibration' sSubsecend(end-1) 'Sectorsand' sRegions 'Regions.xlsx'];
sWorkbookBaseline    = ['ExcelFiles/ModelBaseline'    sSubsecend(end-1) 'Sectorsand' sRegions 'Regions.xlsx'];
sWorkbookScenarios   = ['ExcelFiles/ModelScenarios'   sSubsecend(end-1) 'Sectorsand' sRegions 'Regions.xlsx'];
iposstart = 1;
iposend =   7;
lBaselineBackward_p = 0;
lReshuffleInitial_p = 1;
% When lReshuffleInitial_p == 1, Functions/simulation_model_refactored.m calls
% reshuffle_initial_period.m to rescale the Baseline initial period's investment
% (by economic activity/subsector and by source: private/FDI/public, each as a
% share of nominal regional GDP) and re-derive consumption, government
% expenditure, net exports and public debt bottom-up to match those targets.
% Two ways to supply targets:
%   1) Point sInvestmentTargetsCsv at a GSO
%      investment_gdp_by_ownership_and_sector.csv (columns: aggregate_sector,
%      public_gdp_ratio, fdi_gdp_ratio_proxy, domestic_private_gdp_ratio_residual,
%      ...) and build_investment_targets_from_gso.m builds tabtargets
%      automatically (Primary+MiningEnergy -> subsector 1, Utilities split
%      Fossil/Renewables by existing K0 shares -> subsectors 2/3,
%      Secondary+Refinery -> subsector 4, Tertiary -> subsector 5).
%      The ownership CSV's total (public+private+FDI summed across sectors,
%      ~34.6% of 2019 GDP) is GSO's "Investment_Activity" survey total --
%      realized investment capital by industry -- which does NOT reconcile
%      with SNA gross fixed capital formation (see docs/data_sources.md and
%      GenerateGDPComponentsStartEndVsActual.m's "Actual" column, ~23.3% of
%      GDP for non-housing I in 2019). Left unscaled, the Baseline's
%      simulated investment path runs ~11pp of GDP above that IO-table
%      benchmark. Set sInvestmentTargetsIoTableXlsx (+ optionally
%      sInvestmentTargetsIoTableSheet) to rescale every target
%      proportionally so the aggregate lands on the IO table's total
%      instead, preserving the ownership CSV's relative sector/source
%      shares (see "Rescaling rationale" in build_investment_targets_from_gso.m).
%
% Paths below are personal (outside the repo, under each user's Dropbox),
% so they are derived from %USERPROFILE% rather than hardcoded, and can be
% overridden entirely via DGE_INVESTMENT_TARGETS_CSV /
% DGE_INVESTMENT_TARGETS_IOTABLE_XLSX env vars. If the
% resolved file isn't found, the target is left empty (with a warning) and
% simulation_model_refactored.m skips the reshuffle-from-GSO step rather
% than failing on a bad path.
sInvestmentTargetsCsv = strtrim(getenv('DGE_INVESTMENT_TARGETS_CSV'));
if isempty(sInvestmentTargetsCsv)
    sInvestmentTargetsCsv = fullfile(getenv('USERPROFILE'), 'Dropbox', '2025_GIZ_Vietnam', ...
        'Data', 'GSO', 'data', 'output', 'investment_gdp_by_ownership_and_sector.csv');
end
if ~isfile(sInvestmentTargetsCsv)
    warning('RunSimulations:InvestmentTargetsCsvNotFound', ...
        'sInvestmentTargetsCsv not found at "%s"; skipping GSO investment-target reshuffle.', sInvestmentTargetsCsv);
    sInvestmentTargetsCsv = '';
end

sInvestmentTargetsIoTableXlsx = strtrim(getenv('DGE_INVESTMENT_TARGETS_IOTABLE_XLSX'));
if isempty(sInvestmentTargetsIoTableXlsx)
    sInvestmentTargetsIoTableXlsx = fullfile(getenv('USERPROFILE'), 'Dropbox', '2025_GIZ_Vietnam', ...
        'Data', 'GSO', 'data', 'raw', 'IO-2019.xlsx');
end
if ~isfile(sInvestmentTargetsIoTableXlsx)
    warning('RunSimulations:InvestmentTargetsIoTableNotFound', ...
        'sInvestmentTargetsIoTableXlsx not found at "%s"; investment targets will not be rescaled to the IO-table total.', sInvestmentTargetsIoTableXlsx);
    sInvestmentTargetsIoTableXlsx = '';
end
sInvestmentTargetsIoTableSheet = 'Calibration for GDP Components';  % default; only needed if the sheet name changes
%   2) Define a 'tabtargets' struct here directly, e.g.:
%   tabtargets.IFDI_3_1 = 0.015;  % FDI into region 1 Renewables = 1.5% of regional GDP
%   tabtargets.IG_1_1   = 0.02;   % Public investment into region 1 Primary = 2% of regional GDP
% See Functions/SteadyState/reshuffle_initial_period.m for the full field
% convention. Any (subsector, region, source) left undefined keeps its
% pre-reshuffle model value.

% Optional: additionally reconcile fossil/renewables (subsector 2/3)
% investment against the empirical PDP8 investment/capital-stock ratio
% (first two PDP8 years), holding K_2_1/K_3_1 fixed and letting P_INV
% absorb the reconciliation via tabtargets.IK_2_1/IK_3_1. See
% Functions/SteadyState/reshuffle_initial_period.m step 1b and
% Functions/Miscellaneous/Simulation/compute_pdp8_capital_investment_ratio.m
% for why this ratio must reuse the same New + Maintenance decomposition as
% exo_targetIY_2_1/exo_targetIY_3_1, not a raw INV_MIOUSD/CAP_MIOUSD ratio.
lReshuffleIK_p = 1;
%% Baseline candidate sweep
% Each entry is the name of a sheet inside ModelBaseline5Sectorsand1Regions.xlsx.
% The first entry must be 'Baseline' (the reference sheet already present).
% Add extra candidate sheets to the same workbook and list their names here.
%
% sSensitivity (used for structScenarioResults<suffix>.mat and sVersion key)
% is derived automatically as strrep(sheetName,'Baseline',''), so:
%   'Baseline'       -> sSensitivity = ''        -> structScenarioResults.mat
%   'Baseline_Cand01'-> sSensitivity = '_Cand01' -> structScenarioResults_Cand01.mat
%
% For every candidate the solver warm-starts oo_.endo_simul from the
% user-defined Baseline solution by default. Set DGE_BASELINE_WARM_START
% to "previous" to use the immediately preceding candidate instead, or
% "none" to disable candidate warm-starts.
%
% To add a candidate:
%   1. Open ExcelFiles/ModelBaseline5Sectorsand1Regions.xlsx
%   2. Duplicate the 'Baseline' sheet and rename it, e.g. 'Baseline_Cand01'
%   3. Edit VA shares / growth rates in that sheet
%   4. Add 'Baseline_Cand01' to casCandidates below.
casCandidates = {'Baseline';...
                 };
envCandidates = strtrim(getenv('DGE_BASELINE_SHEETS'));
if ~isempty(envCandidates)
    casCandidates = strtrim(strsplit(envCandidates, ','));
    casCandidates = casCandidates(~cellfun('isempty', casCandidates));
end
if isempty(casCandidates)
    error('RunSimulations:NoBaselineCandidates', ...
        'No baseline sheets selected. Set casCandidates or DGE_BASELINE_SHEETS.');
end

baselineGrowthTolerance = 1e-6;
envGrowthTolerance = strtrim(getenv('DGE_BASELINE_GDP_TOL'));
if ~isempty(envGrowthTolerance)
    baselineGrowthTolerance = str2double(envGrowthTolerance);
    if ~isfinite(baselineGrowthTolerance) || baselineGrowthTolerance < 0
        error('RunSimulations:InvalidGrowthTolerance', ...
            'DGE_BASELINE_GDP_TOL must be a non-negative numeric tolerance.');
    end
end

baselineWarmStartMode = 'user';
envWarmStartMode = lower(strtrim(getenv('DGE_BASELINE_WARM_START')));
if ~isempty(envWarmStartMode)
    if ~any(strcmp(envWarmStartMode, {'user', 'previous', 'none'}))
        error('RunSimulations:InvalidWarmStartMode', ...
            'DGE_BASELINE_WARM_START must be "user", "previous", or "none".');
    end
    baselineWarmStartMode = char(envWarmStartMode);
end

baselineCandidateNewtonMaxit = 8;
envCandidateNewtonMaxit = strtrim(getenv('DGE_BASELINE_CANDIDATE_MAXIT'));
if ~isempty(envCandidateNewtonMaxit)
    baselineCandidateNewtonMaxit = parse_positive_integer( ...
        envCandidateNewtonMaxit, 'DGE_BASELINE_CANDIDATE_MAXIT');
end

baselineCandidateSteps = 1;
envCandidateSteps = strtrim(getenv('DGE_BASELINE_CANDIDATE_STEPS'));
if ~isempty(envCandidateSteps)
    baselineCandidateSteps = parse_positive_integer( ...
        envCandidateSteps, 'DGE_BASELINE_CANDIDATE_STEPS');
end

baselineCandidateScores = baseline_candidate_empty_score('', '', '');
baselineCandidateScores = baselineCandidateScores([]);

for icoCand = 1:numel(casCandidates)
    sBaselineSheet = casCandidates{icoCand};           % sheet to read from ModelBaseline*.xlsx
    sSensitivity   = strrep(sBaselineSheet, 'Baseline', '');  % '' for reference, '_Cand01' etc. for candidates
    lBaselineCandidate_p = ~strcmp(sBaselineSheet, 'Baseline');

scenarioStart = max(1, iposstart);
scenarioEnd = min(iposend, numel(casScenarioNames));
for icoScenario = scenarioStart:scenarioEnd
    sScenario = char(casScenarioNames(icoScenario));
    % This function allows to switch between endogenous production or
    % productivity shocks.
    if contains(sScenario,{'Baseline'})
        sBaseline = 'Baseline';
        if lSteadyState
            sSimulation = '5'; %#ok<UNRCH>
        else
            sSimulation = '20';
        end
        sExoNX = '0'; % exogenous net exports does not work with LOM for foreign assets.
        sCapandTrade = '0';
    elseif ismember(sScenario,{'NZ_constEE', 'NZ_constInt', 'NZ_constEEInt', 'NZ_lowphiK', ...
                               'NZ_concessional', 'NZ_conandsub', 'NZ_subsidy', ...
                               'NZ_GF_A', 'NZ_GF_B', 'NZ_GF_C'})
        sBaseline = 'NZ';
        sSimulation = '20';
        sExoNX = '0';% define whether net exports to GDP are constant
        sCapandTrade = '1';
    elseif ismember(sScenario, {'PDP8_GF_A', 'PDP8_GF_B', 'PDP8_GF_C'})
        sBaseline = 'Baseline';
        sSimulation = '5';
        sExoNX = '0';
        sCapandTrade = '1';
    else
        sBaseline = 'Baseline';
        sSimulation = '20';
        sExoNX = '0';% define whether net exports to GDP are constant
        sCapandTrade = '1';
    end

    lBaselineWarmStart_p = false;
    sBaselineWarmRef = '';
    iPerfectForesightMaxit_p = NaN;
    iStepSimulationOverride_p = NaN;
    if lBaselineCandidate_p && strcmp(sScenario, 'Baseline')
        switch baselineWarmStartMode
            case 'user'
                lBaselineWarmStart_p = true;
                sBaselineWarmRef = ''; % user-defined Baseline solution in structScenarioResults.mat
            case 'previous'
                lBaselineWarmStart_p = icoCand > 1;
                if lBaselineWarmStart_p
                    sBaselineWarmRef = strrep(casCandidates{icoCand - 1}, 'Baseline', '');
                end
            case 'none'
                lBaselineWarmStart_p = false;
        end
        iPerfectForesightMaxit_p = baselineCandidateNewtonMaxit;
        iStepSimulationOverride_p = baselineCandidateSteps;
    end

    change_mod_file(sScenario,sSubsecstart,sSubsecend,sRegions,sSimulation, sExoNX, sCapandTrade, sClimRegional, sClimNational, sTargetBase);
    % Model is called each time. We need to run the preprocessor to update
    % all .m files depending on whether productivity shocks are endogenous or
    % exogenous.
    runSucceeded = false;
    runError = '';
    try
        dynare DGE_Model noclearall
        runSucceeded = true;
    catch ME
        runError = ME.message;
        disp([sScenario ' run with higher iteration'])
        disp(['Run error: ' runError])
    end

    if strcmp(sScenario, 'Baseline')
        if runSucceeded
            score = score_baseline_candidate(sWorkbookBaseline, sBaselineSheet, ...
                sSensitivity, sScenario, baselineGrowthTolerance);
        else
            score = baseline_candidate_empty_score(sBaselineSheet, ...
                sSensitivity, sScenario);
            score.RunError = runError;
        end
        baselineCandidateScores(end + 1) = score; %#ok<SAGROW>
        display_baseline_candidate_score(score);
    end

end  % icoScenario
end  % icoCand

summarize_baseline_candidate_scores(baselineCandidateScores);

timeend = toc(timestart);
disp(['time for computation ' num2str(timeend/60) ' minutes'])

function score = baseline_candidate_empty_score(sBaselineSheet, sSensitivity, sScenario)
    if nargin < 1, sBaselineSheet = ''; end
    if nargin < 2, sSensitivity = ''; end
    if nargin < 3, sScenario = ''; end

    score = struct( ...
        'Sheet', char(sBaselineSheet), ...
        'Sensitivity', char(sSensitivity), ...
        'Scenario', char(sScenario), ...
        'OutputCsv', '', ...
        'Solved', false, ...
        'GrowthFeasible', false, ...
        'MaxAbsMuI', NaN, ...
        'MaxAbsCapitalLomGap', NaN, ...
        'MaxAbsInvGdpTargetDiff', NaN, ...
        'MaxAbsPriceWeightedGrowthDiff', NaN, ...
        'MaxAbsAggregateGrowthDiff', NaN, ...
        'MaxAbsGrowthDiff', NaN, ...
        'RunError', '', ...
        'GrowthAuditError', '');
end

function score = score_baseline_candidate(sWorkbookBaseline, sBaselineSheet, ...
    sSensitivity, sScenario, baselineGrowthTolerance)

    score = baseline_candidate_empty_score(sBaselineSheet, sSensitivity, sScenario);
    score.OutputCsv = expected_output_path(sSensitivity, sScenario);

    if ~isfile(score.OutputCsv)
        score.RunError = ['Output CSV not found: ' score.OutputCsv];
        return
    end

    score.Solved = true;
    results = read_table_preserve_names(score.OutputCsv);
    resultNames = results.Properties.VariableNames;

    muICols = find_matching_columns(resultNames, '^muI_\d+_\d+$');
    if ~isempty(muICols)
        muIValues = table2array(results(:, muICols));
        score.MaxAbsMuI = max_abs_finite(muIValues);
        score.MaxAbsCapitalLomGap = max_abs_finite(exp(muIValues) - 1);
    end

    score.MaxAbsInvGdpTargetDiff = audit_investment_gdp_targets( ...
        sWorkbookBaseline, score.OutputCsv, sBaselineSheet);

    try
        growthSummary = audit_baseline_gdp_growth(sWorkbookBaseline, ...
            score.OutputCsv, sBaselineSheet);
        score.MaxAbsPriceWeightedGrowthDiff = growthSummary.maxAbsPriceWeightedSectorDiff;
        score.MaxAbsAggregateGrowthDiff = growthSummary.maxAbsAggregateDiff;
        score.MaxAbsGrowthDiff = max_finite([ ...
            score.MaxAbsPriceWeightedGrowthDiff, ...
            score.MaxAbsAggregateGrowthDiff]);
        score.GrowthFeasible = isfinite(score.MaxAbsGrowthDiff) && ...
            score.MaxAbsGrowthDiff <= baselineGrowthTolerance;
    catch ME
        score.GrowthAuditError = ME.message;
        score.GrowthFeasible = false;
    end
end

function outputPath = expected_output_path(sSensitivity, sScenario)
    if contains(sScenario, '.csv')
        outputPath = fullfile('ExcelFiles', 'Output', sScenario);
    else
        outputPath = fullfile('ExcelFiles', 'Output', [sSensitivity sScenario '.csv']);
    end
end

function maxDiff = audit_investment_gdp_targets(sWorkbookBaseline, sOutputCsv, sSheet)
    maxDiff = NaN;
    if ~isfile(sWorkbookBaseline) || ~isfile(sOutputCsv)
        return
    end

    targets = read_table_preserve_names(sWorkbookBaseline, 'Sheet', sSheet);
    results = read_table_preserve_names(sOutputCsv);

    targetNames = targets.Properties.VariableNames;
    resultNames = results.Properties.VariableNames;
    timeValues = optional_numeric_column(targets, 'Time');

    targetCols = find_matching_columns(targetNames, '^exo_targetIY_\d+_\d+$');
    diffs = [];
    for iCol = targetCols(:)'
        tokens = regexp(targetNames{iCol}, '^exo_targetIY_(\d+)_(\d+)$', 'tokens', 'once');
        if isempty(tokens)
            continue
        end

        iSubsector = str2double(tokens{1});
        iRegion = str2double(tokens{2});
        sFlag = sprintf('exo_ltargetIY_%d_%d', iSubsector, iRegion);
        sI = sprintf('I_%d_%d', iSubsector, iRegion);
        sIG = sprintf('I_G_%d_%d', iSubsector, iRegion);
        sPInv = sprintf('P_INV_%d_%d', iSubsector, iRegion);
        sY = sprintf('Y_%d', iRegion);
        sP = sprintf('P_%d', iRegion);

        if ~has_variable(resultNames, sI) || ~has_variable(resultNames, sIG) || ...
           ~has_variable(resultNames, sPInv) || ~has_variable(resultNames, sY) || ...
           ~has_variable(resultNames, sP)
            continue
        end

        target = to_numeric(targets.(targetNames{iCol}));
        if has_variable(targetNames, sFlag)
            active = to_numeric(targets.(sFlag)) > 0.5;
        else
            active = ~isnan(target);
        end

        i = to_numeric(results.(sI));
        ig = to_numeric(results.(sIG));
        pInv = to_numeric(results.(sPInv));
        y = to_numeric(results.(sY));
        p = to_numeric(results.(sP));

        for iRow = 1:numel(target)
            if iRow > numel(active) || ~active(iRow) || isnan(target(iRow))
                continue
            end

            if ~isempty(timeValues) && iRow <= numel(timeValues) && isfinite(timeValues(iRow))
                iResult = round(timeValues(iRow));
            else
                iResult = iRow + 1;
            end

            if iResult < 1 || iResult > numel(i) || iResult > numel(y)
                continue
            end

            denominator = y(iResult) * p(iResult);
            if denominator == 0 || ~isfinite(denominator)
                continue
            end

            simulatedRatio = (i(iResult) + ig(iResult)) * pInv(iResult) / denominator;
            diffs(end + 1, 1) = abs(simulatedRatio - target(iRow)); %#ok<AGROW>
        end
    end

    maxDiff = max_finite(diffs);
end

function summarize_baseline_candidate_scores(scores)
    if isempty(scores)
        return
    end

    outDir = fullfile('ExcelFiles', 'Output');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    scoreTable = struct2table(scores, 'AsArray', true);
    scoreFile = fullfile(outDir, 'BaselineCandidateScores.csv');
    writetable(scoreTable, scoreFile);

    feasible = scoreTable.Solved & scoreTable.GrowthFeasible & ...
        isfinite(scoreTable.MaxAbsMuI);
    if any(feasible)
        feasibleIdx = find(feasible);
        [~, relIdx] = min(scoreTable.MaxAbsMuI(feasibleIdx));
        bestIdx = feasibleIdx(relIdx);
        bestSheet = table_text_value(scoreTable.Sheet, bestIdx);
        disp(' ')
        disp(['Best baseline candidate: ' bestSheet ...
            ' (max(abs(muI)) = ' format_metric(scoreTable.MaxAbsMuI(bestIdx)) ...
            ', max GDP-growth diff = ' format_metric(scoreTable.MaxAbsGrowthDiff(bestIdx)) ...
            ', max I/Y target diff = ' format_metric(scoreTable.MaxAbsInvGdpTargetDiff(bestIdx)) ')'])
    else
        disp(' ')
        disp('No baseline candidate satisfied the GDP-growth tolerance with a finite muI score.')
    end
    disp(['Baseline candidate scores written to ' scoreFile])
end

function display_baseline_candidate_score(score)
    if score.GrowthFeasible
        feasibleText = 'yes';
    else
        feasibleText = 'no';
    end
    disp(['[Baseline candidate] ' score.Sheet ...
        ': max(abs(muI))=' format_metric(score.MaxAbsMuI) ...
        ', max exp(muI)-1=' format_metric(score.MaxAbsCapitalLomGap) ...
        ', max I/Y target diff=' format_metric(score.MaxAbsInvGdpTargetDiff) ...
        ', max GDP-growth diff=' format_metric(score.MaxAbsGrowthDiff) ...
        ', GDP feasible=' feasibleText])
end

function tab = read_table_preserve_names(sFile, varargin)
    try
        tab = readtable(sFile, varargin{:}, 'PreserveVariableNames', true);
    catch
        try
            tab = readtable(sFile, varargin{:}, 'VariableNamingRule', 'preserve');
        catch
            tab = readtable(sFile, varargin{:});
        end
    end
end

function cols = find_matching_columns(names, pattern)
    cols = [];
    for i = 1:numel(names)
        if ~isempty(regexp(names{i}, pattern, 'once'))
            cols(end + 1) = i; %#ok<AGROW>
        end
    end
end

function tf = has_variable(names, sName)
    tf = any(strcmp(names, sName));
end

function x = optional_numeric_column(tab, sName)
    if has_variable(tab.Properties.VariableNames, sName)
        x = to_numeric(tab.(sName));
    else
        x = [];
    end
end

function x = to_numeric(value)
    if isnumeric(value)
        x = double(value);
    elseif iscell(value)
        x = nan(size(value));
        for i = 1:numel(value)
            x(i) = numeric_scalar(value{i});
        end
    elseif isstring(value)
        x = str2double(value);
    elseif ischar(value)
        x = str2double(cellstr(value));
    else
        x = double(value);
    end
    x = x(:);
end

function value = numeric_scalar(raw)
    if isempty(raw)
        value = NaN;
    elseif isnumeric(raw)
        value = double(raw);
    elseif ischar(raw) || isstring(raw)
        value = str2double(char(raw));
    else
        value = NaN;
    end
end

function value = max_abs_finite(x)
    x = x(:);
    x = x(isfinite(x));
    if isempty(x)
        value = NaN;
    else
        value = max(abs(x));
    end
end

function value = max_finite(x)
    x = x(:);
    x = x(isfinite(x));
    if isempty(x)
        value = NaN;
    else
        value = max(x);
    end
end

function s = format_metric(x)
    if isfinite(x)
        s = num2str(x, '%.6g');
    else
        s = 'NaN';
    end
end

function value = parse_positive_integer(rawText, envName)
    value = str2double(rawText);
    if ~isfinite(value) || value < 1 || abs(value - round(value)) > 1e-10
        error('RunSimulations:InvalidPositiveInteger', ...
            '%s must be a positive integer.', envName);
    end
    value = round(value);
end

function s = table_text_value(values, idx)
    if iscell(values)
        s = values{idx};
    elseif isstring(values)
        s = char(values(idx));
    elseif ischar(values)
        if size(values, 1) == 1
            s = strtrim(values);
        else
            s = strtrim(values(idx, :));
        end
    else
        s = char(string(values(idx)));
    end
end
