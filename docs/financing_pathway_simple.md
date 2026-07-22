# Financing Pathway — Worked Problem Set

A self-contained exercise, companion to `energy_efficiency_pathway_simple.md`. No file citations,
no software — just arithmetic. Attempt each "Try it yourself" before reading the solution
underneath it.

## Your worksheet — the target, blank

Copy this onto paper before reading further.

### Per-scenario worksheet (fill in one row per scenario)

| Scenario | Public rate wedge (`exo_r_G_3_1`) | FDI rate wedge (`exo_r_FDI_3_1`) | Public capital-share target (`exo_sIGShare_3_1`) | FDI capital-share target (`exo_sFDIShare_3_1`) |
|---|---|---|---|---|
| A — Balanced | | | | |
| B — Market-led | | | | |
| C — Public-led | | | | |

### The remaining columns (same rule for every scenario — fill in now, no calculation needed)

| | Every year except the last | The very last year of the simulation |
|---|---|---|
| `exo_lIGShare_3_1` | | |
| `exo_lFDIShare_3_1` | | |
| `exo_CapTrade_1` | | *(same value both columns)* |

*(Hint for the switch columns' right-hand column: both switches do the same thing in the final
year, and it isn't "repeat last year's value." `exo_CapTrade_1` has no such exception — one value
covers every year, first to last.)*

## Learning objectives

By the end of this problem set you should be able to:

1. Read a financing-instrument table and sort each instrument into "public," "FDI," or
   "residual/private."
2. Compute a weighted-average cost of finance (WACF) across every instrument.
3. Convert a rate into a "wedge" relative to a benchmark rate.
4. Compute a public/FDI capital-share target by summing the right instruments' shares.
5. Explain why these numbers stay constant for 25 years — unlike the EE pathway — except for one
   switch that flips in the very last year.

## Setup: the teaching dataset

Below is a small, made-up (not the real Vietnam numbers) financing-instrument table for three
scenarios. Unlike the EE pathway's dataset, this one has **no years at all** — every number here is
a single, one-off assumption that then applies unchanged for the whole simulation.

| Instrument | Routed to | A share | A rate | B share | B rate | C share | C rate |
|---|---|---|---|---|---|---|---|
| Concessional loans | public | 10% | 2.0% | 5% | 2.0% | 20% | 1.5% |
| Green bonds (public) | public | 15% | 4.0% | 10% | 4.5% | 25% | 3.5% |
| FDI equity | FDI | 12% | 6.0% | 15% | 6.5% | 10% | 5.5% |
| FDI corporate bonds | FDI | 8% | 7.0% | 10% | 7.5% | 5% | 6.5% |
| Bank credit | *residual* | 55% | 8.0% | 60% | 8.5% | 40% | 7.5% |
| **Total** | | **100%** | | **100%** | | **100%** | |

We'll also use a simplified benchmark rate `rf0_p = 10%` throughout this exercise (the real model
uses ≈10.26%, derived from two other model parameters — the arithmetic below works the same way
either way).

## Part 1 — Sorting instruments into buckets

**Only "public" and "FDI" instruments get their own shock variable.** "Residual" instruments (here,
bank credit) get nothing — they're treated as ordinary domestic capital, exactly as if there were no
green-finance scenario running at all.

### Try it yourself — Exercise 1

Looking at the table, which instruments feed `exo_r_G_3_1`/`exo_sIGShare_3_1` (public), which feed
`exo_r_FDI_3_1`/`exo_sFDIShare_3_1` (FDI), and which feed nothing?

### Solution — Exercise 1

- **Public:** Concessional loans, Green bonds (public)
- **FDI:** FDI equity, FDI corporate bonds
- **Nothing (residual):** Bank credit — its share and rate never appear in any `exo_*` variable.

This matters because it tells you *why* bank credit's own share and rate don't need to show up
anywhere in your worksheet at all, no matter how big a share of financing it represents.

## Part 2 — Computing the public-capital rate wedge

```
WACF = Σ (share_i × rate_i)     — summed over ALL instruments, including the residual one
exo_r_G_3_1 = WACF − rf0_p
```

Note this uses **every** instrument's share and rate, not just the public ones — WACF is the
blended cost of the *entire* financing package, which then becomes the rate the model pays on
public capital specifically.

### Try it yourself — Exercise 2

Compute WACF and `exo_r_G_3_1` for scenario A. (Shares are percentages — convert to fractions
first: 10% → 0.10.)

### Solution — Exercise 2

```
WACF_A = 0.10×0.02 + 0.15×0.04 + 0.12×0.06 + 0.08×0.07 + 0.55×0.08
       = 0.0020 + 0.0060 + 0.0072 + 0.0056 + 0.0440
       = 0.0648   (6.48%)
exo_r_G_3_1 (A) = 0.0648 − 0.10 = −0.0352
```

Now do B and C yourself. Answers:

| Scenario | WACF | `exo_r_G_3_1` |
|---|---|---|
| A | 6.48% | **−0.0352** |
| B | 7.375% | **−0.02625** |
| C | 5.05% | **−0.0495** |

Notice the wedge is **negative in every scenario** — every blended rate here is well below the 10%
benchmark, so public capital always ends up cheaper than the model's default cost of capital. Also
notice C (public-led) has the *most* negative wedge — makes sense, since it routes the largest
shares into the cheapest instruments (concessional loans, public green bonds).

## Part 3 — Computing the FDI-capital rate wedge

```
fdi_rate = Σ_(FDI instruments only) (share × rate)  ÷  Σ_(FDI instruments only) share
exo_r_FDI_3_1 = fdi_rate − rf0_p
```

This time only the two FDI-routed instruments count — and you divide by their combined share (not
100%), because you want the *average rate among FDI money only*, not their contribution to the
whole package.

### Try it yourself — Exercise 3

Compute `fdi_rate` and `exo_r_FDI_3_1` for scenario A, using only FDI equity and FDI corporate
bonds.

### Solution — Exercise 3

```
fdi_rate (A) = (0.12×0.06 + 0.08×0.07) / (0.12 + 0.08)
             = (0.0072 + 0.0056) / 0.20
             = 0.0128 / 0.20 = 0.064   (6.4%)
exo_r_FDI_3_1 (A) = 0.064 − 0.10 = −0.036
```

B and C:

| Scenario | FDI-only weighted rate | `exo_r_FDI_3_1` |
|---|---|---|
| A | 6.4% | **−0.036** |
| B | 6.9% | **−0.031** |
| C | 5.833% | **−0.04167** |

## Part 4 — Computing the capital-share targets

These are the simplest calculations in the whole exercise — just add up shares, no rates involved:

```
exo_sIGShare_3_1  = Σ_(public instruments) share
exo_sFDIShare_3_1 = Σ_(FDI instruments) share
```

### Try it yourself — Exercise 4

Compute both share targets for all three scenarios.

### Solution — Exercise 4

| Scenario | `exo_sIGShare_3_1` (public) | `exo_sFDIShare_3_1` (FDI) |
|---|---|---|
| A | 0.10+0.15 = **0.25** | 0.12+0.08 = **0.20** |
| B | 0.05+0.10 = **0.15** | 0.15+0.10 = **0.25** |
| C | 0.20+0.25 = **0.45** | 0.10+0.05 = **0.15** |

These two numbers, together with the rate wedges from Parts 2–3, are the *entire* description of a
financing scenario — one snapshot, not a time series.

## Part 5 — The one place time matters at all

Every number you've computed so far applies **unchanged to every single year** of the simulation —
there's no year-by-year data to work through, unlike the EE pathway. There is exactly one exception:
two switch variables, `exo_lIGShare_3_1` and `exo_lFDIShare_3_1`, are `1` in every ordinary year but
flip to `0` in the very last simulated year, for *every* scenario (A, B, and C alike — this isn't
scenario-specific).

**What do these switches actually do?** When `= 1`, public/FDI capital is targeted as a *share of
whatever total investment happens to be that year* — so it automatically grows or shrinks with the
sector. When `= 0`, it instead follows an ordinary fixed replacement path, unrelated to that year's
investment level. The model reverts to the fixed-path rule for one period only, at the very end of
the simulation, purely to avoid a technical problem with how the last period of a
forward-looking solve gets closed out — it is not a policy statement about the final year.

### Try it yourself — Exercise 5

If the simulation runs from 2026 to 2050 (25 years), in which calendar year does
`exo_lIGShare_3_1` first equal `0`?

### Solution — Exercise 5

**2050** — the last year of the simulation, and only that year. Every year from 2026 through 2049
has `exo_lIGShare_3_1 = exo_lFDIShare_3_1 = 1`.

**One more column, with no calculation at all:** every GF sheet also carries an `exo_CapTrade_1`
column, set to `1` in every single row, every year, no exception. Unlike the two switches above, it
never changes at the end of the simulation — one constant value covers the whole table. (It isn't
actually specific to financing — it's the same emissions-policy flag used elsewhere in the model,
just written once more here because this sheet happens to carry it too.)

## Part 6 — Why there's no "NoBESS"-style counterfactual here

The EE pathway isolates one channel (batteries + household solar) by comparing a full scenario to a
version with 3 of its 10 numbers reverted to baseline. The financing pathway is built differently:
**A, B, and C are three complete, self-consistent alternatives**, each with its own full set of
values from Parts 2–4 above — none of them is "the other one with something removed." Comparing
outcomes means running all three and comparing them directly to each other (and, separately,
comparing the same three scenarios under two different physical-transition paths — PDP8 vs
net-zero — to see whether the financing effect is bigger when the underlying transition is more
ambitious).

## Self-check questions (no calculation needed)

1. Why does adding up bank credit's share and rate never matter for any `exo_*` variable, even
   though it's the *largest* single instrument in every scenario?
2. Why is `exo_r_G_3_1` computed from all 5 instruments, while `exo_r_FDI_3_1` only uses 2 of them?
3. If a new scenario D had every instrument's rate exactly equal to `rf0_p` (10%), what would
   `exo_r_G_3_1` and `exo_r_FDI_3_1` both equal, regardless of the shares?
4. Why does this pathway not need an extrapolation rule, when the EE pathway does?
5. Scenario C has the smallest `exo_r_FDI_3_1` (most negative) despite *not* having the largest FDI
   share. What does that tell you about what actually drives the size of a rate wedge?

<details>
<summary>Answer key</summary>

1. Because bank credit is the *residual* instrument — it's treated as ordinary domestic capital
   with no special financing treatment, so nothing about it is ever plugged into the public or FDI
   formulas.
2. `exo_r_G_3_1` represents the blended cost of the *entire* financing package as it applies to
   public capital, so every instrument's share and rate contributes to the average. `exo_r_FDI_3_1`
   is specifically about the rate *foreign investors* require, so only the instruments actually
   routed to FDI counts.
3. Both would equal 0 — if every rate equals the benchmark, the weighted average (however it's
   sliced) also equals the benchmark, and the wedge (`average − rf0_p`) is zero regardless of how
   the shares are split.
4. Extrapolation exists to fill in years where a time-series of expert data runs out. The financing
   variables were never a time series to begin with — they're a single number computed once from a
   static instrument table, so there's nothing to extend forward.
5. It's driven by the *rates* of the specific instruments routed to FDI, not by how much money goes
   through that channel. Scenario C sends a smaller FDI share than A or B, but at a lower blended
   rate (5.5%/6.5% vs A's 6%/7% and B's 6.5%/7.5%), so its wedge ends up most negative even with
   less volume.

</details>

## One-paragraph summary

Every green-finance scenario is four numbers, each computed **once** rather than year by year: a
weighted-average financing cost turned into a rate wedge for public capital, a similarly-weighted
rate turned into a wedge for FDI capital, and two capital-share targets found by summing the right
instruments' allocation shares. One instrument — commercial bank credit — is deliberately left out
of every formula because it's treated as ordinary domestic capital. The only place time enters at
all is a pair of switches that stay on for the whole simulation and turn off for exactly the last
year, a technical closing rule rather than a policy choice. Because A, B, and C are three complete
alternatives rather than a full scenario and a stripped-down twin, comparing them means running all
three side by side rather than differencing a pair.
