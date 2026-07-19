function [oo_out, success] = ToyModelSOEMC_pf_homotopy_solve(M_, options_pf, oo_base, exo_target, n_steps)
% Solve a PF path using a simple shock-scaling homotopy.
%
% The solver first solves at 1/n_steps of the target shocks, then 2/n_steps,
% ..., until full shocks. This often improves robustness for hard draws.

if nargin < 5 || isempty(n_steps)
    n_steps = 5;
end

if n_steps < 1
    n_steps = 1;
end

oo_out  = oo_base;
success = false;

exo_base = oo_base.exo_simul;

for step = 1:n_steps
    lambda = step / n_steps;

    % Use previous solved step as warm start for the next continuation step.
    oo_step = oo_out;
    oo_step.exo_simul = exo_base + lambda * (exo_target - exo_base);

    [oo_step, ~] = perfect_foresight_solver(M_, options_pf, oo_step);
    oo_out = oo_step;
end

success = true;
end
