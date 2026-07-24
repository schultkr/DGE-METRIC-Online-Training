function ds = dynamic_set_auxiliary_series(ds, params)
%
% Computes auxiliary variables of the dynamic model
%
ds.AUX_ENDO_LEAD_1131=ds.BG_1(1);
ds.AUX_ENDO_LAG_424_1=ds.B_1(-1);
ds.AUX_ENDO_LAG_443_1=ds.PE_1(-1);
end
