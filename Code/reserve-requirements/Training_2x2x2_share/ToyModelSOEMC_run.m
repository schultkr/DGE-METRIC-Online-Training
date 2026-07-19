% ToyModelSOEMC_run.m
% Master runner for the Multi-Commodity SOE Model with Installed Capacity
%
% WHAT THIS SCRIPT DOES:
%   1.  Calls Dynare to compile ToyModelSOEMC.mod (solves SS + extended_path smoke test)
%   2.  Checks steady-state values (Vietnam calibration)
%   3.  Deterministic crisis demo: supply disruption, phi_R=0 vs phi_R=1
%   3b. Vietnam growth scenario: reserve adequacy at 6.5% GDP growth
%   3c. Energy Master Plan VIII: coal phase-down scenarios (A/B/C)
%   4.  Joint optimal policy: 3D Monte Carlo grid over (phi_R × phi_IQ × d)
%       → finds (phi_R*, phi_IQ*, d*) simultaneously
%       → WHY JOINT: phi_R*, phi_IQ*, and d* are interdependent (strategic complements)
%          Sequential optimisation (MC then stock search) gives inconsistent results
%          because the optimal drawdown policy depends on the stock size, and vice versa.
%       → Storage cost (kappa_1*R + kappa_2*R^2) is in the resource constraint,
%          so maximising E[W(phi_R, phi_IQ, d)] already nets out storage costs.
%       → writes R_oil_bar*, R_coal_bar*, phi_R*, phi_IQ* to M_.params
%
% HOW TO USE:
%   Open MATLAB. Change to the 'Toy Model SOE MC' folder.
%   Run this script (F5 or type ToyModelSOEMC_run in the command window).
%
% PREREQUISITES:
%   - Dynare 7 on MATLAB path (run dynare_config or configure in MATLAB startup)
%   - 'Toy Model SOE' folder on path (for shared utility functions)

clc; close all;
SIM_MODE = 'pf';
if ~exist('MINIMAL_MODE', 'var')
    MINIMAL_MODE = false;   % Toggle: true = fastest run, false = full scenario suite
end

% Top-level progress bar for long master run.
wb_run = waitbar(0, 'ToyModelSOEMC: starting...');
set(wb_run, 'Tag', 'ToyModelSOEMCRunWaitbar');
wb_run_cleanup = onCleanup(@() close(findall(0, 'Type', 'figure', 'Tag', 'ToyModelSOEMCRunWaitbar')));

% ----------------------------------------------------------------
% Dynare path setup (Windows-friendly)
%   If dynare is not already on path, try common install locations.
% ----------------------------------------------------------------
if exist('dynare', 'file') ~= 2
    dynare_candidates = {};

    % Common direct install locations
    if isfolder('C:\dynare\7.0\matlab')
        dynare_candidates{end+1} = 'C:\dynare\7.0\matlab'; %#ok<AGROW>
    end
    if isfolder('C:\dynare\6.3\matlab')
        dynare_candidates{end+1} = 'C:\dynare\6.3\matlab'; %#ok<AGROW>
    end
    if isfolder('C:\dynare\6.2\matlab')
        dynare_candidates{end+1} = 'C:\dynare\6.2\matlab'; %#ok<AGROW>
    end

    % Generic scan: C:\dynare\*\matlab
    dynare_scan = dir('C:\dynare\*\matlab');
    for ii = 1:length(dynare_scan)
        if dynare_scan(ii).isdir
            dynare_candidates{end+1} = fullfile(dynare_scan(ii).folder, dynare_scan(ii).name); %#ok<AGROW>
        end
    end

    % Try candidates until dynare is found
    for ii = 1:length(dynare_candidates)
        addpath(dynare_candidates{ii});
        if exist('dynare', 'file') == 2
            fprintf('Added Dynare path: %s\n', dynare_candidates{ii});
            break;
        end
    end
end

if exist('dynare', 'file') ~= 2
    error(['Dynare not found on MATLAB path. ' ...
           'Install Dynare and/or add its matlab folder to the path before running this script.']);
end

% ----------------------------------------------------------------
% COMMODITY LIST (must match @#define COMM in ToyModelSOEMC.mod)
% ----------------------------------------------------------------
COMM   = {'oil', 'coal'};
N_COMM = length(COMM);

% ----------------------------------------------------------------
% Paths
% ----------------------------------------------------------------
this_folder = fileparts(mfilename('fullpath'));
addpath(this_folder);
soe_folder  = fullfile(fileparts(this_folder), 'Toy Model SOE');

if exist(soe_folder, 'dir')
    addpath(soe_folder);
    fprintf('Added to path: %s\n', soe_folder);
end

cd(this_folder);

% ----------------------------------------------------------------
% Step 1: Run Dynare
%   Compiles ToyModelSOEMC.mod, solves SS via steadystate.m,
%   runs extended_path(periods=100, replic=5) for a quick smoke test.
%   After this: M_, options_, oo_ are in the workspace.
% ----------------------------------------------------------------
fprintf('\n=== STEP 1: Running Dynare ===\n');
if isgraphics(wb_run), waitbar(0.05, wb_run, 'Step 1/4: Running Dynare...'); end
dynare ToyModelSOEMC noclearall;
if isgraphics(wb_run), waitbar(0.25, wb_run, 'Step 2/4: Steady-state checks...'); end

% ----------------------------------------------------------------
% Step 2: Steady-state verification
% ----------------------------------------------------------------
fprintf('\n=== STEP 2: Steady-State Check (Vietnam calibration) ===\n');

Y_ss           = get_ss(oo_, M_, 'Y');
C_ss           = get_ss(oo_, M_, 'C');
r_ss           = get_ss(oo_, M_, 'r');
E_ss           = get_ss(oo_, M_, 'E');
NX_ss          = get_ss(oo_, M_, 'NX');
E_D_service_ss = get_ss(oo_, M_, 'E_D_service');

% Vietnam calibration checks
beta_vn  = M_.params(strcmp(M_.param_names, 'beta'));
delta_vn = M_.params(strcmp(M_.param_names, 'delta'));
r_target = 1/beta_vn + delta_vn - 1;

fprintf('  Y_ss          = %.4f  (Vietnam normalized GDP; investment-intensive)\n', Y_ss);
fprintf('  r_ss          = %.4f  (expect %.4f = 1/beta + delta - 1)\n', r_ss, r_target);
fprintf('  C_ss/Y_ss     = %.4f  (Vietnam ~0.60-0.65; lower due to capacity investment)\n', C_ss/Y_ss);
fprintf('  I_ss/Y_ss     = %.4f  (Vietnam investment rate ~33%%)\n', ...
        get_ss(oo_,M_,'I')/Y_ss);
fprintf('  E_ss          = %.4f  (expect 1.0000 — normalized energy aggregate)\n', E_ss);
fprintf('  E_D_service   = %.4f  (expect 0.7500 — dirty energy services)\n', E_D_service_ss);
fprintf('  NX_ss         = %.6f  (expect 0 — current account balanced at SS)\n', NX_ss);

for ci = 1:N_COMM
    c = COMM{ci};
    ED_c_now = M_.params(strcmp(M_.param_names, ['ED_' c '_bar']));
    R_c_now  = get_ss(oo_, M_, ['R_' c]);
    days_now = R_c_now / ED_c_now * 365;
    fprintf('  [%s]  Q_ss = %.4f | R_ss = %.4f (%.0f days) | eps_ss = %.4f | R_draw_ss = %.4f\n', ...
            c, get_ss(oo_, M_, ['Q_' c]), R_c_now, days_now, ...
            get_ss(oo_, M_, ['eps_' c]), get_ss(oo_, M_, ['R_' c '_draw']));
end
if isgraphics(wb_run), waitbar(0.40, wb_run, 'Step 3/4: Crisis and policy scenarios...'); end

% ----------------------------------------------------------------
% Step 3: Deterministic crisis demo (perfect_foresight_solver)
%
%   Scenario: simultaneous supply disruption (e_c_shock = -0.3)
%   lasting 20 periods, starting at period 10.
%
%   Minimal-run mode:
%     phi_R = 0.5 baseline drawdown rule
%
%   Uses perfect_foresight_solver so the exact shock path is visible.
%   (Extended_path draws its own random shocks; PF lets us inject a
%   specific deterministic path for illustration purposes.)
% ----------------------------------------------------------------
fprintf('\n=== STEP 3: Deterministic Crisis Demo ===\n');
fprintf('  e_c_shock = -0.3 for 20 periods (both commodities).\n');
if MINIMAL_MODE
    fprintf('  Minimal run mode: phi_R = 0.5 baseline rule.\n\n');
else
    fprintf('  phi_R = 0 vs phi_R = 1.0\n\n');
end

beta   = 0.95;    % Vietnam calibration
T_demo = 100;   % total simulation horizon for the demo

% Perfect-foresight options for the demo
options_pf        = options_;
options_pf.periods = T_demo;
PF_HOMOTOPY_STEPS = 5;   % Continuation steps for deterministic PF demo

% Set up a baseline exo_simul (all zeros = SS values)
oo_demo_base  = perfect_foresight_setup(M_, options_pf, oo_);
exo_baseline  = oo_demo_base.exo_simul;

% Exo column indices (new format: nu_c and e_c_shock only)
idx_ed = struct();
idx_nu = struct();
for ci = 1:N_COMM
    c = COMM{ci};
    idx_ed.(c) = find(strcmp(M_.exo_names, ['e_' c '_shock']));
    idx_nu.(c) = find(strcmp(M_.exo_names, ['nu_' c]));
end

% Parameter indices (used in Steps 3, 3b, 3c)
idx_phi_R  = find(strcmp(M_.param_names, 'phi_R'));
idx_phi_IQ = find(strcmp(M_.param_names, 'phi_IQ'));

% Crisis timing
T_start = 10;   % crisis starts at period 10
T_end   = 29;   % crisis ends at period 29 (20 periods)
crisis_rows = T_start+1 : T_end+1;   % +1 because row 1 = period 0 (SS)

T_WELFARE = 80;
results_demo = struct();
if MINIMAL_MODE
    phi_R_vals  = [0.5];
    labels_demo = {'\phi_R = 0.5  (baseline drawdown)'};
else
    phi_R_vals  = [0, 1.0];
    labels_demo = {'\phi_R = 0  (no drawdown)', '\phi_R = 1.0  (full drawdown)'};
end
N_demo = length(phi_R_vals);

for kk = 1:N_demo
    phi_R_kk = phi_R_vals(kk);

    % Set phi_R in model parameters
    M_.params(idx_phi_R) = phi_R_kk;

    % Build exo_simul: supply disruption only, no price innovations
    exo_mat = exo_baseline;
    for ci = 1:N_COMM
        c = COMM{ci};
        exo_mat(crisis_rows, idx_ed.(c)) = -0.3;   % supply shortfall
        % nu_c = 0 everywhere (deterministic scenario)
    end

    try
        [oo_run, ~] = ToyModelSOEMC_pf_homotopy_solve(M_, options_pf, oo_demo_base, exo_mat, PF_HOMOTOPY_STEPS);
        results_demo(kk).C      = extract_var(oo_run, M_, 'C');
        results_demo(kk).EDS    = extract_var(oo_run, M_, 'E_D_service');
        for ci = 1:N_COMM
            c = COMM{ci};
            results_demo(kk).(['Q_' c])     = extract_var(oo_run, M_, ['Q_' c]);
            results_demo(kk).(['R_' c])     = extract_var(oo_run, M_, ['R_' c]);
            results_demo(kk).(['Rdraw_' c]) = extract_var(oo_run, M_, ['R_' c '_draw']);
        end
        results_demo(kk).W  = compute_welfare(results_demo(kk).C, beta, T_WELFARE);
        results_demo(kk).ok = true;
    catch ME
        fprintf('  Scenario %d failed: %s\n', kk, ME.message);
        results_demo(kk).ok = false;
    end
    fprintf('  %s  |  W = %.4f\n', labels_demo{kk}, results_demo(kk).W);
end

% Restore default phi_R
M_.params(idx_phi_R) = 0.5;

% --- Plot demo ---
if N_demo > 0 && all([results_demo.ok])
    t_show = 1:min(60, T_demo);
    colors = {'b', 'r'};

    n_panels = 2 + N_COMM;
    figure('Name', 'Supply Crisis Demo', 'Position', [80 80 min(400*n_panels, 1600) 460]);
    if MINIMAL_MODE
        sgtitle({'Multi-Commodity SOE: Supply Crisis Demo', ...
                 'phi\_R = 0.5  (baseline drawdown, 20-period disruption)'}, ...
                'FontWeight', 'bold', 'FontSize', 12);
    else
        sgtitle({'Multi-Commodity SOE: Supply Crisis Demo', ...
                 'phi\_R = 0 vs phi\_R = 1.0  (20-period disruption, both commodities)'}, ...
                'FontWeight', 'bold', 'FontSize', 12);
    end

    subplot(1, n_panels, 1); hold on; grid on;
    for kk = 1:N_demo
        if results_demo(kk).ok
            plot(t_show, results_demo(kk).C(t_show), 'LineWidth', 2, 'Color', colors{kk});
        end
    end
    xline(T_start+1, 'k--', 'LineWidth', 1, 'Label', 'Crisis start');
    xline(T_end+2,   'k:',  'LineWidth', 1, 'Label', 'Crisis end');
    title('Consumption  C', 'FontWeight', 'bold');
    xlabel('Period'); ylabel('C');
    legend(labels_demo, 'Location', 'south', 'FontSize', 8);
    hold off;

    subplot(1, n_panels, 2); hold on; grid on;
    for kk = 1:N_demo
        if results_demo(kk).ok
            plot(t_show, results_demo(kk).EDS(t_show), 'LineWidth', 2, 'Color', colors{kk});
        end
    end
    xline(T_start+1, 'k--', 'LineWidth', 1);
    xline(T_end+2,   'k:',  'LineWidth', 1);
    title('Energy Services  E\_D\_service', 'FontWeight', 'bold');
    xlabel('Period'); ylabel('E\_D\_service');
    hold off;

    for ci = 1:N_COMM
        c = COMM{ci};
        subplot(1, n_panels, 2+ci); hold on; grid on;
        for kk = 1:N_demo
            if results_demo(kk).ok
                plot(t_show, results_demo(kk).(['R_' c])(t_show), ...
                     'LineWidth', 2, 'Color', colors{kk});
            end
        end
        R_bar_val = M_.params(find(strcmp(M_.param_names, ['R_' c '_bar'])));
        yline(R_bar_val, 'k:', 'LineWidth', 1, 'Label', 'R\_bar');
        xline(T_start+1, 'k--', 'LineWidth', 1);
        xline(T_end+2,   'k:',  'LineWidth', 1);
        title(sprintf('Reserve stock  R\\_%s', c), 'FontWeight', 'bold');
        xlabel('Period'); ylabel(['R\_' c]);
        hold off;
    end
end

% ----------------------------------------------------------------
% Step 3b: Vietnam Growth Scenario
%
%   Vietnam targets 6.5% p.a. GDP growth through 2030 (13th Party Congress).
%   As GDP grows, energy demand grows proportionally.
%   QUESTION: do strategic reserves keep pace with GDP, or does reserve
%   ADEQUACY (reserve coverage ratio) decline over time?
%
%   We show: reserve coverage = R_c / (ED_c_bar * (1+g_Y)^t)
%   Without scaling reserves to GDP, coverage halves in ~11 years.
% ----------------------------------------------------------------
fprintf('\n=== STEP 3b: Vietnam Growth Scenario ===\n');
fprintf('  GDP target: g_Y = 6.5%% p.a.  (13th Party Congress Resolution)\n');
fprintf('  Reserve coverage declines as economy grows unless R_bar scales with Y.\n\n');

g_Y        = 0.065;   % annual GDP growth rate (Vietnam target)
T_growth   = 30;       % horizon (periods)
t_growth   = (0:T_growth)';

% Reserve coverage ratio under 3 scenarios:
%   (a) Fixed reserves (no scaling)
%   (b) Reserves scale with GDP (maintain 2x import coverage)
%   (c) Accelerated reserves (reach IEA 90-day target, scale with GDP)

R_oil_bar_0  = M_.params(strcmp(M_.param_names, 'R_oil_bar'));
R_coal_bar_0 = M_.params(strcmp(M_.param_names, 'R_coal_bar'));
ED_oil_bar_0 = M_.params(strcmp(M_.param_names, 'ED_oil_bar'));
ED_coal_bar_0= M_.params(strcmp(M_.param_names, 'ED_coal_bar'));

% Implied import growth: ED_c_bar grows with GDP
ED_oil_path  = ED_oil_bar_0  * (1 + g_Y).^t_growth;
ED_coal_path = ED_coal_bar_0 * (1 + g_Y).^t_growth;

% Coverage ratios (periods of import coverage)
cov_oil_fixed    = R_oil_bar_0  ./ ED_oil_path;   % no reserve scaling
cov_coal_fixed   = R_coal_bar_0 ./ ED_coal_path;
cov_oil_scaled   = R_oil_bar_0  ./ ED_oil_bar_0  * ones(T_growth+1, 1);  % proportional scaling
cov_oil_iea      = (3.0 * ED_oil_bar_0) ./ ED_oil_bar_0 * ones(T_growth+1, 1);  % IEA 90-day target

fprintf('  Oil SPR coverage today:  %.0f days\n', R_oil_bar_0/ED_oil_bar_0 * 365);
fprintf('  IEA 90-day target:       90 days\n');
fprintf('  Without scaling: coverage falls to %.0f days by t=30\n', ...
        cov_oil_fixed(end) * 365);

figure('Name', 'Vietnam: Reserve Adequacy Under Growth', 'Position', [100 100 900 400]);
sgtitle({'Vietnam Strategic Reserve Adequacy Under 6.5%% p.a. GDP Growth', ...
         'Q: Do reserves keep pace with the growing economy?'}, ...
        'FontWeight', 'bold', 'FontSize', 11);

subplot(1,2,1); hold on; grid on;
plot(t_growth, cov_oil_fixed * 365,  'b-',  'LineWidth', 2, 'DisplayName', 'Fixed reserves');
plot(t_growth, cov_oil_scaled * 365, 'g--', 'LineWidth', 2, 'DisplayName', 'GDP-scaled reserves');
yline(90,  'r:',  'LineWidth', 1.5, 'Label', 'IEA 90-day target');
yline(30,  'k--', 'LineWidth', 1,   'Label', 'Current SPR (~30 days)');
title('Oil SPR coverage (days)', 'FontWeight', 'bold');
xlabel('Periods'); ylabel('Days of import coverage');
legend('Location', 'northeast', 'FontSize', 9);
hold off;

subplot(1,2,2); hold on; grid on;
plot(t_growth, cov_coal_fixed * 365, 'b-',  'LineWidth', 2, 'DisplayName', 'Fixed reserves');
yline(45, 'r:',  'LineWidth', 1.5, 'Label', 'Target (45 days)');
title('Coal stockyard coverage (days)', 'FontWeight', 'bold');
xlabel('Periods'); ylabel('Days of import coverage');
legend('Location', 'northeast', 'FontSize', 9);
hold off;

fprintf('  Key insight: at 6.5%% growth, a fixed SPR loses ~50%% coverage in ~11 years.\n');
fprintf('  Policy: reserves must scale with GDP to maintain IEA adequacy standards.\n\n');
if isgraphics(wb_run), waitbar(0.60, wb_run, 'Step 3c: Energy Master Plan scenario...'); end

% ----------------------------------------------------------------
% Step 3c: Energy Master Plan VIII Scenario
%
%   Vietnam's Power Development Plan VIII (2023) and National Energy
%   Master Plan to 2050 (NEMP 2050) mandate:
%     - Coal: peak capacity ~2025-2030, then phase-down
%     - Renewables: 50% of electricity by 2030, 67-71% by 2050
%     - Gas/LNG: bridge fuel through ~2035
%
%   MODEL TRANSLATION:
%     - Coal phase-down: negative e_coal_shock path (imports below baseline)
%     - Renewables build-up: positive capacity investment (phi_IQ increase)
%       (EC_bar implicitly rises as clean energy replaces coal)
%
%   THREE SCENARIOS (deterministic, perfect_foresight_solver):
%     A. Coal phase-down only (no policy response):
%        → energy services fall → GDP loss → shows transition cost
%     B. Coal phase-down + high capacity investment (phi_IQ = 0.08):
%        → investment offsets efficiency losses → smaller GDP impact
%     C. Coal phase-down + reserves as buffer (phi_R = 1.0):
%        → coal reserves smooth the supply gap during transition
% ----------------------------------------------------------------
fprintf('\n=== STEP 3c: Energy Master Plan VIII — Coal Transition Scenario ===\n');
fprintf('  PDP VIII: coal capacity peak ~2025-2030, then phase-down.\n');
if MINIMAL_MODE
    fprintf('  Minimal run mode: scenario A only (phase-down only).\n\n');
else
    fprintf('  Comparing: A) phase-down only  B) high investment  C) use reserves\n\n');
end

T_emp    = 40;    % transition horizon (periods; ~10 yrs if quarterly, ~20 yrs if annual)
T_burn   = 5;     % pre-transition buffer (before coal decline starts)

options_emp        = options_;
options_emp.periods = T_emp;
oo_emp_base = perfect_foresight_setup(M_, options_emp, oo_);
exo_emp_base = oo_emp_base.exo_simul;

% Coal phase-down path: linearly decline by 40% from baseline over T_phase periods
% (PDP VIII: ~40% reduction in coal imports by 2040 vs. 2025)
T_phase       = 25;    % phase-down takes 25 periods
coal_decline  = 0.40 * ED_coal_bar_0;  % total decline magnitude
phase_ramp    = (1:T_phase)' / T_phase * coal_decline;   % linear ramp
e_coal_path   = zeros(T_emp, 1);
e_coal_path(T_burn+1 : T_burn+T_phase) = -phase_ramp;
e_coal_path(T_burn+T_phase+1 : end)    = -coal_decline;  % sustained decline

% Scenario parameter combinations
emp_scenarios = struct();
emp_scenarios(1).label  = 'A: Coal phase-down only';
emp_scenarios(1).phi_IQ = 0.04;   % baseline investment
emp_scenarios(1).phi_R  = 0.0;    % no reserve use
if ~MINIMAL_MODE
    emp_scenarios(2).label  = 'B: Phase-down + high investment';
    emp_scenarios(2).phi_IQ = 0.08;   % double investment (renewables build-out)
    emp_scenarios(2).phi_R  = 0.0;
    emp_scenarios(3).label  = 'C: Phase-down + reserve buffer';
    emp_scenarios(3).phi_IQ = 0.04;   % baseline investment
    emp_scenarios(3).phi_R  = 1.0;    % full reserve drawdown
end
N_emp = length(emp_scenarios);

results_emp = struct();
colors_emp  = {'b', 'g', 'r'};

phi_IQ_prev_emp = M_.params(idx_phi_IQ);
for kk = 1:N_emp
    M_.params(idx_phi_R)  = emp_scenarios(kk).phi_R;

    % Re-solve SS if phi_IQ changed (Q_c_bar depends on phi_IQ)
    if emp_scenarios(kk).phi_IQ ~= phi_IQ_prev_emp
        M_.params(idx_phi_IQ) = emp_scenarios(kk).phi_IQ;
        exo_ss_emp = zeros(1, M_.exo_nbr);
        [ys_emp, params_emp, ~] = ToyModelSOEMC_steadystate([], exo_ss_emp, M_, options_);
        oo_.steady_state = ys_emp;
        M_.params        = params_emp;
        phi_IQ_prev_emp  = emp_scenarios(kk).phi_IQ;
    end

    oo_emp_base_k = perfect_foresight_setup(M_, options_emp, oo_);
    exo_mat = oo_emp_base_k.exo_simul;
    for ci = 1:N_COMM
        c = COMM{ci};
        if strcmp(c, 'coal')
            exo_mat(2:T_emp+1, idx_ed.(c)) = e_coal_path;
        end
        % nu_c = 0 (deterministic scenario)
    end

    oo_run = oo_emp_base_k;
    oo_run.exo_simul = exo_mat;
    try
        [oo_run, ~] = perfect_foresight_solver(M_, options_emp, oo_run);
        results_emp(kk).C    = extract_var(oo_run, M_, 'C');
        results_emp(kk).EDS  = extract_var(oo_run, M_, 'E_D_service');
        results_emp(kk).R_coal = extract_var(oo_run, M_, 'R_coal');
        results_emp(kk).ok   = true;
        results_emp(kk).W    = compute_welfare(results_emp(kk).C, beta, min(T_emp-5, T_WELFARE));
    catch ME
        fprintf('  Scenario %s failed: %s\n', emp_scenarios(kk).label, ME.message);
        results_emp(kk).ok = false;
        results_emp(kk).W  = NaN;
    end
    fprintf('  %s  |  W = %.4f\n', emp_scenarios(kk).label, results_emp(kk).W);
end
if isgraphics(wb_run), waitbar(0.85, wb_run, 'Step 4/4: Joint optimal policy search...'); end

% Restore baseline parameters and SS
M_.params(idx_phi_R)  = 0.5;
M_.params(idx_phi_IQ) = 0.04;
exo_ss_restore = zeros(1, M_.exo_nbr);
[ys_base, params_base, ~] = ToyModelSOEMC_steadystate([], exo_ss_restore, M_, options_);
oo_.steady_state = ys_base;
M_.params        = params_base;

% --- Plot EMP scenarios ---
t_emp_show = 1:T_emp;
any_ok = any([results_emp.ok]);
if any_ok
    figure('Name', 'Energy Master Plan VIII — Coal Transition', ...
           'Position', [100 80 1100 440]);
    sgtitle({'Vietnam Energy Master Plan VIII: Coal Phase-Down Scenarios', ...
             sprintf('Coal imports decline %.0f%% over %d periods (PDP VIII implementation)', ...
                     100*coal_decline/ED_coal_bar_0, T_phase)}, ...
            'FontWeight', 'bold', 'FontSize', 11);

    % Panel 1: Consumption
    subplot(1,3,1); hold on; grid on;
    for kk = 1:N_emp
        if results_emp(kk).ok
            plot(t_emp_show, results_emp(kk).C(t_emp_show), ...
                 'LineWidth', 2, 'Color', colors_emp{kk}, ...
                 'DisplayName', emp_scenarios(kk).label);
        end
    end
    xline(T_burn+1,          'k--', 'LineWidth', 1, 'Label', 'Phase-down start');
    xline(T_burn+T_phase+1,  'k:',  'LineWidth', 1, 'Label', 'Phase-down complete');
    title('Consumption  C', 'FontWeight', 'bold');
    xlabel('Period'); ylabel('C');
    legend('Location', 'southwest', 'FontSize', 8, 'Interpreter', 'none');
    hold off;

    % Panel 2: Energy services
    subplot(1,3,2); hold on; grid on;
    for kk = 1:N_emp
        if results_emp(kk).ok
            plot(t_emp_show, results_emp(kk).EDS(t_emp_show), ...
                 'LineWidth', 2, 'Color', colors_emp{kk});
        end
    end
    xline(T_burn+1,         'k--', 'LineWidth', 1);
    xline(T_burn+T_phase+1, 'k:',  'LineWidth', 1);
    title('Energy Services  E\_D\_service', 'FontWeight', 'bold');
    xlabel('Period'); ylabel('E\_D\_service');
    hold off;

    % Panel 3: Coal reserves
    subplot(1,3,3); hold on; grid on;
    for kk = 1:N_emp
        if results_emp(kk).ok
            plot(t_emp_show, results_emp(kk).R_coal(t_emp_show), ...
                 'LineWidth', 2, 'Color', colors_emp{kk});
        end
    end
    R_coal_bar_val = M_.params(strcmp(M_.param_names, 'R_coal_bar'));
    yline(R_coal_bar_val, 'k:', 'LineWidth', 1, 'Label', 'R\_coal\_bar');
    xline(T_burn+1,         'k--', 'LineWidth', 1);
    xline(T_burn+T_phase+1, 'k:',  'LineWidth', 1);
    title('Coal Reserve Stock  R\_coal', 'FontWeight', 'bold');
    xlabel('Period'); ylabel('R\_coal');
    hold off;

    fprintf('\n  INTERPRETATION:\n');
    if MINIMAL_MODE
        fprintf('  Scenario A (minimal run): coal phase-down only baseline.\n\n');
    else
        fprintf('  A (no policy): coal phase-down creates energy service gap → C falls.\n');
        fprintf('  B (invest):    higher phi_IQ builds capacity faster → smaller C loss.\n');
        fprintf('  C (reserves):  coal SPR buffers the transition supply gap → C smoothed.\n');
        fprintf('  KEY INSIGHT: Energy Master Plan requires BOTH capacity investment AND\n');
        fprintf('  strategic reserves to navigate the coal-to-renewables transition.\n\n');
    end
end

% ----------------------------------------------------------------
% Step 4: Joint Optimal Policy
%
%   ECONOMIC LOGIC:
%     phi_R, phi_IQ, and d (reserve days) are JOINTLY determined.
%     They cannot be optimised sequentially because they interact:
%       - The value of drawdown (phi_R) depends on how large the stock is (d)
%       - The value of a large stock (d) depends on how well it can be used (phi_R)
%       - Capacity (phi_IQ) makes each unit of reserves more effective
%         (strategic complementarity: ES_c = E_D_c * (Q_c/Q_c_bar)^(1-alpha_Q))
%
%   METHOD: 3D Monte Carlo grid over (phi_R × phi_IQ × d)
%     - Storage cost is already IN the resource constraint (kappa_1*R + kappa_2*R^2)
%       so it already reduces C in every simulation draw.
%     - We simply maximise E[W(phi_R, phi_IQ, d)] over all three dimensions.
%     - No separate lambda_cost subtraction needed — it would double-count.
%
%   OUTPUT:
%     phi_R_star, phi_IQ_star, d_star written to workspace
%     M_.params updated with R_oil_bar*, R_coal_bar*, phi_IQ*, phi_R*
%     Plots: policy heatmap at d*; E[W] vs d curve; stock-drawdown interaction
% ----------------------------------------------------------------
fprintf('\n=== STEP 4: Joint Optimal Policy (phi_R x phi_IQ x d) ===\n');
fprintf('  Searching 3D grid: reserve level x drawdown x capacity investment.\n');
fprintf('  Storage cost is in the model resource constraint — maximising E[W] is correct.\n\n');
run('ToyModelSOEMC_joint_optimal.m');
if isgraphics(wb_run), waitbar(1.00, wb_run, 'Complete: ToyModelSOEMC_run finished.'); end

% Report optimal targets (written to workspace by joint_optimal.m)
ED_oil_val  = M_.params(strcmp(M_.param_names, 'ED_oil_bar'));
ED_coal_val = M_.params(strcmp(M_.param_names, 'ED_coal_bar'));
R_oil_star  = M_.params(strcmp(M_.param_names, 'R_oil_bar'));
R_coal_star = M_.params(strcmp(M_.param_names, 'R_coal_bar'));

fprintf('\n  JOINTLY OPTIMAL POLICY:\n');
fprintf('    d*          = %d days of import coverage\n', d_star);
fprintf('    phi_R*      = %.2f  (drawdown intensity)\n',   phi_R_star);
fprintf('    phi_IQ*     = %.2f  (capacity investment rate)\n', phi_IQ_star);
fprintf('    R_oil_bar*  = %.4f  (%.0f days of oil imports)\n', ...
        R_oil_star, R_oil_star / ED_oil_val * 365);
fprintf('    R_coal_bar* = %.4f  (%.0f days of coal imports)\n', ...
        R_coal_star, R_coal_star / ED_coal_val * 365);
fprintf('\n  WHY JOINT? phi_R* found at d_IEA differs from phi_R* found at d*.\n');
fprintf('  Larger stock → drawdown more sustainable → higher optimal phi_R.\n');
fprintf('  Higher phi_IQ → reserves more effective (Q_c keeps pace) → higher d*.\n');

fprintf('\n=== ToyModelSOEMC_run.m complete. ===\n');
