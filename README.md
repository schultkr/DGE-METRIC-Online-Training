# DGE-METRIC Online Training Repository

This repository contains materials for the DGE-METRIC Online Training on finance and energy-efficiency scenarios, reserve requirements, and calibration and sensitivity analysis.

It is structured for hands-on delivery: participants can move from agenda to code, reproduce core exercises, and document outputs in a consistent workflow.

## Setup Guide

For participant onboarding, use the GitHub-viewable setup guide:

- [worksheets/setup/GitHub_Copilot_Setup_Guide.md](worksheets/setup/GitHub_Copilot_Setup_Guide.md)

Source document (kept in-repo):

- [worksheets/setup/GitHub_Copilot_Setup_Guide.docx](worksheets/setup/GitHub_Copilot_Setup_Guide.docx)

## Training Summary

- Program: GIZ Vietnam | DGE-METRIC Program | Online Module
- Dates: 22-24 July 2026
- Time zone: ICT (UTC+7)
- Delivery format: 5 live sessions (2 morning sessions, 3 afternoon sessions)
- Total live instruction: approximately 15 hours

## Target Audience

Participants who have completed the on-site DGE-METRIC training and are ready for applied work in:

- calibration and diagnostics,
- scenario design and implementation,
- reserve-requirement analysis, and
- interpretation and policy communication.

## Learning Outcomes

By the end of the online training, participants should be able to:

- Navigate the DGE-METRIC codebase and trace equations to implementation.
- Run baseline calibration workflows and interpret diagnostics.
- Build and document finance and energy-efficiency scenarios.
- Modify calibration inputs and selected structural parameters.
- Explain reserve-requirement logic (MC = MB) and implementation pathways.
- Use GitHub and VS Code in a practical model-development workflow.

## Session Schedule

| Session | Date            | Time (ICT)  | Topic                                                       | Main Output                                                  |
| ------- | --------------- | ----------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
| 1       | Wed 22 Jul 2026 | 13:00-17:00 | Finance and energy-efficiency scenario definition           | Two completed scenario metadata sheets                       |
| 2       | Thu 23 Jul 2026 | 09:00-11:30 | Calibration and scenario hands-on                           | Calibration diagnostic note + comparison chart and narrative |
| 3       | Thu 23 Jul 2026 | 13:00-17:00 | Reserve requirements method and implementation planning     | MC=MB walkthrough + implementation plan                      |
| 4       | Fri 24 Jul 2026 | 09:00-11:30 | Guided open lab on reserve requirements                     | Completed reserve-requirement analysis note                  |
| 5       | Fri 24 Jul 2026 | 13:00-17:00 | Calibration internals, modification, sensitivity, and close | Sensitivity-analysis plan + exit outputs                     |

## Day-to-Code Mapping

### Day 1 - Wednesday, 22 July 2026

Primary focus:

- Finance and energy-efficiency scenario definition (Session 1).

Relevant repository locations:

- Main model workflows: [Code/dge-metric-model](Code/dge-metric-model)
- Equations and calibration scripts: [Code/dge-metric-model/ModFiles](Code/dge-metric-model/ModFiles), [Code/dge-metric-model/Functions](Code/dge-metric-model/Functions)

### Day 2 - Thursday, 23 July 2026

Primary focus:

- Morning: calibration and scenario hands-on (Session 2).
- Afternoon: reserve requirements method and implementation planning (Session 3).

Relevant repository locations:

- Calibration and scenario execution: [Code/dge-metric-model](Code/dge-metric-model)
- Reserve requirements methods and scripts: [Code/reserve-requirements](Code/reserve-requirements)
- Reserve outputs and examples: [Code/reserve-requirements/run_outputs](Code/reserve-requirements/run_outputs)

### Day 3 - Friday, 24 July 2026

Primary focus:

- Morning: guided open lab on reserve requirements (Session 4).
- Afternoon: calibration internals, model modification, and sensitivity analysis (Session 5).

Relevant repository locations:

- Reserve-requirement lab work: [Code/reserve-requirements](Code/reserve-requirements)
- Model modification and sensitivity practice: [Code/dge-metric-model](Code/dge-metric-model)
- Communication outputs and presentation assets: [slides](slides), [Code/reserve-requirements/Presentation](Code/reserve-requirements/Presentation)

## Session Details

### Session 1 - Wed 22 Jul, 13:00-17:00

- Welcome, recap, and repository orientation
- Finance-scenario matrix and mechanism walkthrough
- Group drafting of finance scenario metadata
- Energy-efficiency channels and quantified assumptions
- Group drafting of energy-efficiency scenario metadata

### Session 2 - Thu 23 Jul, 09:00-11:30

- 09:00-10:00 recap and troubleshooting
- 10:00-11:30 technical hands-on
- Codebase navigation across ModFiles and Functions
- Baseline calibration run and diagnostics
- Debugging common MATLAB/Dynare errors
- Scenario runs and comparison outputs

### Session 3 - Thu 23 Jul, 13:00-17:00

- Policy framing for reserve adequacy
- Mapping Day 1-2 outputs to reserve-analysis inputs
- Break-even screening (Step 1)
- Validation and optimization concepts (Steps 2-3)
- Implementation mapping into DGE-METRIC structure
- Group drafting of an implementation plan for one carrier

### Session 4 - Fri 24 Jul, 09:00-11:30

- Recap and discussion
- Group lab work on break-even and validation logic
- Write-up of assumptions, method, sensitivities, and caveats
- Report-out and debrief

### Session 5 - Fri 24 Jul, 13:00-17:00

- Calibration workflow recap and reliability checks
- Data inputs versus structural parameters
- Modification workflow and re-validation process
- One-at-a-time sensitivity method
- Group drafting of a sensitivity-analysis plan
- Report-out, checklist, and exit ticket

## Repository Structure

- [Agenda](Agenda)
- [slides](slides)
- [worksheets](worksheets)
- [worksheets/setup](worksheets/setup)
- [Code](Code)
- [Code/dge-metric-model](Code/dge-metric-model)
- [Code/reserve-requirements](Code/reserve-requirements)

## Prerequisites

- MATLAB and Dynare installed and operational
- Access to this repository
- No mandatory pre-reading
- Prior Git/GitHub Desktop/VS Code experience is helpful but not required

## Source and Notes

Additional notes:

- Reserve-requirement method examples are instructional and not policy-final outputs.
- Some institutional follow-up items (for example TA/manual/video support and Octave substitution) remain to be confirmed.
