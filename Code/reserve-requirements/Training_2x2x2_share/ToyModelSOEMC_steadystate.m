function [ys, params, check] = ToyModelSOEMC_steadystate(~, exo, M_, ~)
% Steady-state solver for ToyModelSOEMC (multi-commodity SOE with capacity)
%
% COMMODITY LIST: must match @#define COMM in ToyModelSOEMC.mod
%   To add a commodity, append its name to both COMM here and in the .mod file.
%
% VARIABLE ORDER (matches .mod var declaration, per macroprocessor expansion):
%   Y C I K r w p_E  E_D_service E  NX
%   [for each c in COMM]: E_D_c_import  E_D_c  ES_c  Q_c  IQ_c  R_c  ToT_c
%
% KEY SS PROPERTIES:
%   - E_ss = 1.0 (same as original ToyModel: sum(ED_c_bar) + EC_bar = 0.75+0.25)
%   - K_ss, Y_ss: same formulas as original (MPK = r_ss, E_ss unchanged)
%   - C_ss = (1 - phi_IQ)*Y_ss - I_ss  (reduced by capacity investment)
%   - Q_c_ss = phi_IQ * Y_ss / (N_COMM * delta_Q)  [computed here, stored in params]
%   - ES_c = E_D_c = ED_c_bar in SS  (because Q_c(-1) = Q_c_bar by construction)

% ----------------------------------------------------------------
% COMMODITY LIST (must match @#define COMM in ToyModelSOEMC.mod)
% ----------------------------------------------------------------
COMM   = {'oil', 'coal'};
N_COMM = length(COMM);

% ----------------------------------------------------------------
% Extract parameters and exogenous values into structs
% ----------------------------------------------------------------
sp = struct();
for ii = 1:M_.param_nbr
    sp.(M_.param_names{ii}) = M_.params(ii);
end

se = struct();
for ii = 1:M_.exo_nbr
    se.(M_.exo_names{ii}) = exo(ii);
end

params = M_.params;
check  = 0;

% ----------------------------------------------------------------
% PART 1: Core production block (identical to original ToyModel)
%         E_ss = sum(ED_c_bar) + EC_bar = 0.75 + 0.25 = 1.0  (by calibration)
% ----------------------------------------------------------------

% Total dirty energy in SS = sum of baseline imports for each commodity
ED_total_ss = 0;
for ci = 1:N_COMM
    c = COMM{ci};
    ED_total_ss = ED_total_ss + sp.(['ED_' c '_bar']);
end

E_ss = ED_total_ss + sp.EC_bar;   % = 1.0 by calibration

% Steady-state rental rate from Euler equation
r_ss = 1/sp.beta + sp.delta - 1;

% Solve for capital from MPK = r_ss
%   MPK = A * alpha_K * K^(rho-1) * (CES)^(1/rho-1) = r_ss
%   K = [ r_ss/(A*alpha_K) ]^(rho/(1-rho)) / [alpha_L*L^rho + alpha_E*E^rho] ^(1/rho ... ) (implicit)
numerator   = (r_ss / (sp.A * sp.alpha_K))^(sp.rho / (1 - sp.rho)) - sp.alpha_K;
denominator = sp.alpha_L * sp.Lbar^sp.rho + sp.alpha_E * E_ss^sp.rho;
K_ss = (numerator / denominator)^(-1 / sp.rho);

I_ss = sp.delta * K_ss;
Y_ss = sp.A * (sp.alpha_K*K_ss^sp.rho + sp.alpha_L*sp.Lbar^sp.rho + sp.alpha_E*E_ss^sp.rho)^(1/sp.rho);

% Total storage cost in SS (quadratic, symmetric across commodities):
%   SC_per_comm = kappa_1 * R_c_bar + kappa_2 * R_c_bar^2
%   (kappa_1 = delta_R * p_D_bar by default calibration)
total_storage_cost_ss = 0;
for ci_tmp = 1:N_COMM
    c_tmp = COMM{ci_tmp};
    R_c_bar_tmp = sp.(['R_' c_tmp '_bar']);
    total_storage_cost_ss = total_storage_cost_ss + ...
        sp.kappa_1 * R_c_bar_tmp + sp.kappa_2 * R_c_bar_tmp^2;
end

% Resource constraint in SS: Y = C + I + phi_IQ*Y + total_storage_cost  (ToT = 0)
% => C = (1 - phi_IQ)*Y - I - total_storage_cost
C_ss = (1 - sp.phi_IQ) * Y_ss - I_ss - total_storage_cost_ss;

r_out = r_ss;
w_ss  = sp.A * sp.alpha_L * (sp.Lbar^(sp.rho-1)) * ...
        (sp.alpha_K*K_ss^sp.rho + sp.alpha_L*sp.Lbar^sp.rho + sp.alpha_E*E_ss^sp.rho)^(1/sp.rho - 1);
pE_ss = sp.A * sp.alpha_E * (E_ss^(sp.rho-1)) * ...
        (sp.alpha_K*K_ss^sp.rho + sp.alpha_L*sp.Lbar^sp.rho + sp.alpha_E*E_ss^sp.rho)^(1/sp.rho - 1);

% ----------------------------------------------------------------
% PART 2: Capacity steady state — compute Q_c_bar and store in params
%         Q_c_ss = phi_IQ * Y_ss / (N_COMM * delta_Q)
%         This is the level at which IQ_c_ss = delta_Q * Q_c_ss (zero net investment)
% ----------------------------------------------------------------
Q_c_ss = sp.phi_IQ * Y_ss / (N_COMM * sp.delta_Q);
IQ_c_ss = sp.phi_IQ * Y_ss / N_COMM;   % = delta_Q * Q_c_ss (consistent)

% Write Q_c_bar back into params (needed by ES_c equation in model)
for ci = 1:N_COMM
    c = COMM{ci};
    param_name = ['Q_' c '_bar'];
    idx = find(strcmp(M_.param_names, param_name));
    if ~isempty(idx)
        params(idx) = Q_c_ss;
    end
end

% ----------------------------------------------------------------
% PART 3: Per-commodity SS values (using exo values from initval/endval)
% ----------------------------------------------------------------
ED_service_ss = 0;
comm_blocks   = cell(N_COMM, 1);

for ci = 1:N_COMM
    c = COMM{ci};

    % Supply disruption exo (= 0 in SS); eps_c and R_c_draw are now endogenous
    e_shock  = se.(['e_' c '_shock']);    % = 0 in SS

    % Per-commodity SS values
    ED_c_bar = sp.(['ED_' c '_bar']);
    R_c_bar  = sp.(['R_' c '_bar']);

    % Endogenous states: eps_c = 0 (AR(1) at SS), R_c_draw = 0 (no shock => no release)
    eps_c    = 0;
    R_c_draw = 0;

    E_D_c_import = ED_c_bar + e_shock;        % = ED_c_bar
    E_D_c        = E_D_c_import + R_c_draw;   % = ED_c_bar
    % ES_c = E_D_c * (Q_c(-1)/Q_c_bar)^(1-alpha_Q) = ED_c_bar * 1 in SS
    ES_c    = E_D_c;                           % full efficiency in SS
    IQ_c    = IQ_c_ss;
    Q_c     = Q_c_ss;
    R_c     = R_c_bar;
    ToT_c   = eps_c * E_D_c_import;           % = 0

    ED_service_ss = ED_service_ss + ES_c;

    % Per-commodity block order matches .mod var declaration:
    %   eps_c  R_c_draw  E_D_c_import  E_D_c  ES_c  Q_c  IQ_c  R_c  ToT_c  (9 vars)
    comm_blocks{ci} = [eps_c; R_c_draw; E_D_c_import; E_D_c; ES_c; Q_c; IQ_c; R_c; ToT_c];
end

% Aggregate energy services
E_D_service_ss = ED_service_ss;   % should equal ED_total_ss = 0.75
E_out          = E_D_service_ss + sp.EC_bar;
NX_ss          = 0;

% ----------------------------------------------------------------
% PART 4: Assemble steady-state vector (must match var order in .mod)
%
% var order: Y C I K r w p_E  E_D_service E  NX
%            [for each c in COMM]: E_D_c_import E_D_c ES_c Q_c IQ_c R_c ToT_c
% ----------------------------------------------------------------
n_core     = 10;
n_per_comm = 9;   % eps_c R_c_draw E_D_c_import E_D_c ES_c Q_c IQ_c R_c ToT_c
ys = zeros(n_core + N_COMM * n_per_comm, 1);
ys(1:n_core) = [Y_ss; C_ss; I_ss; K_ss; r_out; w_ss; pE_ss; E_D_service_ss; E_out; NX_ss];

for ci = 1:N_COMM
    i0 = n_core + (ci-1)*n_per_comm + 1;
    i1 = n_core + ci*n_per_comm;
    ys(i0:i1) = comm_blocks{ci};
end

save('ToyModelSOEMC_steadystate.mat', 'ys', 'params');

end
