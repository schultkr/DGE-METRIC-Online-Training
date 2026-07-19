function v = get_ss(oo_, M_, var_name)
% Return steady-state value of an endogenous variable by name.
idx = find(strcmp(M_.endo_names, var_name), 1);
if isempty(idx)
    error('get_ss:UnknownVariable', 'Variable %s not found in M_.endo_names.', var_name);
end
if ~isfield(oo_, 'steady_state') || isempty(oo_.steady_state)
    error('get_ss:MissingSteadyState', 'oo_.steady_state is missing or empty.');
end
v = oo_.steady_state(idx);
end
