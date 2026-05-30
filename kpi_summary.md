# KPI Summary
## DataCo Supply Chain Analytics

> *This document consolidates the key performance indicators investigated across all seven analytical modules. All figures are derived from the DataCo Smart Supply Chain dataset (180,519 orders, 2015–2018) and validated through SQL analysis in Microsoft SQL Server.*

---

## Dataset Overview

| KPI | Value |
|---|---|
| Total Orders | 180,519 |
| Total Customers | 20,652 |
| Unique Orders | 65,752 |
| Total Revenue | $36,784,735.01 |
| Total Profit | $3,966,902.97 |
| Average Order Value | $203.77 |
| Average Orders Per Customer | 8.74 |
| Product Categories | 50 |
| Markets | 5 |
| Regions | 23 |
| Analysis Period | 2015 – 2018 |

---

## Module 1 — Delivery Performance

| KPI | Value |
|---|---|
| Total Orders | 180,519 |
| Late Orders | 103,400 |
| **Overall Late Delivery Rate** | **57.28%** |
| On-Time Orders | 77,119 |
| On-Time Delivery Rate | 42.72% |
| Average Delivery Gap | +0.57 days |
| Best Performing Shipping Mode | Standard Class (39.77% late) |
| Worst Performing Shipping Mode | First Class (100.00% late) |
| Worst Performing Region | Central Africa (60.70% late) |
| Best Performing Region | Canada (51.93% late) |
| Late Delivery Rate — 2015 | 57.27% |
| Late Delivery Rate — 2016 | 57.30% |
| Late Delivery Rate — 2017 | 57.21% |
| Late Delivery Rate — 2018 | 58.69% |

**Headline:** More than half of all customer orders arrive late. The rate has not improved in four years.

---

## Module 2 — Shipping Mode Efficiency

| Shipping Mode | Orders | Order Share | Late Rate | Avg Gap |
|---|---|---|---|---|
| Standard Class | 107,752 | 59.69% | 39.77% | 0.00 days |
| Second Class | 35,216 | 19.51% | 79.73% | +1.99 days |
| First Class | 27,814 | 15.41% | 100.00% | +1.00 day |
| Same Day | 9,737 | 5.39% | 47.83% | +0.48 days |

| KPI | Value |
|---|---|
| Modes with majority late delivery | 3 of 4 |
| First Class on-time orders | 0 |
| First Class delivery gap (all orders) | Exactly +1 day — zero variance |
| Standard Class advance shipping rate | 38.60% |
| Orders on premium modes (First + Second Class) | 63,030 (34.92%) |

**Headline:** The most expensive shipping modes are the least reliable. Standard Class — the slowest option — is the only mode that consistently meets its delivery promise.

---

## Module 3 — Profitability & Margin Analysis

| KPI | Value |
|---|---|
| Total Revenue | $36,784,735.01 |
| Total Profit | $3,966,902.97 |
| **Overall Profit Margin** | **10.78%** |
| Average Profit Per Order | $21.97 |
| Average Discount Rate | 10.17% |
| Loss-Making Orders | 33,784 |
| Loss-Making Order Rate | 18.71% |
| Total Gross Loss | $3,883,547.35 |
| Gross Loss as % of Total Profit | 97.89% |
| Top Profit Category | Fishing ($756,220.77) |
| Highest Avg Profit Per Order | Computers ($157.59) |
| Most Profitable Department | Fan Shop ($1,834,155.44 — 46.24%) |
| Lowest Margin Department | Book Shop (7.02%) |

| Discount Tier | Avg Profit Ratio | Avg Profit Per Order |
|---|---|---|
| 0% — No Discount | 0.1275 | $26.67 |
| 6–10% | 0.1245 | $23.51 |
| 1–5% | 0.1196 | $23.26 |
| 11–15% | 0.1189 | $21.47 |
| 16–20% | 0.1179 | $20.14 |
| Above 20% | 0.1197 | $18.41 |

**Headline:** Total gross losses ($3,883,547.35) are 97.89% of total profit ($3,966,902.97). The business is one bad quarter away from aggregate loss.

---

## Module 4 — Regional Sales Imbalance

| Market | Orders | Total Sales | Sales Share | Profit Margin |
|---|---|---|---|---|
| Europe | 50,252 | $10,872,396.80 | 29.56% | 10.75% |
| LATAM | 51,594 | $10,277,612.84 | 27.94% | 10.93% |
| Pacific Asia | 41,260 | $8,273,743.74 | 22.49% | 10.37% |
| USCA | 25,799 | $5,066,528.71 | 13.77% | 11.14% |
| Africa | 11,614 | $2,294,452.93 | 6.24% | 10.99% |

| KPI | Value |
|---|---|
| Top Region by Sales | Western Europe ($5,894,380.77 — 16.02%) |
| Highest Margin Region | Southern Africa (13.51%) |
| Lowest Margin Region | Eastern Asia (9.91%) |
| Single City Sales Concentration | Caguas, Puerto Rico — 37.00% of total sales |
| Europe + LATAM Combined Sales Share | 57.50% |
| Africa Sales Share | 6.24% |
| Africa Highest Region Margin | East Africa (13.97%) |

**Headline:** 37% of total company sales originate from a single city — Caguas, Puerto Rico — almost certainly a data recording anomaly. No market operates at a loss but Africa's margins are the highest despite the lowest investment.

---

## Module 5 — Delivery Risk Identification

| KPI | Value |
|---|---|
| High Risk Orders (flag = 1) | 98,977 |
| Low Risk Orders (flag = 0) | 81,542 |
| High Risk Order Share | 54.83% |
| Risk Flag Precision | 100.00% |
| Risk Flag Recall | 100.00% |
| False Positives | 0 |
| False Negatives | 0 |
| Highest Risk Shipping Mode | First Class (95.32% flagged) |
| Lowest Risk Shipping Mode | Standard Class (38.07% flagged) |
| Highest Risk Region | Central Africa (57.96% flagged) |
| Lowest Risk Region | Canada (48.80% flagged) |
| Risk Rate Spread Across All Regions | 9.16 percentage points |
| Risk Rate Spread Across Sales Tiers | 0.80 percentage points |

**Headline:** The delivery risk flag perfectly predicts actual late delivery with zero exceptions across 180,519 orders — confirming it is a scheduling calculation output, not an independent early warning system.

---

## Module 6 — Customer Order Trends

| Customer Segment | Customers | Orders | Avg Orders/Customer | Avg Order Value | Total Profit | Profit Share |
|---|---|---|---|---|---|---|
| Consumer | 10,695 | 93,504 | 8.74 | $204.22 | $2,073,487.67 | 52.27% |
| Corporate | 6,239 | 54,789 | 8.78 | $203.84 | $1,202,574.96 | 30.32% |
| Home Office | 3,718 | 32,226 | 8.67 | $202.34 | $690,840.34 | 17.42% |

| KPI | Value |
|---|---|
| Avg Order Value Spread Across Segments | $1.88 |
| Avg Profit Per Order Spread Across Segments | $0.74 |
| Top Category (all segments) | Cleats |
| Market Distribution Variance Across Segments | < 1 percentage point |
| Top Customer by Sales | Customer 791 — $10,524.17 |
| Top Customer Profit | Customer 791 — **-$866.38** (loss-making) |
| Caguas Customers in Top 10 | 6 of 10 |
| 2017 Avg Order Value Increase (all segments) | ~$25 simultaneously |

**Headline:** Consumer, Corporate, and Home Office segments are commercially indistinguishable across every measurable dimension. The business has segment labels but not a segment strategy.

---

## Module 7 — Product Category Performance

| KPI | Value |
|---|---|
| Total Product Categories | 50 |
| Categories with Loss-Making Orders | 50 of 50 (100%) |
| Average Loss Order Rate Across Categories | ~18.7% |
| Top Category by Profit | Fishing ($756,220.77 — 19.06% of total profit) |
| Top Category Avg Profit Per Order | Computers ($157.59) |
| Lowest Margin High-Volume Category | Shop By Sport (9.91%) |
| Highest Margin Department | Fitness (11.72%) |
| Lowest Margin Department | Book Shop (7.02%) |
| Fan Shop Profit Share | 46.24% |
| Technology Avg Profit Per Order | $77.25 |
| Technology Order Share | 0.81% of total orders |
| Avg Discount Rate Across All Top Categories | ~10.17% (uniform) |

| Department | Orders | Profit Share | Margin |
|---|---|---|---|
| Fan Shop | 66,861 | 46.24% | 10.72% |
| Apparel | 48,998 | 22.23% | 11.06% |
| Golf | 33,220 | 12.54% | 10.79% |
| Footwear | 14,525 | 10.34% | 10.24% |
| Outdoors | 9,686 | 3.66% | 11.59% |
| Technology | 1,465 | 2.85% | 10.89% |
| Fitness | 2,479 | 1.17% | 11.72% |
| Discs Shop | 2,026 | 0.61% | 10.57% |
| Health & Beauty | 362 | 0.24% | 8.95% |
| Pet Shop | 492 | 0.09% | 8.64% |
| Book Shop | 405 | 0.02% | 7.02% |

**Headline:** Every category generates losses. Net profit is the thin residual between two large opposing forces. Fishing alone contributes 19.06% of total company profit — making it the single most critical asset in the portfolio.

---

## Cross-Module Critical Findings

| # | Finding | Module |
|---|---|---|
| 1 | 57.28% of orders are delivered late — unchanged for 4 years | M1 |
| 2 | First Class shipping has a 100% late delivery rate — likely a scheduling misconfiguration | M1, M2 |
| 3 | Gross losses ($3,883,547.35) are 97.89% of total profit — the business is fragile | M3 |
| 4 | 37% of total sales originate from a single city — data anomaly requiring investigation | M4 |
| 5 | The delivery risk flag is a perfect predictor with zero operational intervention value | M5 |
| 6 | All three customer segments are commercially identical — no effective segmentation exists | M6 |
| 7 | Every product category carries loss-making orders — a structural pricing problem | M7 |

---

## Top 5 Highest Impact Recommendations

| Priority | Recommendation | Expected Impact | Module |
|---|---|---|---|
| 1 | Fix First Class scheduling configuration | Reduce overall late rate from 57.28% to ~42% overnight | M1, M2 |
| 2 | Implement category-differentiated discount policy | Reduce loss-making order rate below 18.71% | M3, M7 |
| 3 | Investigate and resolve Caguas data anomaly | Restore integrity of all geographic and customer analysis | M4, M6 |
| 4 | Build a Technology volume growth plan | Add ~$113K profit per 1,500 additional orders at current efficiency | M3, M7 |
| 5 | Redesign customer segmentation around behavioural signals | Enable targeted commercial strategy across 20,652 customers | M6 |

---

*All KPIs derived from DataCo.dbo.vw_DataCo_Cleaned — 180,519 rows.*
*SQL analysis conducted in Microsoft SQL Server (SSMS).*
*Full query scripts available in `/scripts/analysis/`.*
