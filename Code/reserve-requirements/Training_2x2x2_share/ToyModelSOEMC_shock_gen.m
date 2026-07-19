function exo_mat = ToyModelSOEMC_shock_gen(M_, oo_, T_MC, COMM, params_mc)
% Generate a random shock path for one Monte Carlo draw (PF-solver mode).
%
% Used when SIM_MODE = 'pf' in ToyModelSOEMC_montecarlo.m / _optimal_stock.m.
% Extended_path mode draws its own shocks internally; this function is only
% needed for the perfect-foresight fallback.
%
% NEW EXOGENOUS STRUCTURE (2 per commodity):
%   nu_c      : iid Gaussian innovation to the AR(1) price state eps_c.
%               The AR(1) is in the model: eps_c = rho_p*eps_c(-1) + nu_c.
%               sigma_nu (default 0.17) matches the shocks block in the .mod file.
%   e_c_shock : supply disruption (negative = shortfall).
%               Step-function: Bernoulli onset (p_dis=0.04), Geometric duration
%               (p_end=0.20), magnitude Uniform(0.2, 0.5)*ED_c_bar.
%               This is more persistent than the iid shocks block approximation,
%               making PF-mode results more interesting for comparison.
%
% NOTE: phi_R is no longer an argument — drawdown R_c_draw is endogenous
% in the model (model equation: R_c_draw = phi_R*max(0,-e_c_shock) + ...).
% The parameter phi_R is set in M_.params before calling the PF solver.
%
% INPUTS:
%   M_, oo_   : Dynare model and results structs
%   T_MC      : simulation length (shock periods)
%   COMM      : commodity names, e.g. {'oil', 'coal'}
%   params_mc : optional struct overriding shock parameters:
%       sigma_nu    (default 0.17)  std of price AR(1) innovation
%       p_dis       (default 0.04)  supply disruption onset probability
%       p_end       (default 0.20)  supply disruption end probability
%       dis_lo      (default 0.20)  min disruption depth (fraction of ED_c_bar)
%       dis_hi      (default 0.50)  max disruption depth
%
% OUTPUT:
%   exo_mat : (T_MC+2) x M_.exo_nbr matrix, assign to oo_run.exo_simul

% ----------------------------------------------------------------
% Default parameters
% ----------------------------------------------------------------
if nargin < 5 || isempty(params_mc)
    params_mc = struct();
end
mc = struct();
mc.sigma_nu = getf(params_mc, 'sigma_nu', 0.17);  % Std. dev. of iid price innovation nu_c
mc.p_dis    = getf(params_mc, 'p_dis',    0.04);  % Probability a new supply crisis starts in a period
mc.p_end    = getf(params_mc, 'p_end',    0.20);  % Probability an ongoing crisis ends in a period
mc.dis_lo   = getf(params_mc, 'dis_lo',   0.20);  % Minimum crisis depth as share of ED_c_bar
mc.dis_hi   = getf(params_mc, 'dis_hi',   0.50);  % Maximum crisis depth as share of ED_c_bar

% ----------------------------------------------------------------
% Extract model parameters
% ----------------------------------------------------------------
sp = struct();
for ii = 1:M_.param_nbr
    sp.(M_.param_names{ii}) = M_.params(ii);
end
N_COMM = length(COMM);

% ----------------------------------------------------------------
% Start from baseline (SS exo values throughout)
% ----------------------------------------------------------------
exo_mat = oo_.exo_simul;

% Column indices for each exo variable
idx_nu = zeros(1, N_COMM);
idx_ed = zeros(1, N_COMM);
for ci = 1:N_COMM
    c = COMM{ci};
    idx_nu(ci) = find(strcmp(M_.exo_names, ['nu_' c]));
    idx_ed(ci) = find(strcmp(M_.exo_names, ['e_' c '_shock']));
end

T_rows = size(exo_mat, 1);
T_use  = min(T_MC, T_rows - 2);

% ----------------------------------------------------------------
% Generate shocks per commodity (rows 2..T+1)
% ----------------------------------------------------------------
for ci = 1:N_COMM
    c = COMM{ci};
    ED_c_bar = sp.(['ED_' c '_bar']);

    % --- nu_c: iid Gaussian innovations to the price AR(1) ---
    nu_path = mc.sigma_nu * randn(T_use, 1);

    % --- e_c_shock: step-function supply disruptions ---
    e_path    = zeros(T_use, 1);
    in_crisis = false;
    dis_size  = 0;
    for t = 1:T_use
        if ~in_crisis
            if rand < mc.p_dis
                in_crisis = true;
                dis_size  = -(mc.dis_lo + (mc.dis_hi - mc.dis_lo)*rand) * ED_c_bar;
            end
        else
            if rand < mc.p_end
                in_crisis = false;
                dis_size  = 0;
            end
        end
        e_path(t) = dis_size;
    end

    exo_mat(2:T_use+1, idx_nu(ci)) = nu_path;
    exo_mat(2:T_use+1, idx_ed(ci)) = e_path;
end

end

function v = getf(s, fname, default)
    if isfield(s, fname)
        v = s.(fname);
    else
        v = default;
    end
end
