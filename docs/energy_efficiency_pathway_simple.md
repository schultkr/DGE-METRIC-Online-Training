# Energy Efficiency Pathway — Worked Problem Set

A self-contained exercise: by working through it you will reconstruct, by hand, every number that
goes into an EE scenario. No file citations, no software — just arithmetic and a calculator (or a
log button). Attempt each "Try it yourself" before reading the solution underneath it.

## Your worksheet — the target, blank

This is what you are building. Copy both tables onto paper or into a spreadsheet now, before
reading anything else. Every cell starts blank; each Part of this problem set tells you exactly
how to fill in one or more columns, until — 25 rows later — the whole thing is done.

### Full scenario worksheet (fill in as you go)

| Year | Calendar | Industry shock (`exo_AI_4_1_2`) | Services shock (`exo_AI_5_1_2`) | Industry public EE-investment value (`exo_GA_4_1`) | Services public EE-investment value (`exo_GA_5_1`) | Public BESS-investment value (`exo_GA_3_1`) | PV-gain shock (`exo_PVEff_1`) | Household RTS-investment value (`exo_PV_1`) | Switch 1 (`exo_lAddEE_4_1`) | Switch 2 (`exo_lAddEE_5_1`) | Switch 3 (`exo_CapTrade_1`) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026 | | | | | | | | | | |
| 2 | 2027 | | | | | | | | | | |
| 3 | 2028 | | | | | | | | | | |
| 4 | 2029 | | | | | | | | | | |
| 5 | 2030 | | | | | | | | | | |
| 6 | 2031 | | | | | | | | | | |
| 7 | 2032 | | | | | | | | | | |
| 8 | 2033 | | | | | | | | | | |
| 9 | 2034 | | | | | | | | | | |
| 10 | 2035 | | | | | | | | | | |
| 11 | 2036 | | | | | | | | | | |
| 12 | 2037 | | | | | | | | | | |
| 13 | 2038 | | | | | | | | | | |
| 14 | 2039 | | | | | | | | | | |
| 15 | 2040 | | | | | | | | | | |
| 16 | 2041 | | | | | | | | | | |
| 17 | 2042 | | | | | | | | | | |
| 18 | 2043 | | | | | | | | | | |
| 19 | 2044 | | | | | | | | | | |
| 20 | 2045 | | | | | | | | | | |
| 21 | 2046 | | | | | | | | | | |
| 22 | 2047 | | | | | | | | | | |
| 23 | 2048 | | | | | | | | | | |
| 24 | 2049 | | | | | | | | | | |
| 25 | 2050 | | | | | | | | | | |

### NoBESS worksheet (same shape — only 3 columns will end up different)

| Year | Calendar | Industry shock (`exo_AI_4_1_2`) | Services shock (`exo_AI_5_1_2`) | Industry public EE-investment value (`exo_GA_4_1`) | Services public EE-investment value (`exo_GA_5_1`) | Public BESS-investment value (`exo_GA_3_1`) | PV-gain shock (`exo_PVEff_1`) | Household RTS-investment value (`exo_PV_1`) | Switch 1 (`exo_lAddEE_4_1`) | Switch 2 (`exo_lAddEE_5_1`) | Switch 3 (`exo_CapTrade_1`) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026 | | | | | | | | | | |
| 2 | 2027 | | | | | | | | | | |
| 3 | 2028 | | | | | | | | | | |
| 4 | 2029 | | | | | | | | | | |
| 5 | 2030 | | | | | | | | | | |
| 6 | 2031 | | | | | | | | | | |
| 7 | 2032 | | | | | | | | | | |
| 8 | 2033 | | | | | | | | | | |
| 9 | 2034 | | | | | | | | | | |
| 10 | 2035 | | | | | | | | | | |
| 11 | 2036 | | | | | | | | | | |
| 12 | 2037 | | | | | | | | | | |
| 13 | 2038 | | | | | | | | | | |
| 14 | 2039 | | | | | | | | | | |
| 15 | 2040 | | | | | | | | | | |
| 16 | 2041 | | | | | | | | | | |
| 17 | 2042 | | | | | | | | | | |
| 18 | 2043 | | | | | | | | | | |
| 19 | 2044 | | | | | | | | | | |
| 20 | 2045 | | | | | | | | | | |
| 21 | 2046 | | | | | | | | | | |
| 22 | 2047 | | | | | | | | | | |
| 23 | 2048 | | | | | | | | | | |
| 24 | 2049 | | | | | | | | | | |
| 25 | 2050 | | | | | | | | | | |

**How the worksheet gets filled in, part by part:**

| Worksheet column | Filled in by | All 25 rows filled in after... |
|---|---|---|
| Industry shock (`exo_AI_4_1_2`), Services shock (`exo_AI_5_1_2`) | Part 1 (Years 1–6), Part 3 Rule 1 (Years 7–25) | Part 3 |
| Industry public EE-investment value (`exo_GA_4_1`), Services public EE-investment value (`exo_GA_5_1`), Household RTS-investment value (`exo_PV_1`), Public BESS-investment value (`exo_GA_3_1`) | Part 2 (Years 1–6), Part 3 Rule 2 (Years 7–25) | Part 3 |
| PV-gain shock (`exo_PVEff_1`) | Part 1 (Years 1–6), Part 3 Rule 1 (Years 7–25) | Part 3 |
| Switch 1 (`exo_lAddEE_4_1`), Switch 2 (`exo_lAddEE_5_1`), Switch 3 (`exo_CapTrade_1`) | always just `1` — fill in every row immediately, no calculation | now |
| The 3 NoBESS columns that differ (public BESS-investment value `exo_GA_3_1`, PV-gain shock `exo_PVEff_1`, household RTS-investment value `exo_PV_1`) | Part 5 | Part 5 |

Don't worry if none of that makes sense yet — go fill in Switches 1–3 with `1` in every row of both
tables (that part needs no maths), then move on to Part 1.

## Learning objectives

By the end of this problem set you should be able to:

1. Read a raw table of expert policy assumptions and identify what each column means and what
   units it's in.
2. Convert a percentage saving/gain into a productivity shock using a log formula.
3. Turn a stream of yearly investment dollars into a single decaying, accumulating balance.
4. Extend a shock forward in time when the expert data runs out before the model's final year.
5. Build the "NoBESS" counterfactual row from a full scenario row.

## Setup: the teaching dataset

Below is a small, made-up (not the real Vietnam numbers) 6-year table of expert assumptions for a
fictional scenario. We will use it for every exercise in this problem set.

The real model runs for **25 years, 2026–2050**. To match that, treat "Year 1" as 2026 and "Year 6"
as 2031 — expert assumptions are only given for those first 6 years (2026–2031). The model still
needs a number for every one of the remaining 19 years, all the way to Year 25 (2050), so Part 3
(below) walks through exactly how those 19 missing years get filled in.

| Exercise year | 1 | 2 | 3 | 4 | 5 | 6 | ... | 25 |
|---|---|---|---|---|---|---|---|---|
| Calendar year | 2026 | 2027 | 2028 | 2029 | 2030 | 2031 | ... | 2050 |
| Expert data available? | yes | yes | yes | yes | yes | yes | **no** | **no** |

| Year | Industry saving % | Services saving % | Industry EE $m | Services EE $m | Industry RTS $m | Services RTS $m | Household RTS $m | BESS $bn | PV gain % |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 2 | 3 | 100 | 40 | 0 | 0 | 0 | 0.2 | 2 |
| 2 | 4 | 5 | 120 | 45 | 10 | 5 | 5 | 0.3 | 4 |
| 3 | 4 | 7 | 130 | 50 | 10 | 5 | 5 | 0.3 | 6 |
| 4 | 6 | 9 | 140 | 55 | 15 | 5 | 10 | 0.4 | 8 |
| 5 | 8 | 11 | 150 | 60 | 15 | 10 | 10 | 0.4 | 10 |
| 6 | 10 | 12 | 160 | 60 | 20 | 10 | 10 | 0.5 | 12 |

**Read the table before continuing.** Each row is one year. Each column is one raw assumption:

- **Industry / Services saving %** — how much less energy that sector needs per unit of output,
  thanks to efficiency measures, compared to doing nothing.
- **Industry / Services EE $m** — money spent that year on ordinary efficiency upgrades (in USD
  million).
- **Industry / Services RTS $m** — money spent that year on rooftop solar panels for that sector's
  buildings (also USD million — note this gets *combined* with the EE spending above, one recipe
  per sector, not kept separate).
- **Household RTS $m** — rooftop solar spending by households (its own, separate running balance).
- **BESS $bn** — grid-scale battery investment, in USD **billion**, not million — watch the units,
  this is the one column with a different scale.
- **PV gain %** — how much more of the *already installed* solar power batteries let the grid
  actually use (less wasted/curtailed power), not new solar capacity.

We will also assume, purely to keep the arithmetic simple for this exercise, that the "baseline"
(the do-nothing path) contributes **zero** to every one of the 10 output columns — so every number
you compute below is the whole answer, not an addition on top of some other baseline number. (In
the real model, everything you compute here still gets added to a non-zero baseline value — see
the note at the end.)

## Part 1 — Turning a percentage into a productivity number ("Recipe A")

Used for: saving percentages and the PV gain percentage.

```
saving_fraction = saving_percent / 100
shock = ln( 1 / (1 - saving_fraction) )
```

**Why a log, and why does it grow faster than the percentage?** If a sector becomes `x`% more
efficient, it now needs `1/(1-x/100)` times its old productivity to make the same output from less
energy. Try it: at 50% saving you'd need to *double* effective productivity
(`1/(1-0.5) = 2`) — savings above 50% blow up fast, which is why the model caps the saving fraction
at 99.99% (never let a sector claim it needs *zero* energy).

### Try it yourself — Exercise 1

Using the table above, compute the **Industry** productivity shock for Year 1, Year 4, and Year 6.
Then do the same for **Services**, Year 1, Year 4, and Year 6.

*(Work it out before reading on. A calculator with a natural-log button, or `ln`, is all you need.)*

### Solution — Exercise 1

| Year | Industry saving % | Industry shock `exo_AI_4_1_2` = ln(1/(1−saving)) | Services saving % | Services shock `exo_AI_5_1_2` |
|---|---|---|---|---|
| 1 | 2% | ln(1/0.98) = **0.0202** | 3% | ln(1/0.97) = **0.0305** |
| 4 | 5% | ln(1/0.95) = **0.051** | 9% | ln(1/0.91) = **0.0943** |
| 6 | 10% | ln(1/0.10) = **0.101** | 12% | ln(1/0.88) = **0.1278** |

Notice: Industry's saving % is only ~1.7× Services' in every year, but Industry's *shock* is more
than 1.7× Services' shock (e.g. Year 6: 0.223 vs 0.128, a ratio of 1.7 — check a smaller/larger pair
yourself to see the gap widen). That's the "grows faster than the percentage" effect from the log.

All six years, for reference (you'll need these later):

| Year | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Industry shock (`exo_AI_4_1_2`) | 0.0200 | 0.0400 | 0.0600 | 0.0800 | 0.1000 | 0.1200 |
| Services shock (`exo_AI_5_1_2`) | 0.0305 | 0.0513 | 0.0726 | 0.0943 | 0.1165 | 0.1278 |
| PV-gain shock (`exo_PVEff_1`) | 0.0198 | 0.0392 | 0.0583 | 0.0770 | 0.0953 | 0.1133 |

*(PV-gain shock uses the same formula, just with "gain %" instead of "saving %": for Year 1,
`ln(1 + 2/100) = ln(1.02) = 0.0198`.)*

## Part 2 — Turning dollars into a balance ("Recipe B")

Used for: Industry EE+RTS combined, Services EE+RTS combined, household RTS, and BESS.

Think of a bank account that pays no interest and **leaks 10% every year**, into which you make a
new deposit each year:

```
this_year_balance = 0.90 × last_year_balance + (this_year's spending in USD million ÷ 430,000)
```

`430,000` is a stand-in for the whole country's GDP in USD million — dividing by it turns a dollar
amount into "share of the whole economy," the unit the model actually works in. The `0.90` factor
means: whatever was invested doesn't last forever, so 10% of its effect fades out every year even
with no new spending.

**Why "public" for three of these four, but not the fourth?** The Industry, Services, and BESS
values feed a *government* spending target — hitting them costs real government money, financed
like any other government expenditure. Household rooftop solar is different: it's private household
spending, not government spending, so it doesn't get the "public" label even though the arithmetic
recipe is identical.

### Try it yourself — Exercise 2

Using the table's **Industry EE $m** and **Industry RTS $m** columns (add them together each year
— they share one running value), compute the Industry public EE-investment value for all 6 years.

### Solution — Exercise 2

| Year | Industry EE $m | Industry RTS $m | Combined $m | New deposit (÷430,000) | Industry public EE-investment value `exo_GA_4_1` = 0.9×prior + deposit |
|---|---|---|---|---|---|
| 1 | 100 | 0 | 100 | 0.000233 | **0.000233** |
| 2 | 120 | 10 | 130 | 0.000302 | 0.9×0.000233 + 0.000302 = **0.000512** |
| 3 | 130 | 10 | 140 | 0.000326 | 0.9×0.000512 + 0.000326 = **0.000786** |
| 4 | 140 | 15 | 155 | 0.000360 | 0.9×0.000786 + 0.000360 = **0.001068** |
| 5 | 150 | 15 | 165 | 0.000384 | 0.9×0.001068 + 0.000384 = **0.001345** |
| 6 | 160 | 20 | 180 | 0.000419 | 0.9×0.001345 + 0.000419 = **0.001629** |

Now do the same on your own for **Services** (EE + RTS combined), **Household RTS** (on its own),
and **BESS** (remember: convert billions to millions first — multiply by 1000). Answers:

| Year | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Services public EE-investment value (`exo_GA_5_1`) | 0.000093 | 0.000200 | 0.000308 | 0.000417 | 0.000538 | 0.000647 |
| Household RTS-investment value (`exo_PV_1`) | 0.000000 | 0.0000116 | 0.0000221 | 0.0000431 | 0.0000621 | 0.0000791 |
| Public BESS-investment value (`exo_GA_3_1`) | 0.000465 | 0.001116 | 0.001702 | 0.002462 | 0.003146 | 0.003995 |

*(Check your BESS row carefully: Year 1 is `0.2 bn × 1000 = 200m`, `200,000/430,000 = 0.000465` —
if your number is 1000× too small, you forgot the billion→million conversion.)*

## Part 3 — What if the model needs more years than you have data for?

Our expert assumptions stop at Year 6 (2031), but the model runs through Year 25 (2050) — **19
years with no expert data at all.** What happens to those 19 years?

### Rule 1 — Productivity/gain shocks (Recipe A outputs) keep growing along the same trend

The model does **not** freeze the shock at its Year-6 value, and does not assume it hits some
future target. Instead it draws a straight line from **zero at Year 0** through the Year-6 value,
and keeps extending that same straight line for all 19 remaining years:

```
rate = (Year-6 shock value) ÷ 6                     # "average yearly increase so far"
Year-k shock (k > 6) = Year-6 shock + rate × (k − 6)          for every k = 7, 8, ..., 25
```

### Try it yourself — Exercise 3

Using your Industry shock at Year 6 (0.2231, from Exercise 1), compute the rate, then extend the
Industry shock all the way out to Year 25 (2050). Then do the same for Services (Year-6 value
0.1278) and for the PV-gain shock (Year-6 value 0.1133). (Tedious by hand for all 19 years — do at
least Years 7, 10, 15, 20, and 25 yourself, then check every year against the full table below.)

### Solution — Exercise 3

Rates: Industry = 0.2231 ÷ 6 = **0.0372**/year; Services = 0.1278 ÷ 6 = **0.0213**/year;
PV gain = 0.1133 ÷ 6 = **0.0189**/year.

| Year | Calendar | Industry shock (`exo_AI_4_1_2`) | Services shock (`exo_AI_5_1_2`) | PV-gain shock (`exo_PVEff_1`) |
|---|---|---|---|---|
|6|2031| 0.12  *(last real data point)* | 0.1278 | 0.1133 |
|7|2032| 0,1400 | 0.1491 | 0.1322 |
|8|2033| 0,1600 | 0.1704 | 0.1511 |
|9|2034| 0,1800 | 0.1917 | 0.1700 |
|10|2035| 0,2000 | 0.2131 | 0.1889 |
|11|2036|0,2200 | 0.2344 | 0.2078 |
|12|2037|0,2400| 0.2557 | 0.2267 |
|13|2038|0,2600| 0.2770 | 0.2455 |
|14|2039|0,2800| 0.2983 | 0.2644 |
|15|2040|0,3000| 0.3196 | 0.2833 |
|16|2041|0,3200| 0.3409 | 0.3022 |
|17|2042|0,3400| 0.3622 | 0.3211 |
|18|2043|0,3600| 0.3835 | 0.3400 |
|19|2044|0,3800| 0.4048 | 0.3589 |
|20|2045|0,4000| 0.4261 | 0.3778 |
|21|2046|0,4200| 0.4474 | 0.3967 |
|22|2047|0,4400| 0.4687 | 0.4155 |
|23|2048|0,4600| 0.4900 | 0.4344 |
|24|2049|0,4800| 0.5113 | 0.4533 |
|25|2050|0,5000| 0.5326 | 0.4722 |
![Uploading image.png…]()


Notice the shock is still climbing steadily at Year 25 (nearly **4× its Year-6 value**) — a
straight-line extrapolation never levels off on its own. That is a real, worth-remembering property
of this method, not just a quirk of the made-up numbers: if 19 out of 25 years are extrapolated
rather than expert-supplied, the later years of a scenario are driven almost entirely by whatever
trend was visible in the first handful of data years.

### Rule 2 — Balances (Recipe B outputs) need no special rule at all

With no new investment, "this year's spending" is just zero, so the *same* recipe from Part 2
keeps working on its own, for as many years as needed:

```
Year-k balance (k > 6) = 0.90 × Year-(k-1) balance          # nothing new added, for k = 7 ... 25
```

### Try it yourself — Exercise 4

Extend the Industry public EE-investment value (Year 6 = 0.001629) all the way to Year 25 assuming no further
investment. Do the same for Services, Household RTS, and BESS. (Shortcut: `Year-(6+k) balance =
Year-6 balance × 0.9^k` — you don't have to multiply by 0.9 nineteen times by hand, just raise 0.9
to the right power.)

### Solution — Exercise 4

| Year | Calendar | Industry public EE-investment value (`exo_GA_4_1`) | Services public EE-investment value (`exo_GA_5_1`) | Household RTS-investment value (`exo_PV_1`) | Public BESS-investment value (`exo_GA_3_1`) |
|---|---|---|---|---|---|
| 6 | 2031 | 0.001629 *(last real data point)* | 0.000647 | 0.0000791 | 0.003995 |
| 7 | 2032 | 0.001466 | 0.000582 | 0.0000712 | 0.003596 |
| 8 | 2033 | 0.001319 | 0.000524 | 0.0000641 | 0.003236 |
| 9 | 2034 | 0.001188 | 0.000472 | 0.0000577 | 0.002912 |
| 10 | 2035 | 0.001069 | 0.000424 | 0.0000519 | 0.002621 |
| 11 | 2036 | 0.000962 | 0.000382 | 0.0000467 | 0.002359 |
| 12 | 2037 | 0.000866 | 0.000344 | 0.0000420 | 0.002123 |
| 13 | 2038 | 0.000779 | 0.000309 | 0.0000378 | 0.001911 |
| 14 | 2039 | 0.000701 | 0.000279 | 0.0000340 | 0.001720 |
| 15 | 2040 | 0.000631 | 0.000251 | 0.0000306 | 0.001548 |
| 16 | 2041 | 0.000568 | 0.000226 | 0.0000276 | 0.001393 |
| 17 | 2042 | 0.000511 | 0.000203 | 0.0000248 | 0.001254 |
| 18 | 2043 | 0.000460 | 0.000183 | 0.0000223 | 0.001128 |
| 19 | 2044 | 0.000414 | 0.000164 | 0.0000201 | 0.001015 |
| 20 | 2045 | 0.000373 | 0.000148 | 0.0000181 | 0.000914 |
| 21 | 2046 | 0.000335 | 0.000133 | 0.0000163 | 0.000823 |
| 22 | 2047 | 0.000302 | 0.000120 | 0.0000147 | 0.000740 |
| 23 | 2048 | 0.000272 | 0.000108 | 0.0000132 | 0.000666 |
| 24 | 2049 | 0.000245 | 0.000097 | 0.0000119 | 0.000600 |
| 25 | 2050 | 0.000220 | 0.000087 | 0.0000107 | 0.000540 |

By Year 25 every balance has shrunk to roughly **13–14%** of its Year-6 value (`0.9^19 ≈ 0.135`) —
19 years of pure 10%/year decay with nothing to replenish it. Contrast this directly with Rule 1:
percentage-based shocks keep *climbing* with no data, while dollar-based balances keep *shrinking*
with no data. Same "no more information" situation, opposite-looking results — because one recipe
extrapolates a trend and the other just keeps depreciating an existing stock.

## Part 4 — Assembling the full scenario row

Put Parts 1–3 together and you have all 10 columns, for every year 1–25 (2026–2050):

| # | Column | exo_ name | Comes from |
|---|---|---|---|
| 1 | Industry productivity shock | `exo_AI_4_1_2` | Part 1 (Industry saving %) |
| 2 | Services productivity shock | `exo_AI_5_1_2` | Part 1 (Services saving %) |
| 3 | Industry public EE-investment value | `exo_GA_4_1` | Part 2 (Industry EE $ + Industry RTS $, combined) |
| 4 | Services public EE-investment value | `exo_GA_5_1` | Part 2 (Services EE $ + Services RTS $, combined) |
| 5 | Public BESS-investment value | `exo_GA_3_1` | Part 2 (BESS $, converted from billions) |
| 6 | PV-gain shock | `exo_PVEff_1` | Part 1 (PV gain %) |
| 7 | Household RTS-investment value | `exo_PV_1` | Part 2 (Household RTS $, on its own) |
| 8 | "additive EE" switch | `exo_lAddEE_4_1` | always just the number `1` |
| 9 | "additive EE" switch | `exo_lAddEE_5_1` | always just the number `1` |
| 10 | "cap-and-trade" switch | `exo_CapTrade_1` | always just the number `1` |

Rows 8–10 are never calculated — they are fixed constants written the same way every year, in every
scenario.

## Part 5 — Building the "NoBESS" twin

The NoBESS version of a scenario is nearly a photocopy of the full version — **only 3 of the 10
numbers change**, and they don't become zero, they revert to whatever the do-nothing baseline
already had for that column (which we've been treating as zero in this exercise, for simplicity).

### Try it yourself — Exercise 5

Using your Year 6 answers (Industry shock 0.2231, Services shock 0.1278, Industry public EE-investment
value 0.001629, Services public EE-investment value 0.000647, public BESS-investment value 0.003995,
PV-gain shock 0.1133, household RTS-investment value 0.0000791), write out the full-scenario row for Year 6 and the NoBESS row for Year 6, side by side.

### Solution — Exercise 5

| Column | Full scenario, Year 6 | NoBESS, Year 6 | Changed? |
|---|---|---|---|
| Industry shock (`exo_AI_4_1_2`) | 0.2231 | 0.2231 | No |
| Services shock (`exo_AI_5_1_2`) | 0.1278 | 0.1278 | No |
| Industry public EE-investment value (`exo_GA_4_1`) | 0.001629 | 0.001629 | No |
| Services public EE-investment value (`exo_GA_5_1`) | 0.000647 | 0.000647 | No |
| **Public BESS-investment value (`exo_GA_3_1`)** | **0.003995** | **0 (baseline)** | **Yes** |
| **PV-gain shock (`exo_PVEff_1`)** | **0.1133** | **0 (baseline)** | **Yes** |
| **Household RTS-investment value (`exo_PV_1`)** | **0.0000791** | **0 (baseline)** | **Yes** |
| Switch 1 (`exo_lAddEE_4_1`) | 1 | 1 | No |
| Switch 2 (`exo_lAddEE_5_1`) | 1 | 1 | No |
| Switch 3 (`exo_CapTrade_1`) | 1 | 1 | No |

Notice that rooftop solar for *industry and services* (rows 3–4 above) is **not** one of the three
that changes — it was already folded into the Industry/Services investment values in Part 2, which stay the
same in both versions. Only grid batteries and *household* rooftop solar are what "NoBESS" strips
out. Comparing the full scenario's results to the NoBESS scenario's results, year by year, tells you
exactly how much of the outcome came from batteries + household solar, and how much came from
everything else.

## Self-check questions (no calculation needed)

1. Why does a 40% saving produce *more than double* the shock of a 20% saving, instead of exactly
   double?
2. Why do investment dollars get divided by 430,000 instead of being used directly?
3. If a scenario had *zero* rooftop-solar and battery data at all, would its full scenario and its
   NoBESS twin be identical? Why?
4. Why doesn't the model just repeat the last known saving-percentage forever, once expert data
   runs out, instead of extrapolating a trend?
5. Which is more sensitive to a single bad/missing data year: a Recipe A shock or a Recipe B
   balance? (Hint: think about what a zero in the middle of the investment column does to the
   balance versus what it does to a percentage-saving column.)

<details>
<summary>Answer key (click to expand in most renderers, otherwise just scroll)</summary>

1. Because the formula is `ln(1/(1−fraction))`, not a straight multiple of the fraction — the
   denominator `(1−fraction)` shrinks faster than the fraction grows, so the ratio blows up.
2. To express it as a *share of the whole economy* rather than a raw dollar figure — the model's
   internal units are GDP shares, not dollars, so every dollar input has to be rescaled the same
   way before it's comparable to everything else in the model.
3. Yes — if the BESS, PV-gain, and household-RTS columns are already zero (or already equal to
   baseline) in the full scenario, there's nothing left to revert, so NoBESS collapses to the same
   numbers as the full scenario.
4. Repeating the last value flat would assume policy effort suddenly stalls right at the edge of
   the data; extrapolating the trend instead assumes the same *pace* of improvement continues,
   which is closer to what "we don't have more data yet" usually means for a policy that's still
   ramping up.
5. A Recipe B balance — a missing/zero year just means "no new deposit that year," and the balance
   keeps most of its value (decays only 10%). A Recipe A shock has no memory at all between years;
   if the underlying saving percentage for one year were wrongly recorded as zero, that year's
   shock would be zero regardless of the years before or after it.

</details>

## One-paragraph summary

Every EE scenario is ten numbers, computed with only two formulas: a **log formula** that turns a
percentage saving/gain into a productivity shock (bigger percentages produce disproportionately
bigger shocks), and a **decaying-balance formula** that turns a stream of yearly investment dollars
into one running total (each year keeps 90% of the old balance and adds the new year's spending,
rescaled by the size of the whole economy). When expert data runs out before the model's final
year, percentage-based shocks keep extending along their historical trend line, while dollar-based
balances simply keep decaying with no new deposits. The "NoBESS" twin of a scenario changes exactly
three of the ten numbers — batteries, PV integration gain, and household rooftop solar — reverting
them to the baseline, so that comparing the two isolates exactly what those three channels
contributed.

*(Note: in the real model, every number you computed above gets added on top of a non-zero
baseline value for that year and column — we set the baseline to zero throughout this exercise
purely to keep the arithmetic focused on the two recipes themselves. That baseline value is itself
not just a flat trend: for the industry/services productivity shocks and their public
EE-investment values, the real Baseline workbook builds it from actual Vietnam rooftop-solar
deployment plans and the VNEEP3 policy program, using the same two recipes taught here — a PV
coverage share run through Recipe A, and an RTS deployment index applied to Recipe B — before any
EE *scenario* number gets added on top. See `docs/energy_efficiency_pathway.md`, "Where the
Baseline's own EE/RTS numbers come from," for the full mechanism.)*
