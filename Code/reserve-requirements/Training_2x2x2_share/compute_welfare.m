function W = compute_welfare(C_path, beta, T_welfare)
% Welfare metric: sum_{t=0}^{T-1} beta^t * log(C_t).
if nargin < 3 || isempty(T_welfare)
    T_welfare = numel(C_path);
end

c = C_path(:);
T = min(T_welfare, numel(c));
if T == 0
    W = NaN;
    return;
end

% Guard against log(0) or negative consumption from failed paths.
c_eff = max(c(1:T), 1e-12);
beta_vec = beta .^ (0:T-1)';
W = sum(beta_vec .* log(c_eff));
end
