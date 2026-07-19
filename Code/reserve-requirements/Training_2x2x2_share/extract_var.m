function x = extract_var(oo_, M_, var_name)
% Extract a simulated endogenous path by variable name.
idx = find(strcmp(M_.endo_names, var_name), 1);
if isempty(idx)
    error('extract_var:UnknownVariable', 'Variable %s not found in M_.endo_names.', var_name);
end

if isfield(oo_, 'endo_simul') && ~isempty(oo_.endo_simul)
    x = oo_.endo_simul(idx, :)';
    return;
end

if isfield(oo_, 'steady_state') && ~isempty(oo_.steady_state)
    x = oo_.steady_state(idx);
    return;
end

error('extract_var:NoSimulationData', 'Neither oo_.endo_simul nor oo_.steady_state is available.');
end
