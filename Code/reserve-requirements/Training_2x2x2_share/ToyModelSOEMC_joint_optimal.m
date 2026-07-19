% ToyModelSOEMC_joint_optimal.m
% Joint Optimal Policy: Reserve Stock × Drawdown Rule × Capacity Investment
%
% ECONOMIC QUESTION:
%   What combination of (phi_R, phi_IQ, d) jointly maximises expected welfare?
%
%   These three dimensions are INTERDEPENDENT and must be optimised together:
%     d      = days of reserve coverage (sets R_oil_bar, R_coal_bar)
%              More reserves = better insurance BUT higher storage cost
%              (storage cost kappa_1*R + kappa_2*R^2 is in the resource constraint
%               so it already reduces C in every simulation draw — no double counting)
%     phi_R  = drawdown intensity (how aggressively reserves are released in a crisis)
%              Only valuable if the stock is large enough to sustain drawdown
%     phi_IQ = capacity investment rate (raises Q_c_bar, making reserves more effective)
%              Strategic complement: higher Q makes each unit of reserves worth more
%
%   JOINT OPTIMUM:
%     (phi_R*, phi_IQ*, d*) = argmax_{phi_R, phi_IQ, d}  E[W(phi_R, phi_IQ, d)]
%
%   NOTE: E[W] already accounts for storage costs through the model's resource constraint:
%     Y = C + I + sum_c(IQ_c + ToT_c + kappa_1*R_c(-1) + kappa_2*R_c(-1)^2)
%   So the objective is simply maximum expected welfare — no separate cost subtraction.
%
% APPROACH: Extended-path Monte Carlo on a 3-dimensional policy grid.
%   Outer loop: d (reserve level) — changes R_c_bar, requires SS re-solve
%     Middle loop: phi_IQ        — changes Q_c_bar, requires SS re-solve
%       Inner loop: phi_R        — no SS change
%         MC draws: N_MC_joint extended_path runs
%
% OUTPUT:
%   W_joint  : (N_d × N_phi_IQ × N_phi_R) matrix of mean welfare
%   Optimal (d*, phi_IQ*, phi_R*) written to workspace and M_.params updated
%
% HOW TO USE:
%   Called from ToyModelSOEMC_run.m (Step 4).
%   Requires M_, options_, oo_ in workspace (from dynare run).

% ----------------------------------------------------------------
% COMMODITY LIST  (must match @#define COMM in ToyModelSOEMC.mod)
% ----------------------------------------------------------------
COMM   = {'oil', 'coal'};
N_COMM = length(COMM);

% ----------------------------------------------------------------
% SETTINGS
% ----------------------------------------------------------------
beta        = 0.95;     % Vietnam calibration
T_MC        = 100;      % simulation length
T_WELFARE   = 80;       % welfare horizon

if ~exist('MINIMAL_MODE', 'var')
    MINIMAL_MODE = false;
end
if ~exist('TRAINING_MODE', 'var')
    TRAINING_MODE = false;
end

if MINIMAL_MODE
    N_MC_joint = 1;      % Fastest mode: one draw per point
else
    N_MC_joint = 40;     % Full mode
end

% ANNUAL MODEL — must use 'pf' with shock_gen Bernoulli crisis events.
% EP mode with Gaussian shocks is WRONG here: small per-period sigma → expected
% drawdown >> refill rate → stock depletes to 0 → insurance value = 0 (spurious result).
SIM_MODE = 'pf';

% ----------------------------------------------------------------
% POLICY GRIDS
%   d: days of import coverage (reserve level)
%      Expressed in days so results are directly interpretable.
%      R_c_bar(d) = (d/365) * ED_c_bar_c  [model units, annual]
%
%   phi_R:  [0, 0.5, 1.0]   — no/partial/full drawdown
%   phi_IQ: [0.02, 0.04, 0.08] — baseline, moderate, high (EMP VIII) investment
%
%   NOTE: d=0 excluded from phi_R variation (no stock to release);
%         phi_IQ_grid excludes 0 to avoid Q_c_bar=0 singularity.
% ----------------------------------------------------------------
if TRAINING_MODE
    d_grid      = [90, 365];
    phi_R_grid  = [0.5, 1.0];
    phi_IQ_grid = [0.04, 0.08];
elseif MINIMAL_MODE
    d_grid      = [90];
    phi_R_grid  = [0.5];
    phi_IQ_grid = [0.04];
else
    d_grid      = [30, 90, 180, 365, 730, 1095, 1460, 1825];
    phi_R_grid  = [0, 0.5, 1.0];
    phi_IQ_grid = [0.02, 0.04, 0.08];
end

N_d      = length(d_grid);
N_phi_R  = length(phi_R_grid);
N_phi_IQ = length(phi_IQ_grid);

% ----------------------------------------------------------------
% Parameter indices
% ----------------------------------------------------------------
idx_phi_R  = find(strcmp(M_.param_names, 'phi_R'));
idx_phi_IQ = find(strcmp(M_.param_names, 'phi_IQ'));

% ED_c_bar values (annual import volumes)
ED_c_bar = struct();
for ci = 1:N_COMM
    c = COMM{ci};
    ED_c_bar.(c) = M_.params(strcmp(M_.param_names, ['ED_' c '_bar']));
end

% ----------------------------------------------------------------
% Solver options
% ----------------------------------------------------------------
options_ep            = options_;
options_ep.ep.periods   = 100;
options_ep.ep.verbosity = 0;

options_pf = options_;
options_pf.periods = T_MC;
PF_HOMOTOPY_STEPS = 5;   % Default continuation steps per PF draw

% ----------------------------------------------------------------
% Storage
% ----------------------------------------------------------------
W_joint  = NaN(N_d, N_phi_IQ, N_phi_R);   % mean welfare at each grid point
n_failed = zeros(N_d, N_phi_IQ, N_phi_R);

total_calls = N_d * N_phi_IQ * N_phi_R * N_MC_joint;
fprintf('\n=== JOINT OPTIMAL POLICY: Reserve Stock × Drawdown × Capacity ===\n\n');
fprintf('  Grid:  d = [%s] days\n', num2str(d_grid));
fprintf('         phi_R  = [%s]\n', num2str(phi_R_grid,  '%.2f '));
fprintf('         phi_IQ = [%s]\n', num2str(phi_IQ_grid, '%.2f '));
fprintf('  N_MC = %d draws per point  |  Total EP calls: %d\n\n', N_MC_joint, total_calls);
fprintf('  (Storage cost is in the resource constraint — maximising E[W] is correct.)\n\n');

% ----------------------------------------------------------------
% OUTER LOOP: d (reserve level)
%   Sets R_c_bar(d) for all commodities proportionally to import volume.
%   Re-solved in each phi_IQ iteration (SS depends on both d and phi_IQ).
% ----------------------------------------------------------------
for di = 1:N_d
    d = d_grid(di);
    R_d = struct();
    for ci = 1:N_COMM
        c = COMM{ci};
        R_d.(c) = (d / 365) * ED_c_bar.(c);
        M_.params(strcmp(M_.param_names, ['R_' c '_bar'])) = R_d.(c);
    end

    fprintf('--- d = %4d days  (R_oil=%.3f, R_coal=%.3f) ---\n', ...
            d, R_d.oil, R_d.coal);

    % ----------------------------------------------------------------
    % MIDDLE LOOP: phi_IQ
    %   Re-solve SS at each phi_IQ (Q_c_bar depends on phi_IQ and Y_ss).
    %   C_ss also changes with phi_IQ (capacity investment diverts output).
    % ----------------------------------------------------------------
    phi_IQ_prev = -1;
    for ii = 1:N_phi_IQ
        phi_IQ = phi_IQ_grid(ii);

        M_.params(idx_phi_IQ) = phi_IQ;
        exo_ss = zeros(1, M_.exo_nbr);
        [ys_ij, params_ij, ~] = ToyModelSOEMC_steadystate([], exo_ss, M_, options_ep);
        oo_.steady_state = ys_ij;
        M_.params        = params_ij;

        if strcmp(SIM_MODE, 'pf')
            oo_ = perfect_foresight_setup(M_, options_pf, oo_);
        end

        C_ss_ij = ys_ij(strcmp(M_.endo_names, 'C'));
        fprintf('  phi_IQ=%.2f  C_ss=%.4f  Q_oil_bar=%.4f\n', phi_IQ, C_ss_ij, ...
                M_.params(strcmp(M_.param_names, 'Q_oil_bar')));

        % ----------------------------------------------------------------
        % INNER LOOP: phi_R
        %   No SS change — just varies the drawdown response rule.
        % ----------------------------------------------------------------
        for jj = 1:N_phi_R
            phi_R = phi_R_grid(jj);
            M_.params(idx_phi_R) = phi_R;

            W_draws = NaN(N_MC_joint, 1);
            n_fail_ij = 0;

            for kk = 1:N_MC_joint
                try
                    if strcmp(SIM_MODE, 'ep')
                        extended_path([], T_MC, options_ep, M_, oo_);
                        C_path = extract_var(oo_, M_, 'C');
                    else
                        exo_mat = ToyModelSOEMC_shock_gen(M_, oo_, T_MC, COMM, struct());
                        [oo_run, ~] = ToyModelSOEMC_pf_homotopy_solve(M_, options_pf, oo_, exo_mat, PF_HOMOTOPY_STEPS);
                        C_path = extract_var(oo_run, M_, 'C');
                    end
                    W_draws(kk) = compute_welfare(C_path, beta, T_WELFARE);
                catch
                    n_fail_ij = n_fail_ij + 1;
                end
            end

            W_joint(di, ii, jj)  = mean(W_draws, 'omitnan');
            n_failed(di, ii, jj) = n_fail_ij;

            fprintf('    phi_R=%.1f  E[W]=%.4f  (fail:%d/%d)\n', ...
                    phi_R, W_joint(di,ii,jj), n_fail_ij, N_MC_joint);
        end
    end
end

% Restore calibration defaults
M_.params(idx_phi_R)  = 0.5;
M_.params(idx_phi_IQ) = 0.04;

% ----------------------------------------------------------------
% FIND JOINT OPTIMUM
% ----------------------------------------------------------------
[W_max, idx_best] = max(W_joint(:));
[di_opt, ii_opt, jj_opt] = ind2sub(size(W_joint), idx_best);

d_opt      = d_grid(di_opt);
phi_IQ_opt = phi_IQ_grid(ii_opt);
phi_R_opt  = phi_R_grid(jj_opt);

R_oil_opt  = (d_opt / 365) * ED_c_bar.oil;
R_coal_opt = (d_opt / 365) * ED_c_bar.coal;

% ----------------------------------------------------------------
% WRITE OPTIMAL VALUES TO M_.params AND RE-SOLVE SS
% ----------------------------------------------------------------
M_.params(strcmp(M_.param_names, 'R_oil_bar'))  = R_oil_opt;
M_.params(strcmp(M_.param_names, 'R_coal_bar')) = R_coal_opt;
M_.params(idx_phi_IQ) = phi_IQ_opt;
M_.params(idx_phi_R)  = phi_R_opt;

[ys_opt, params_opt, ~] = ToyModelSOEMC_steadystate([], zeros(1,M_.exo_nbr), M_, options_ep);
oo_.steady_state = ys_opt;
M_.params        = params_opt;

% Store optimal policy in workspace for downstream scripts
phi_R_star  = phi_R_opt;
phi_IQ_star = phi_IQ_opt;
d_star      = d_opt;

% ----------------------------------------------------------------
% CONSOLE RESULTS
% ----------------------------------------------------------------
fprintf('\n  ============================================================\n');
fprintf('  JOINT OPTIMAL POLICY (Vietnam, annual model)\n');
fprintf('  ============================================================\n');
fprintf('  Reserve stock:     d* = %d days of import coverage\n', d_opt);
fprintf('                     R_oil_bar*  = %.4f  (annual model units)\n', R_oil_opt);
fprintf('                     R_coal_bar* = %.4f  (annual model units)\n', R_coal_opt);
fprintf('  Drawdown rule:     phi_R*  = %.2f\n', phi_R_opt);
fprintf('  Capacity invest.:  phi_IQ* = %.2f\n', phi_IQ_opt);
fprintf('  E[W] at optimum: %.4f\n', W_max);
fprintf('\n  Interpretation:\n');
fprintf('  The jointly optimal policy requires BOTH adequate reserves AND\n');
fprintf('  sufficient installed capacity. Sub-optimal on either dimension\n');
fprintf('  reduces the welfare gain from the other (strategic complementarity).\n\n');

% ----------------------------------------------------------------
% SAVE RESULTS TO TEXT FILE  (read by make_slides.m and LaTeX update)
% ----------------------------------------------------------------
C_ss_opt  = ys_opt(strcmp(M_.endo_names, 'C'));
k1        = M_.params(strcmp(M_.param_names, 'kappa_1'));
k2        = M_.params(strcmp(M_.param_names, 'kappa_2'));
cost_oil  = k1 * R_oil_opt  + k2 * R_oil_opt^2;
cost_coal = k1 * R_coal_opt + k2 * R_coal_opt^2;
cost_pct  = (cost_oil + cost_coal) / C_ss_opt * 100;

% Benefit vs zero-reserve baseline (compute E[W] at d=0 for reference)
W_zero   = W_joint(1, ii_opt, 1);     % smallest d, phi_R=0 ≈ no-reserve benchmark
lambda_b = (exp((W_max - W_zero) * (1 - beta)) - 1) * 100;

res_fid = fopen('joint_optimal_results.txt', 'w');
fprintf(res_fid, 'd_star         = %d\n',      d_opt);
fprintf(res_fid, 'phi_R_star     = %.2f\n',    phi_R_opt);
fprintf(res_fid, 'phi_IQ_star    = %.2f\n',    phi_IQ_opt);
fprintf(res_fid, 'R_oil_star     = %.4f\n',    R_oil_opt);
fprintf(res_fid, 'R_coal_star    = %.4f\n',    R_coal_opt);
fprintf(res_fid, 'R_oil_days     = %.0f\n',    R_oil_opt / ED_c_bar.oil * 365);
fprintf(res_fid, 'R_coal_days    = %.0f\n',    R_coal_opt / ED_c_bar.coal * 365);
fprintf(res_fid, 'EW_opt         = %.4f\n',    W_max);
fprintf(res_fid, 'EW_zero        = %.4f\n',    W_zero);
fprintf(res_fid, 'storage_cost_pct = %.3f\n',  cost_pct);
fprintf(res_fid, 'lambda_benefit_pct = %.3f\n',lambda_b);
fprintf(res_fid, 'C_ss           = %.4f\n',    C_ss_opt);
fprintf(res_fid, 'Y_ss           = %.4f\n',    ys_opt(strcmp(M_.endo_names, 'Y')));
fprintf(res_fid, 'Q_oil_star     = %.4f\n',    M_.params(strcmp(M_.param_names, 'Q_oil_bar')));
fprintf(res_fid, 'Q_coal_star    = %.4f\n',    M_.params(strcmp(M_.param_names, 'Q_coal_bar')));
fprintf(res_fid, 'kappa_1        = %.4f\n',    k1);
fprintf(res_fid, 'kappa_2        = %.4f\n',    k2);
fprintf(res_fid, 'N_MC           = %d\n',      N_MC_joint);
fprintf(res_fid, 'N_d            = %d\n',      N_d);
fclose(res_fid);

fprintf('  Results saved to: joint_optimal_results.txt\n\n');

% ----------------------------------------------------------------
% FIGURE 1: Heatmap of E[W] at optimal d*
%   Shows phi_R × phi_IQ trade-off at the optimal reserve level.
% ----------------------------------------------------------------
figure('Name', 'Joint Optimal: Policy Heatmap at d*', 'Position', [80 80 700 520]);

W_slice = squeeze(W_joint(di_opt, :, :));   % N_phi_IQ × N_phi_R at optimal d
imagesc(phi_R_grid, phi_IQ_grid, W_slice);
colorbar;
xlabel('\phi_R  (drawdown intensity)', 'FontSize', 12);
ylabel('\phi_{IQ}  (capacity investment rate)', 'FontSize', 12);
title({sprintf('E[W] at optimal d^* = %d days of coverage', d_opt), ...
       sprintf('Optimal: \\phi_R^* = %.2f,  \\phi_{IQ}^* = %.2f', phi_R_opt, phi_IQ_opt)}, ...
      'FontWeight', 'bold', 'FontSize', 12);
set(gca, 'XTick', phi_R_grid, 'YTick', phi_IQ_grid, ...
         'XTickLabel', arrayfun(@(x) sprintf('%.2f',x), phi_R_grid, 'UniformOutput',false), ...
         'YTickLabel', arrayfun(@(x) sprintf('%.2f',x), phi_IQ_grid, 'UniformOutput',false));
hold on;
scatter(phi_R_opt, phi_IQ_opt, 250, 'g', 'filled', 'MarkerEdgeColor', 'k', ...
        'LineWidth', 2, 'DisplayName', 'Optimal (\\phi_R^*, \\phi_{IQ}^*)');
text(phi_R_opt, phi_IQ_opt, sprintf('  (%.2f, %.2f)', phi_R_opt, phi_IQ_opt), ...
     'Color', 'w', 'FontWeight', 'bold', 'FontSize', 11, 'VerticalAlignment', 'bottom');
hold off;
grid on;

% ----------------------------------------------------------------
% FIGURE 2: E[W] vs d at optimal (phi_R*, phi_IQ*)
%   Shows the reserve sizing dimension — how much stock matters.
% ----------------------------------------------------------------
figure('Name', 'Joint Optimal: Welfare vs Reserve Level', 'Position', [100 100 750 500]);

W_d_curve = squeeze(W_joint(:, ii_opt, jj_opt));   % N_d vector at optimal policy

plot(d_grid, W_d_curve, '-o', 'Color', [0.18 0.44 0.71], 'LineWidth', 2.5, ...
     'MarkerFaceColor', [0.18 0.44 0.71], 'MarkerSize', 8);
hold on;
scatter(d_opt, W_max, 200, [0.13 0.60 0.33], 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
xline(d_opt, '--', 'Color', [0.13 0.60 0.33], 'LineWidth', 2, ...
      'Label', sprintf('  d^* = %d days', d_opt));
xline(90,   ':', 'Color', [0.18 0.44 0.71], 'LineWidth', 1.5, 'Label', '  IEA 90d');
xline(365,  'k--', 'LineWidth', 1, 'Label', '  1yr');
xline(1825, 'k:',  'LineWidth', 1, 'Label', '  5yr');
hold off;

xlabel('Days of import coverage  d', 'FontSize', 12);
ylabel('Expected welfare  E[W]', 'FontSize', 12);
title({sprintf('E[W] vs Reserve Level  at  \\phi_R^*=%.2f, \\phi_{IQ}^*=%.2f', ...
               phi_R_opt, phi_IQ_opt), ...
       'Storage cost is in resource constraint — E[W] is the correct criterion'}, ...
      'FontWeight', 'bold', 'FontSize', 12);
grid on;

% ----------------------------------------------------------------
% FIGURE 3: E[W] vs d for all phi_R values at optimal phi_IQ*
%   Shows interaction between stock level and drawdown policy.
% ----------------------------------------------------------------
figure('Name', 'Joint Optimal: Stock-Drawdown Interaction', 'Position', [120 120 800 500]);

phi_R_colors = {[0.80 0.15 0.15], [0.18 0.44 0.71], [0.13 0.60 0.33]};
hold on; grid on;
for jj = 1:N_phi_R
    W_curve_jj = squeeze(W_joint(:, ii_opt, jj));
    plot(d_grid, W_curve_jj, '-o', 'Color', phi_R_colors{jj}, 'LineWidth', 2.2, ...
         'MarkerFaceColor', phi_R_colors{jj}, 'MarkerSize', 7, ...
         'DisplayName', sprintf('\\phi_R = %.2f', phi_R_grid(jj)));
end
xline(d_opt, '--', 'Color', [0.13 0.60 0.33], 'LineWidth', 2, ...
      'Label', sprintf('  d^* = %d days', d_opt));
xline(90, ':', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.5, 'Label', '  IEA 90d');
scatter(d_opt, W_max, 200, [0.13 0.60 0.33], 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
hold off;

xlabel('Days of import coverage  d', 'FontSize', 12);
ylabel('Expected welfare  E[W]', 'FontSize', 12);
title({sprintf('Stock Level × Drawdown Policy  (at \\phi_{IQ}^* = %.2f)', phi_IQ_opt), ...
       'Higher \\phi_R is more valuable when the stock is large enough to sustain drawdown'}, ...
      'FontWeight', 'bold', 'FontSize', 12);
legend('Location', 'southeast', 'FontSize', 11);

fprintf('=== Joint optimal policy analysis complete. ===\n\n');
