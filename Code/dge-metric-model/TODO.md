# DGE-METRIC model transfer — status and open items

**Transferred so far (2026-07-16):** `ModFiles/` and `Functions/` only, copied verbatim from `C:\Users\nb\Documents\GitHub\DGE-METRIC` (commit state as of copy date). This is a partial transfer — the folders below do not yet run standalone. Everything in this file is a gap found by scanning the two transferred folders (and, where relevant, the root-level files that drive them) for references to files outside `ModFiles/`/`Functions/`.

## Why only these two folders

`@#include` directives inside `ModFiles/*.mod` reference paths as `ModFiles/Equations/...` and `ModFiles/Equations_display/...` — i.e. **relative to the repository root**, not relative to `ModFiles/` itself. That root-relative structure has been preserved here (`Code/dge-metric-model/ModFiles/...`), so Dynare must eventually be invoked with `Code/dge-metric-model/` as the working directory, once the rest of the root-level files below are added.

## ToDo: repo-root files not yet transferred, required to actually run anything

These live at the DGE-METRIC repo root (outside `ModFiles/`/`Functions/`) and are needed before this code does anything:

- [ ] `DGE_Model.mod` — top-level Dynare file `RunSimulations.m` edits and calls.
- [ ] `DGE_Model_steadystate.m` — steady-state driver.
- [ ] `RunSimulations.m` — main entry point; defines `scenarioGroups` (see scenario gap below) and drives the run loop.
- [ ] `setup_paths.m` — adds `Functions/` and `ModFiles/` to the MATLAB path. Also hardcodes two candidate Dynare install paths:
  ```matlab
  'C:\dynare\7.0\matlab', ...
  'C:\dynare\6.1\matlab'
  ```
  This is a **machine dependency**, not a repo dependency — every participant machine needs Dynare installed at one of these paths (or `setup_paths.m` needs a portable rewrite, e.g. reading a `DYNARE_PATH` environment variable) before this runs on any machine but the current one.

## ToDo: sibling folders referenced by `Functions/` but not yet transferred

`Functions/` reads and writes Excel workbooks under a top-level `ExcelFiles/` folder that has not been copied yet. All references are relative to repo root (`ExcelFiles/...`, `fullfile(sRepoRoot,'ExcelFiles')`, `fullfile(cfg.root,'ExcelFiles',...)`) — not absolute paths — but the folder itself is missing here. Specific workbooks named in code/docs:

- [ ] `ExcelFiles/ModelBaseline5Sectorsand1Regions.xlsx`
- [ ] `ExcelFiles/ModelSimulationandCalibration*.xlsx` (legacy combined workbook)
- [ ] `ExcelFiles/ModelScenarios5Sectorsand1Regions.xlsx` — per `docs/use_cases_finance.md`, this is where WACF-derived shock paths for the green-finance scenarios either already live or still need to be translated in from `Vietnam_Green_Finance_Scenarios_April2026.xlsx`
- [ ] `ExcelFiles/PDP8/Vietnam_Green_Finance_Scenarios_April2026.xlsx` — source for the three finance scenarios' WACF assumptions
- [ ] `ExcelFiles/PDP8/Vietnam_EnergyExpert_ScenarioInputs - Adjust_2505.xlsx` — source for EE sector savings targets
- [ ] `ExcelFiles/Output/` — output directory `simulation_model_refactored.m` and `store_baseline_final_state.m` write to

Also referenced only in comments/docstrings (informational, not a runtime blocker, but these docs explain the workflow and aren't transferred yet): `docs/data_sources.md`, `docs/README` under `ExcelFiles/`, `scripts/maintenance/UpdateBaselineSheet.m`, `scripts/reporting/GenerateGDPComponentsStartEndVsActual.m`.

## ToDo: genuine external/machine-specific paths (outside any repo)

These are the two findings from the scan that point **outside any git repository entirely** — real "ToDo, fix before this is portable" items, not just missing-folder items:

1. **`RunSimulations.m` lines 152, 163** — default fallback paths read from environment variables, but if unset, fall back to a hardcoded Dropbox path:
   ```matlab
   sInvestmentTargetsCsv = fullfile(getenv('USERPROFILE'), 'Dropbox', '2025_GIZ_Vietnam', ...);
   sInvestmentTargetsIoTableXlsx = fullfile(getenv('USERPROFILE'), 'Dropbox', '2025_GIZ_Vietnam', ...);
   ```
   `[SME REVIEW NEEDED: confirm the exact investment-targets CSV and IO-table xlsx filenames/subpath, and whether these should ship inside the model repo instead of defaulting to a Dropbox path that only exists on the original author's machine]`

2. **`Figures/save_figures_for_scenarios*.m`** (all three files) hardcode absolute output paths to a *different user's* machine:
   ```matlab
   outdir = 'C:/Users/schul/Documents/GitHub/DGE-METRIC-VietNam/docs/figures/RTS/';    % save_figures_for_scenarios.m
   outdir = 'C:/Users/schul/Documents/GitHub/DGE-METRIC-VietNam/docs/figures/finance/'; % save_figures_for_scenarios_finance.m
   outdir = 'C:/Users/schul/Documents/GitHub/DGE-METRIC-VietNam/docs/figures/EE/';      % save_figures_for_scenarios_ee.m
   ```
   Username is `schul`, not the current machine's `nb` — these will fail outright on this machine, and point at a **separate `DGE-METRIC-VietNam` repository** that these `Figures/` scripts assume exists as a sibling checkout. `[SME REVIEW NEEDED: confirm whether DGE-METRIC-VietNam is still the canonical docs/figures destination, or whether this repo (DGE-METRIC) is now self-contained and these scripts are stale]`. `Figures/` itself has not been transferred here yet either.

## Open question: does the training's scenario design match what this model actually implements?

This is the important one — it affects whether the hands-on sessions as currently written can be run against this code at all.

**Energy-efficiency scenario — matches.** The online training's `efficiency-dsm-baseline` (manufacturing ≈7.4%, services/commercial ≈5.1%, households ≈11.6%, ≈USD 361m/yr ≈0.076% of GDP) lines up exactly with this model's `EE_PDP8` scenario per `docs/use_cases_ee.md`. Good sign — the training content was source-grounded in this model correctly for EE.

**Finance scenarios — do not match.** The online training's `scenario-template.md` describes a **six-scenario matrix** built from two independent binary levers: public financing rate (8% baseline vs. 5% concessional) × revenue recycling (off vs. on: `τ^{K,F}_Renewable,t = Rev^{C&T}_t`), crossed with emissions pathway (PDP8/NZ) — `PDP8-Base`, `NZ-Base`, `PDP8-Concessional`, `NZ-Concessional`, `PDP8-Recycle`, `NZ-Recycle`.

This model instead implements **three named finance architectures** (`GF_A` balanced 6.43% WACF, `GF_B` market-led 7.37% WACF — the baseline, `GF_C` public-led 5.07% WACF), each run on both PDP8 and NZ (`PDP8_GF_A/B/C`, `NZ_GF_A/B/C` — six runs total, wired in `RunSimulations.m`'s `scenarioGroups.GF_PDP8` / `scenarioGroups.GF_NZ`). There is no revenue-recycling lever (`τ^{K,F}_Renewable,t = Rev^{C&T}_t`) visible in `docs/use_cases_finance.md`'s channel table (`exo_r_G_s`, `exo_r_FDI_s`, `exo_P_K_s`, `exo_K_G_s`/`exo_s_G_s`) — it may exist elsewhere in the model and simply not be documented in that use-case page, or the training's revenue-recycling scenario may not be implemented at all yet.

`[SME REVIEW NEEDED: reconcile the training's finance-scenario matrix against this model's actual GF_A/B/C implementation before Online Day 1 PM / Day 2 AM run — either (a) rewrite the training's finance scenario-template.md and exercise.md to match GF_A/B/C's WACF framing, or (b) confirm the revenue-recycling channel exists in the model under a different name/location than docs/use_cases_finance.md documents, or (c) treat revenue recycling as a genuinely new scenario to be implemented before this training can run it hands-on]`

## Suggested next transfer steps, in order

1. Resolve the finance-scenario question above — it determines whether step 2 needs new model code or just new documentation.
2. Transfer `ExcelFiles/` (at least `ModelBaseline5Sectorsand1Regions.xlsx`, `ModelScenarios5Sectorsand1Regions.xlsx`, and the `PDP8/` expert-input workbooks) — check file sizes first; Excel workbooks in this codebase can be large.
3. Transfer `DGE_Model.mod`, `DGE_Model_steadystate.m`, `RunSimulations.m`, `setup_paths.m` (rewriting the Dropbox default paths and Dynare install paths to be portable across participant machines).
4. Add a short `Code/dge-metric-model/README.md` with the MATLAB quick-start (`setup_paths; RunSimulations`) once the above is in place, and confirm which Dynare version participants need installed.
