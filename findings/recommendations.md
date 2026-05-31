# Findings & Recommendations
## DataCo Supply Chain Analytics

> *This document presents the consolidated findings and actionable recommendations produced across all seven analytical modules of the DataCo Supply Chain Analytics engagement. Each recommendation is grounded in SQL-validated data and prioritised by expected business impact. This document is intended for operations leadership, commercial strategy, and senior management.*

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Module 1 — Delivery Performance](#module-1--delivery-performance)
3. [Module 2 — Shipping Mode Efficiency](#module-2--shipping-mode-efficiency)
4. [Module 3 — Profitability & Margin Analysis](#module-3--profitability--margin-analysis)
5. [Module 4 — Regional Sales Imbalance](#module-4--regional-sales-imbalance)
6. [Module 5 — Delivery Risk Identification](#module-5--delivery-risk-identification)
7. [Module 6 — Customer Order Trends](#module-6--customer-order-trends)
8. [Module 7 — Product Category Performance](#module-7--product-category-performance)
9. [Priority Action Plan](#priority-action-plan)

---

## Executive Summary

This analytics engagement investigated seven business problems across 180,519 orders from the DataCo Smart Supply Chain dataset covering the period 2015 to 2018. The analysis was conducted entirely in SQL against a cleaned and validated dataset in Microsoft SQL Server.

The findings paint a consistent picture across all seven modules: **DataCo is a business operating with significant structural inefficiencies that have persisted for years without measurable improvement.**

Three structural problems sit beneath every module finding:

**1. A delivery system that fails the majority of customers**
57.28% of all orders arrive late. This rate has held flat across four consecutive years. The business has not improved its delivery performance at all despite the problem affecting more than half its customer base on every order.

**2. A pricing model that destroys nearly as much value as it creates**
Total gross losses of $3,883,547.35 are 97.89% of total profit of $3,966,902.97. A uniform ~10.17% discount rate is applied across all categories regardless of margin strength, creating loss-making orders in every single product line in the portfolio.

**3. A commercial strategy that treats all customers, segments, and categories identically**
Customer segments are commercially indistinguishable. Product categories receive identical discount treatment. Shipping modes are allocated without regard to order value. The business operates at scale without differentiation — and the data shows the cost of that approach in every module.

Several findings also require immediate data governance action before commercial decisions can be made reliably — most critically the Caguas, Puerto Rico concentration anomaly and the delivery risk flag's lack of independent predictive value.

---

## Module 1 — Delivery Performance

### Key Findings

**F1.1 — 57.28% of all orders are delivered late**
103,400 of 180,519 orders failed to meet the scheduled delivery date. The average customer experience at DataCo is a late delivery. This is the default outcome, not an exception.

**F1.2 — The late delivery rate has not improved in four years**
Late delivery rates held at 57.27% in 2015, 57.30% in 2016, and 57.21% in 2017. The marginal increase to 58.69% in 2018 (partial year) suggests no improvement trajectory. Four years of consistent failure at this scale indicates a structural ceiling the business has been unable to break through.

**F1.3 — No market or region performs acceptably**
All 23 regions across 5 markets show late delivery rates between 51.93% and 60.70%. The best performing region — Canada at 51.93% — still fails more than half its orders. The problem is global and structural, not regional.

**F1.4 — Late deliveries are concentrated in specific shipping modes**
First Class (100% late) and Second Class (79.73% late) together account for 63,030 orders — 34.92% of all orders — and are responsible for a disproportionate share of the late delivery problem.

### Recommendations

**R1.1 — Audit the First Class scheduling configuration immediately**
The 100% late delivery rate on First Class with a perfectly consistent 1-day gap across all 27,814 orders and all 5 markets is almost certainly a system configuration error — the scheduled delivery window is set 1 day shorter than operationally achievable. This should be the first investigation. Correcting this single configuration error would reclassify all 27,814 First Class orders from late to on time, reducing the overall late delivery rate from 57.28% to approximately 42% with zero operational cost or logistics investment.

**R1.2 — Establish a formal on-time delivery KPI with ownership**
Four years of consistent failure without improvement confirms there is no tracked performance target. The business should establish a formal on-time delivery KPI — suggested target: 80% on-time within 12 months — and assign accountability to operations leadership. Without a tracked target, the current rate will persist indefinitely.

**R1.3 — Revise customer-facing delivery promises for underperforming modes**
Until performance is corrected, the delivery promises shown to customers at checkout for First Class and Second Class should be revised to reflect actual performance. Showing a 1-day promise that fails 100% of the time actively damages customer trust on every single order.

**R1.4 — Prioritise regional intervention in Western Europe and Central America**
Western Europe (27,109 orders, 58.52% late) and Central America (28,341 orders, 57.25% late) together represent 30.72% of all orders. Their late delivery rates exceed the global average despite their high volumes. A targeted operational review of last-mile logistics in these two regions offers the highest volume impact for improvement.

---

## Module 2 — Shipping Mode Efficiency

### Key Findings

**F2.1 — First Class has never delivered a single order on time in four years**
Across 27,814 orders, 5 markets, and 4 consecutive years, First Class recorded a 100% late delivery rate with zero exceptions. Every order arrived exactly 1 day late — no more, no less. The zero-variance gap across all geographies and all years is the unmistakable signature of a scheduling misconfiguration.

**F2.2 — The value proposition is inverted — customers paying more receive worse service**
Standard Class (slowest, cheapest) has the lowest late delivery rate at 39.77%. Same Day is next at 47.83%. Second Class follows at 79.73%. First Class is last at 100%. A customer selecting the premium First Class option receives a worse delivery experience — guaranteed — than one selecting the standard option.

**F2.3 — Standard Class is the only mode that exceeds its own promise**
38.60% of Standard Class orders (41,592) arrive ahead of schedule. It is the only mode generating early deliveries at meaningful scale. Its average delivery gap across all markets is effectively zero — it does not just meet its promise, it routinely beats it.

**F2.4 — Second Class failure is structural and global**
Second Class late delivery rates range from 78.94% to 80.42% across all five markets — a spread of less than 2 percentage points. Year over year, rates hold between 79.27% and 80.90% with no improvement. The consistency rules out operational or regional explanations — this is a structural problem embedded in how the mode is configured or contracted.

### Recommendations

**R2.1 — Fix the First Class scheduling configuration before any other logistics action**
This is the same as R1.1 and remains the single highest-impact, lowest-cost action available. No carrier negotiation, no routing change, and no logistics investment is required. The fix is a system configuration correction that should take hours, not months.

**R2.2 — Conduct a formal Second Class carrier performance review**
Second Class failure at ~80% cannot be resolved by a scheduling fix alone. A formal review of Second Class carrier contracts, SLA terms, and routing configurations is required. If the carrier cannot demonstrate a credible improvement plan, alternative carriers or route restructuring should be evaluated.

**R2.3 — Investigate the Same Day 2017 performance spike**
Same Day late delivery spiked from 44.41% in 2016 to 53.47% in 2017 — a 9-percentage-point deterioration — before recovering to 45.00% in 2018. Understanding the cause of this spike would provide operational intelligence that could be applied proactively to prevent recurrence.

**R2.4 — Document Standard Class operational practices as the internal benchmark**
Standard Class consistently meets its delivery promise across all markets and all years. The carrier relationships, routing configurations, and scheduling logic behind Standard Class should be formally documented and used as the internal benchmark when diagnosing and improving the other three modes.

---

## Module 3 — Profitability & Margin Analysis

### Key Findings

**F3.1 — The business is barely profitable in aggregate**
Total profit of $3,966,902.97 on $36,784,735.01 in sales represents a 10.78% margin. However, 33,784 loss-making orders generated $3,883,547.35 in gross losses — 97.89% of total profit. The business is one sustained discount event or volume shift away from aggregate loss.

**F3.2 — Discounting erodes margins with no evidence of compensating volume**
As discount rate increases from 0% to above 20%, average profit per order falls from $26.67 to $18.41 — a reduction of $8.26 per order. The 16–20% discount tier contains 40,116 orders — the same volume as the 6–10% tier — generating $134 less total profit per 1,000 orders. High-volume discounting is not driving proportionally higher order volumes to justify the margin sacrifice.

**F3.3 — Technology generates the highest profit per order but is barely present**
Computers average $157.59 profit per order — 7.2 times the company average. The Technology department averages $77.25 profit per order on just 1,465 orders (0.81% of total). The business's most efficient product category is generating less than 3% of its revenue.

**F3.4 — No customer segment is meaningfully more profitable than another**
Consumer, Corporate, and Home Office show average profit per order of $22.18, $21.95, and $21.44 respectively. Profit differences between segments are driven entirely by order volume, not by pricing power or product mix.

### Recommendations

**R3.1 — Implement a discount governance policy with category-specific caps**
Discounts above 15% are being applied to 60,174 orders (33.33% of all orders) and generating measurably lower profit ratios and per-order profit. The business should establish a discount approval policy requiring commercial justification for any discount above 15%, with particular scrutiny on the above 20% tier. Category-specific caps should reflect each category's margin profile — tighter caps for lower-margin categories, more flexibility for higher-margin ones.

**R3.2 — Build a growth plan for the Technology department**
Doubling Technology order volume from 1,465 to approximately 3,000 orders would add ~$113,000 in profit at current per-order efficiency — equivalent to the entire Outdoors department's current annual contribution — without requiring any improvement in unit economics. This represents the highest return-on-investment commercial opportunity identified in this analysis.

**R3.3 — Investigate loss-making order root causes at the transaction level**
33,784 orders generated $3,883,547.35 in losses. This analysis identifies the scale but not the cause. A follow-up investigation should determine whether losses are concentrated in specific products, customers, discount events, or shipping modes, and whether they represent deliberate commercial decisions or operational inefficiencies that can be eliminated.

**R3.4 — Protect Fishing category investment unconditionally**
Fishing generates $756,220.77 in total profit — 19.06% of company profit — with the highest per-order efficiency of any high-volume category. No ranging, promotional, or supply chain decision should reduce Fishing's commercial priority without a full impact assessment showing how the profit gap would be closed elsewhere.

---

## Module 4 — Regional Sales Imbalance

### Key Findings

**F4.1 — 37% of total company sales originate from a single city**
Caguas, Puerto Rico generated $13,610,266.21 in sales from 66,770 orders — 37% of total revenue. The next largest city, Chicago, contributes 2.17%. This concentration almost certainly reflects a data recording anomaly rather than genuine customer demand from one location.

**F4.2 — Europe and LATAM control 57.5% of total sales**
Europe ($10,872,396.80, 29.56%) and LATAM ($10,277,612.84, 27.94%) together represent more than half of total company revenue. Western Europe alone contributes 16.02% of total sales — more than the entire Africa market.

**F4.3 — Africa has the highest margin potential but the lowest investment**
East Africa leads all regions globally with a 13.97% profit margin. Southern Africa follows at 13.51%. Both exceed Western Europe (10.61%) and Central America (10.88%) — the two highest-volume regions. Africa is being commercially underserved relative to its margin efficiency.

**F4.4 — No region operates at a loss but all margins are thin**
Profit margins across all 23 regions range from 9.91% to 13.51% — a spread of just 3.6 percentage points. The business has no high-margin anchor region. Every region is margin-thin and vulnerable to cost increases or discount events.

### Recommendations

**R4.1 — Investigate the Caguas data anomaly as an immediate data governance priority**
The business should verify whether Caguas, Puerto Rico reflects genuine customer locations or a system recording default — such as a warehouse address or billing system fallback. If it is a data issue, all city-level and customer-level reporting is unreliable and should be suspended until corrected. This is a prerequisite for any customer analytics, retention modelling, or geographic targeting initiative.

**R4.2 — Develop a commercial growth programme for Africa**
Africa's high-margin regions are operating efficiently at very low volume. A targeted commercial development programme focused on order volume growth — rather than margin improvement — in East Africa, Southern Africa, and West Africa could generate significant profit uplift with lower risk than expanding in already saturated high-volume regions.

**R4.3 — Investigate Europe's 2017 average order value increase**
Europe's average order value rose from $197.21 in 2015 to $242.13 in 2017 — a 22.8% increase. Understanding the driver would allow the business to either protect and replicate this improvement or identify whether it represents a temporary anomaly. If driven by product mix or pricing, the same approach could be applied in LATAM and Pacific Asia.

**R4.4 — Review Eastern Asia and Oceania commercial strategy**
Eastern Asia has the lowest profit margin of any region at 9.91% on $1,486,401.34 in sales. Oceania follows at 9.99% on $2,016,654.20. Both generate significant revenue but return margins below the global average. A pricing or product mix review in these two regions could meaningfully improve Pacific Asia's overall margin profile.

---

## Module 5 — Delivery Risk Identification

### Key Findings

**F5.1 — The risk flag is a perfect predictor with zero operational intervention value**
Every order flagged as high risk (98,977) resulted in a confirmed late delivery — 100% precision and 100% recall across 180,519 orders with zero false positives and zero false negatives. This perfect alignment confirms the flag is derived from the same scheduling calculation that determines whether an order will be late — it is a scheduling mirror, not an early warning system.

**F5.2 — Delivery risk is uniformly distributed across all geographies**
High risk rates span from 48.80% (Canada) to 57.96% (Central Africa) — a spread of just 9.16 percentage points across all 23 regions. Risk is not driven by geography. It is entirely determined by shipping mode allocation and scheduling logic.

**F5.3 — Order value has no relationship with delivery risk**
High risk rates across five sales tiers ranging from under $100 to $500 and above vary by just 0.80 percentage points. A $62 order and a $500 order carry virtually identical delivery risk. The business does not prioritise high-value orders for more reliable fulfilment.

**F5.4 — First Class drives the highest risk volume**
95.32% of First Class orders are flagged high risk — 26,513 orders. Fixing the First Class scheduling configuration (R1.1, R2.1) would remove 26,513 orders from the high risk pool — a 26.8% reduction in total high risk orders from a single operational change.

### Recommendations

**R5.1 — Do not invest in the current risk flag as an intervention tool**
The flag's perfect alignment with actual outcomes confirms it has no independent predictive value beyond what is already known from the shipping mode and schedule data. Building intervention workflows around it would provide no operational benefit.

**R5.2 — Rebuild the risk flag using real-time operational signals**
To make the flag genuinely useful, it should be rebuilt to incorporate independent data sources — carrier scan events, warehouse processing timestamps, route disruption alerts, and weather data. A flag that identifies at-risk orders before they are determined to be late by the scheduling system would enable meaningful operational response.

**R5.3 — Implement value-based order routing**
Since order value has no relationship with delivery risk, the business has an opportunity to introduce preferential routing for high-value orders. Assigning orders above $300 to Standard Class or Same Day — the two most reliable modes — would protect the highest-revenue orders from the chronic failure rates of First Class and Second Class without changing the overall logistics operation.

---

## Module 6 — Customer Order Trends

### Key Findings

**F6.1 — The business has three segment labels but effectively one customer profile**
Consumer, Corporate, and Home Office are commercially indistinguishable across every measurable dimension — orders per customer (8.67–8.78), average order value ($202.34–$204.22), average profit per order ($21.44–$22.18), top product categories (identical rank order), and market distribution (within 1% across all five markets). The segmentation exists as a label but has no analytical or commercial foundation.

**F6.2 — The top customer is generating a net loss**
Customer 791 (Corporate, Canton) is the highest sales-value customer at $10,524.17 across 43 orders but generates a total profit of -$866.38. The business's most commercially active individual customer is a loss-making relationship that would be invisible in aggregate reporting.

**F6.3 — A 2017 pricing shift affected all segments simultaneously and equally**
Average order value increased by approximately $25 in 2017 for all three segments simultaneously — Consumer from $197.28 to $222.43, Corporate from $195.77 to $222.34, Home Office from $196.58 to $220.06. The uniformity confirms this was a company-wide event, not segment-specific behaviour.

**F6.4 — Caguas concentration distorts customer-level analysis**
6 of the top 10 highest-value customers are from Caguas, Puerto Rico. Until the data anomaly identified in Module 4 is resolved, individual customer records from this city should be treated with caution.

### Recommendations

**R6.1 — Redesign the segmentation framework around behavioural signals**
The current three-segment model has no analytical foundation. The business should build a new segmentation framework based on actual behavioural signals — order frequency, lifetime value, category concentration, discount sensitivity, and delivery mode preference. A value-based segmentation (High, Mid, Low value tiers) would immediately enable more targeted commercial decisions.

**R6.2 — Conduct an account review for all loss-making customers**
Customer 791 demonstrates the pattern of high activity combined with negative profit — typically the result of excessive discounting at the account level. A systematic review of all customers with negative lifetime profit should be conducted, with the goal of renegotiating terms, adjusting product mix, or in extreme cases, exiting the relationship.

**R6.3 — Investigate and document the 2017 order value increase**
The $25 average order value increase in 2017 across all segments represents a meaningful revenue uplift. Understanding whether it was a deliberate pricing decision, a product ranging change, or an external market factor would allow the business to assess whether it can be sustained or replicated.

**R6.4 — Resolve the Caguas data issue before any customer analytics investment**
Any customer lifetime value model, retention programme, or personalisation initiative built on this dataset will be distorted by the Caguas concentration. This should be resolved as a prerequisite to any customer analytics work.

---

## Module 7 — Product Category Performance

### Key Findings

**F7.1 — Every category in the portfolio carries loss-making orders**
All 50 product categories contain orders generating negative profit. Loss order rates are uniform between 13% and 24% across every category regardless of volume, margin, or department. This is a company-wide structural issue — almost certainly driven by the uniform discount rate applied across all categories — not a product portfolio problem.

**F7.2 — Net profit is a thin margin between two large opposing forces**
Fishing's $756,220.77 net profit sits alongside $728,570.95 in gross losses within the same category — meaning 49.1% of Fishing's gross profit is destroyed by loss-making orders. This pattern repeats across all top categories. The business is not running a profitable portfolio with weak spots — it is running a portfolio where every category simultaneously generates significant profit and significant losses.

**F7.3 — Computers generate the highest profit per order in the entire portfolio**
Computers average $157.59 profit per order — 7.2 times the company average — on 442 orders representing 1.80% of sales. The Technology department averages $77.25 profit per order — the highest of any department — on 1,465 orders. The most efficient category is generating less than 2% of revenue.

**F7.4 — Fan Shop dominates by volume but not by efficiency**
Fan Shop generates 46.24% of total profit but its margin (10.72%) is below Apparel (11.06%), Outdoors (11.59%), Fitness (11.72%), and Technology (10.89%). The business is heavily dependent on a high-volume, below-average-efficiency department.

**F7.5 — Book Shop, Pet Shop, and Health & Beauty are structurally marginal**
Together these three departments contribute less than 0.35% of total company profit at margins of 7.02%, 8.64%, and 8.95% respectively — all below the company average of 10.78%.

### Recommendations

**R7.1 — Protect Fishing as the portfolio's commercial anchor**
Fishing contributes 19.06% of company profit with the highest per-order efficiency of any high-volume category. It should be treated as a protected commercial asset. No promotional, ranging, or supply chain decision should reduce its priority without a full impact assessment.

**R7.2 — Build a dedicated Technology growth initiative**
Doubling Technology order volume from 1,465 to 3,000 orders would add approximately $113,000 in profit at current efficiency — equivalent to the entire Outdoors department's annual contribution. This is the highest return-on-investment commercial opportunity in the portfolio.

**R7.3 — Implement category-differentiated discount governance**
The uniform ~10.17% discount rate applied across all 50 categories is the most likely structural cause of the company-wide loss-making order problem. Higher-margin categories can absorb moderate discounts. Lower-margin categories (Shop By Sport at 9.91%, Cardio Equipment at 10.37%) should have tighter discount caps. This single policy change — if implemented across all categories — would reduce the loss-making order rate below 18.71% without requiring any product ranging changes.

**R7.4 — Conduct a formal portfolio review for Book Shop, Pet Shop, and Health & Beauty**
Three departments contributing less than 0.35% of total profit at below-average margins are consuming supply chain capacity and operational resources. A formal review should assess whether these departments can reach viable scale within 12–18 months or whether the business should exit these categories and redeploy resources toward Technology and Fishing growth.

**R7.5 — Address the gross profit vs gross loss imbalance before expanding any category**
Expanding any category without first fixing the underlying loss-making order mechanism would simply scale both profit and loss proportionally. The discount governance recommendation (R7.3) should be implemented before any volume growth initiatives are launched in any category.

---

## Priority Action Plan

| Priority | Recommendation | Owner | Effort | Expected Impact |
|---|---|---|---|---|
| 1 | Fix First Class scheduling configuration | Operations / IT | Low — configuration change | Reduce overall late rate from 57.28% to ~42% immediately |
| 2 | Investigate Caguas data anomaly | Data Governance | Low — audit and validate | Restore integrity of all geographic and customer reporting |
| 3 | Implement discount governance policy | Commercial / Finance | Medium — policy design | Reduce loss-making order rate below 18.71% |
| 4 | Conduct Second Class carrier review | Logistics | Medium — contract review | Reduce Second Class late rate from 79.73% |
| 5 | Build Technology volume growth plan | Merchandising | Medium — commercial planning | Add ~$113K profit per 1,500 additional Technology orders |
| 6 | Redesign customer segmentation framework | Customer Strategy | Medium — analytical work | Enable targeted commercial strategy across 20,652 customers |
| 7 | Conduct account review for loss-making customers | Sales / Account Management | Low — data pull and review | Eliminate negative-profit customer relationships |
| 8 | Develop Africa commercial growth programme | Commercial Strategy | High — market development | Unlock high-margin volume in underserved regions |
| 9 | Rebuild delivery risk flag with operational signals | Technology / Operations | High — data engineering | Create genuine early warning system for late deliveries |
| 10 | Review Book Shop, Pet Shop, Health & Beauty portfolio | Merchandising | Low — strategic review | Redeploy resources toward higher-return categories |

---

## Analytical Methodology

| Item | Detail |
|---|---|
| Dataset | DataCo Smart Supply Chain — Kaggle |
| Total Records | 180,519 order line items |
| Analysis Period | 2015 – 2018 |
| Tool | Microsoft SQL Server (SSMS) |
| Query Source | DataCo.dbo.vw_DataCo_Cleaned |
| Primary Key | Order_Item_Id (NOT NULL) |
| Late Delivery Definition | Days_for_shipping_real > Days_for_shipment_scheduled |
| Profit Definition | Order_Profit_Per_Order at order line item level |
| Cleaning Approach | Non-destructive — raw data preserved, analysis via cleaned view |
| PII Handling | Customer_Email, Fname, Lname, Street, Password excluded from all outputs |

---

*Full SQL scripts, schema documentation, and data cleaning methodology available in `/scripts/`.*
*KPI reference figures available in `/findings/kpi_summary.md`.*
*Project repository: DataCo-Supply-Chain-SQL-Analytics*
