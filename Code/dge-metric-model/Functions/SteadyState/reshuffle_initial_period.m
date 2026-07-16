function oo_ = reshuffle_initial_period(oo_, M_, posIdx, inbregions_p, imaxsec_p, tabtargets) %#ok<INUSL>
% RESHUFFLE_INITIAL_PERIOD  Bottom-up reshuffle of the initial-period (col 1
% of oo_.endo_simul) national-accounts flows so investment matches
% user-supplied data targets, and every other flow (consumption,
% government expenditure, net exports, external debt) is re-derived
% consistently from those targets by re-running the same steady-state
% accounting routines used during calibration (setup_initial_state.m,
% steps V-VII).
%
% WHAT IS TARGETED
%   Investment is the only variable set directly by the user, and it is
%   set bottom-up: by economic activity (subsector) AND by source
%   (private household, FDI, public), each expressed as a ratio of
%   nominal investment to nominal regional GDP (Y_<reg> is already a
%   nominal quantity in this model's units):
%
%       tabtargets.IH_<subsec>_<reg>   = I_H_<subsec>_<reg>*P_INV_<subsec>_<reg>   / Y_<reg>
%       tabtargets.IFDI_<subsec>_<reg> = I_FDI_<subsec>_<reg>*P_INV_<subsec>_<reg> / Y_<reg>
%       tabtargets.IG_<subsec>_<reg>   = I_G_<subsec>_<reg>*P_INV_<subsec>_<reg>   / Y_<reg>
%
%   <subsec> is the subsector index (economic activity; e.g. in the
%   current 5-subsector configuration: 1 Primary, 2 Fossil, 3 Renewables,
%   4 Secondary, 5 Tertiary) and <reg> the region index. A field that is
%   absent or NaN leaves that source's investment at its current
%   (pre-reshuffle) model value - generalizing the old
%   targetCY/targetIY/targetGY==0 "keep SS" convention to per-source,
%   per-activity granularity.
%
%   Example:
%       tabtargets.IFDI_3_1 = 0.015;  % FDI into region 1 Renewables = 1.5% of regional GDP
%       tabtargets.IG_1_1   = 0.02;   % Public investment into region 1 Primary = 2% of regional GDP
%       oo_ = reshuffle_initial_period(oo_, M_, posIdx, inbregions_p, imaxsec_p, tabtargets);
%
% WHAT IS DERIVED (bottom-up, by reusing steady-state accounting functions)
%   1. I_<subsec>_<reg> = I_H_<subsec>_<reg> + I_FDI_<subsec>_<reg>          (firms.mod identity)
%   2. Regional/national aggregate investment I_<reg>, I                     compute_aggregates.m
%   3. Regional public investment I_G_<reg> (incl. adaptation G_A)           compute_regional_economic_accounts.m
%   4. Regional/national consumption C_<reg>, C (household budget residual)  compute_regional_economic_accounts.m
%   5. Regional/national government expenditure G_<reg>, G (goods-market     compute_government_expenditure_and_capital.m
%      resource-constraint residual, given C, I, I_G above)
%   6. Regional net exports NX_<reg>, external position B_<reg>/B and        compute_regional_economic_accounts.m
%      exchange-rate index s_<reg> (these respond only through the FDI
%      income/outflow term; goods-market NX itself does not depend on the
%      domestic C/I/G mix in this model)
%   7. Regional public debt BG_<reg> closes the regional government budget
%      constraint (government.mod), using the ORIGINAL (pre-reshuffle)
%      BG_<reg> and s_<reg> as the "lagged" state and the newly reshuffled
%      C_<reg>/G_<reg>/I_G_<reg> plus reused tax income
%      (compute_tax_income.m) on the revenue side.
%
% WHAT IS NOT CHANGED
%   K_<subsec>_<reg> (and its K_H/K_FDI/K_G split), KG_<reg>, H_<reg>,
%   prices, wages, lambda and productivity: only the flow/accounting side
%   is re-derived.

    if nargin < 6 || isempty(tabtargets)
        tabtargets = struct();
    end

    %% Parameters into struct
    paramNames = cellstr(M_.param_names);
    for ii = 1:M_.param_nbr
        strpar.(paramNames{ii}) = M_.params(ii);
    end

    %% Endogenous variables (initial period) into struct
    endoNames = cellstr(M_.endo_names);
    endoIndex = containers.Map(endoNames, num2cell(1:numel(endoNames)));
    ys = oo_.endo_simul(:, 1);
    for ii = 1:M_.endo_nbr
        strys.(endoNames{ii}) = ys(ii);
    end
    strys_pre = strys;  % pre-reshuffle snapshot; used as the "lagged" state for BG below

    %% Exogenous variables (initial period) into struct
    exoNames = cellstr(M_.exo_names);
    exo0 = oo_.exo_simul(1, :);
    for ii = 1:M_.exo_nbr
        strexo.(exoNames{ii}) = exo0(ii);
    end

    %% 1. Bottom-up investment targets, by economic activity (subsector) and source
    anyTarget = false;
    namesToWrite = {};
    for icoreg = 1:inbregions_p
        sreg = num2str(icoreg);
        YnomReg = strys.(['Y_' sreg]);

        for icosec = 1:strpar.inbsectors_p
            ssec = num2str(icosec);
            for icosubsec = strpar.(['substart_' ssec '_p']):strpar.(['subend_' ssec '_p'])
                ssubsec = num2str(icosubsec);
                stemp = [ssubsec '_' sreg];
                PINV = strys.(['P_INV_' stemp]);

                tH   = local_target(tabtargets, ['IH_'   stemp]);
                tFDI = local_target(tabtargets, ['IFDI_' stemp]);
                tG   = local_target(tabtargets, ['IG_'   stemp]);

                if isfinite(tH)
                    strys.(['I_H_' stemp]) = tH * YnomReg / PINV;
                    anyTarget = true;
                end
                if isfinite(tFDI)
                    strys.(['I_FDI_' stemp]) = tFDI * YnomReg / PINV;
                    anyTarget = true;
                end
                if isfinite(tG)
                    strys.(['I_G_' stemp]) = tG * YnomReg / PINV;
                    anyTarget = true;
                end

                % firms.mod identity: total private + FDI investment flow.
                strys.(['I_' stemp]) = strys.(['I_H_' stemp]) + strys.(['I_FDI_' stemp]);

                namesToWrite = [namesToWrite, {['I_H_' stemp], ['I_FDI_' stemp], ...
                    ['I_G_' stemp], ['I_' stemp]}]; %#ok<AGROW>
            end
        end
    end

    if ~anyTarget
        return
    end

    %% 2-6. Bottom-up aggregation, reusing the calibration accounting pipeline
    % (same call order as setup_initial_state.m, steps V-VII)
    [strys, strpar, strexo] = compute_aggregates(strys, strpar, strexo);
    [strys, strpar]         = compute_regional_imports_and_demand(strys, strpar);
    [strys, strpar, strexo] = compute_tax_income(strys, strpar, strexo);
    [strys, strpar, strexo] = compute_regional_economic_accounts(strys, strpar, strexo);
    strys = compute_government_expenditure_and_capital(strys, strpar);

    %% 7. Close each region's government budget constraint for BG
    for icoreg = 1:inbregions_p
        sreg = num2str(icoreg);

        phiBGext = strpar.(['phi_BG_ext_' sreg '_p']) + strexo.(['exo_phi_BG_ext_' sreg]);
        BG_lag   = strys_pre.(['BG_' sreg]);
        s_lag    = strys_pre.(['s_' sreg]);

        revenue = strys.(['tauC_' sreg]) * strys.(['P_' sreg]) * strys.(['C_' sreg]) ...
            + strys.(['IH_' sreg]) * strys.(['PH_' sreg]) * strys.(['tauH_' sreg]) ...
            + strys.(['PE_' sreg]) * strys.(['E_' sreg]) ...
            + strys.(['capitaltax_' sreg]) + strys.(['wagetax_' sreg]) + strys.(['publiccapitalincome_' sreg]) ...
            + (1 + strys.rf) * (phiBGext * s_lag + (1 - phiBGext)) * BG_lag;

        strys.(['BG_' sreg]) = revenue ...
            - strys.(['P_' sreg]) * strys.(['G_' sreg]) ...
            - strys.(['P_' sreg]) * strys.(['I_G_' sreg]) ...
            - strys.(['Tr_' sreg]);

        namesToWrite = [namesToWrite, {['I_' sreg], ['I_G_' sreg], ['C_' sreg], ['G_' sreg], ['BG_' sreg], ...
            ['NX_' sreg], ['B_' sreg], ['s_' sreg], ['Tr_' sreg]}]; %#ok<AGROW>

        fprintf(['[reshuffle_initial_period] reg %s: I/Y=%.4f  C/Y=%.4f  G/Y=%.4f  ' ...
            'NX/Y=%.4f  dBG=%.4f\n'], sreg, ...
            strys.(['I_' sreg]) * strys.(['P_' sreg]) / strys.(['Y_' sreg]), ...
            strys.(['C_' sreg]) * strys.(['P_' sreg]) / strys.(['Y_' sreg]), ...
            strys.(['G_' sreg]) * strys.(['P_' sreg]) / strys.(['Y_' sreg]), ...
            strys.(['NX_' sreg]) / strys.(['Y_' sreg]), ...
            strys.(['BG_' sreg]) - BG_lag);
    end

    namesToWrite = [namesToWrite, {'I', 'C', 'G', 'NX', 'B'}];

    %% Write reshuffled variables back into oo_.endo_simul(:,1)
    for k = 1:numel(namesToWrite)
        nm = namesToWrite{k};
        if isKey(endoIndex, nm) && isfield(strys, nm)
            oo_.endo_simul(endoIndex(nm), 1) = strys.(nm);
        end
    end
end

function v = local_target(tabtargets, name)
    if isfield(tabtargets, name)
        v = tabtargets.(name);
    else
        v = NaN;
    end
end
