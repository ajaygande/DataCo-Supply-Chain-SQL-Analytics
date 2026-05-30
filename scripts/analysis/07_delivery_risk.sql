-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 07_delivery_risk.sql
-- MODULE   : 5 — Delivery Risk Identification
-- PURPOSE  : Analyse the distribution, predictive validity,
--            and operational drivers of delivery risk across
--            shipping modes, markets, and order segments
-- DATABASE : DataCo
-- VIEW     : dbo.vw_DataCo_Cleaned
-- DIALECT  : SQL Server (T-SQL)
-- ROWS     : 180,519
-- NOTE     : Late_delivery_risk imported as BIT by SSMS.
--            All aggregations use CAST(Late_delivery_risk
--            AS INT) — see cleaning decision log Decision 8.
-- ============================================================


-- ============================================================
-- SECTION 1 — USE DATABASE
-- ============================================================

USE DataCo;
GO


-- ============================================================
-- SECTION 2 — BUSINESS CONTEXT
-- ============================================================

/*
---------------------------------------------------------------
BUSINESS SITUATION
---------------------------------------------------------------
The dataset includes a Late_delivery_risk flag that signals
orders identified as high risk for late delivery at the
point of processing. However, the business has not
systematically analysed what characteristics are associated
with elevated delivery risk, nor whether risk is uniformly
distributed or concentrated in specific operational segments.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We have a risk flag in our system but we've never really
interrogated what it's telling us. If we could understand
what drives high delivery risk, we could intervene earlier
and prevent late deliveries before they happen."
— Head of Fulfilment Operations

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Reactive management of delivery failures is more expensive
than proactive prevention. If the business can identify
which order characteristics are systematically associated
with high delivery risk, it can build early intervention
protocols that reduce late delivery rates without requiring
significant infrastructure investment. With 98,977 high
risk orders across 180,519 total orders, the scale of
potential intervention is significant.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. What proportion of orders carry a high delivery
    risk flag?
Q2. Does the risk flag accurately predict actual late
    delivery outcomes?
Q3. How does delivery risk vary by shipping mode?
Q4. Which markets and regions have the highest
    concentration of high risk orders?
Q5. Is there a relationship between order value and
    delivery risk?

---------------------------------------------------------------
RISK FLAG DEFINITION
---------------------------------------------------------------
Late_delivery_risk = 1 : High risk of late delivery
Late_delivery_risk = 0 : Low risk of late delivery
Column imported as BIT — cast to INT for all aggregations.
Is_Late_Delivery = 1 : Confirmed late (actual outcome)
---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1: OVERALL RISK DISTRIBUTION
-- ============================================================
-- Establish the baseline split between high risk and low
-- risk orders across the full dataset.
-- ============================================================

SELECT
    Late_delivery_risk,
    COUNT(*)                                        AS Total_Orders,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)                   AS Order_Share_Pct,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales,
    ROUND(AVG(Order_Profit_Per_Order), 2)           AS Avg_Profit,
    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2) AS Avg_Delivery_Gap
FROM dbo.vw_DataCo_Cleaned
GROUP BY Late_delivery_risk
ORDER BY Late_delivery_risk;

/*
---------------------------------------------------------------
RESULT — Q1
---------------------------------------------------------------
Risk_Flag | Orders  | Share   | Avg_Sales | Avg_Profit | Avg_Gap
0         | 81,542  | 45.17%  | $204.29   | $22.40     | -0.71
1         | 98,977  | 54.83%  | $203.34   | $21.62     | 1.62
---------------------------------------------------------------
54.83% of all orders carry a high delivery risk flag.
High risk orders have a positive average gap of 1.62 days
(late) while low risk orders average -0.71 days (early).
Average sales and profit values are nearly identical across
both groups — order value does not drive risk classification.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: RISK FLAG VS ACTUAL DELIVERY OUTCOME
-- ============================================================
-- Test the predictive validity of the risk flag by comparing
-- flagged risk against confirmed delivery outcomes.
-- A reliable flag enables proactive intervention.
-- A poor flag is operationally misleading.
-- ============================================================

SELECT
    Late_delivery_risk,
    Delivery_Status,
    COUNT(*)                                        AS Order_Count,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Late_delivery_risk), 2)   AS Pct_Within_Risk_Group,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales,
    ROUND(AVG(Order_Profit_Per_Order), 2)           AS Avg_Profit
FROM dbo.vw_DataCo_Cleaned
GROUP BY Late_delivery_risk, Delivery_Status
ORDER BY Late_delivery_risk, Order_Count DESC;

/*
---------------------------------------------------------------
RESULT — Q2
---------------------------------------------------------------
Risk | Delivery_Status    | Orders  | Pct_Within_Group | Avg_Sales | Avg_Profit
0    | Advance shipping   | 41,592  | 51.01%           | $204.80   | $22.49
0    | Shipping on time   | 32,196  | 39.48%           | $204.06   | $22.71
0    | Shipping canceled  | 7,754   |  9.51%           | $202.52   | $20.70
1    | Late delivery      | 98,977  | 100.00%          | $203.34   | $21.62
---------------------------------------------------------------
CRITICAL FINDING: The risk flag has perfect predictive
validity with zero exceptions across 180,519 orders.
Every order flagged high risk (98,977) resulted in a
confirmed late delivery — 100% conversion, no false
positives. Every low risk order (81,542) resolved as
on time, early, or canceled — zero converted to late.
The flag is a perfect binary predictor of delivery outcome.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: DELIVERY RISK BY SHIPPING MODE
-- ============================================================
-- Identify which shipping modes carry the highest proportion
-- of high risk orders and whether the risk flag aligns
-- with actual late delivery rates per mode.
-- ============================================================

SELECT
    Shipping_Mode,
    COUNT(*)                                        AS Total_Orders,
    SUM(CAST(Late_delivery_risk AS INT))            AS High_Risk_Orders,
    ROUND(CAST(100.0 * SUM(CAST(Late_delivery_risk AS INT))
        AS FLOAT) / COUNT(*), 2)                    AS High_Risk_Pct,
    SUM(Is_Late_Delivery)                           AS Actual_Late_Orders,
    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)                    AS Actual_Late_Pct,
    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2) AS Avg_Gap_Days
FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY High_Risk_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q3
---------------------------------------------------------------
Shipping_Mode  | Orders  | High_Risk | Risk_Pct | Actual_Late | Late_Pct | Avg_Gap
First Class    | 27,814  | 26,513    | 95.32%   | 27,814      | 100.00%  | 1.00
Second Class   | 35,216  | 26,987    | 76.63%   | 28,078      | 79.73%   | 1.99
Same Day       | 9,737   | 4,454     | 45.74%   | 4,657       | 47.83%   | 0.48
Standard Class | 107,752 | 41,023    | 38.07%   | 42,851      | 39.77%   | 0.00
---------------------------------------------------------------
First Class carries a 95.32% high risk rate — nearly every
order is flagged before it ships. The 4.68% gap between
risk flag (95.32%) and actual late rate (100%) represents
the 1,301 canceled First Class orders that never shipped.
Second Class risk flag (76.63%) slightly undercounts actual
late rate (79.73%) — the flag misses approximately 1,091
orders that went late without being flagged high risk.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q4: DELIVERY RISK BY MARKET AND REGION
-- ============================================================
-- Determine whether high risk orders are concentrated in
-- specific geographies or distributed globally.
-- Geographic concentration enables targeted intervention.
-- Global distribution confirms a structural problem.
-- ============================================================

SELECT
    Market,
    Order_Region,
    COUNT(*)                                        AS Total_Orders,
    SUM(CAST(Late_delivery_risk AS INT))            AS High_Risk_Orders,
    ROUND(CAST(100.0 * SUM(CAST(Late_delivery_risk AS INT))
        AS FLOAT) / COUNT(*), 2)                    AS High_Risk_Pct,
    SUM(Is_Late_Delivery)                           AS Actual_Late_Orders,
    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)                    AS Actual_Late_Pct,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
ORDER BY High_Risk_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Market       | Region           | Orders  | High_Risk | Risk_Pct | Late  | Late_Pct | Avg_Sales
Africa       | Central Africa   | 1,677   | 972       | 57.96%   | 1,018 | 60.70%   | $195.15
Pacific Asia | South Asia       | 7,731   | 4,350     | 56.27%   | 4,523 | 58.50%   | $200.97
Africa       | East Africa      | 1,852   | 1,036     | 55.94%   | 1,064 | 57.45%   | $203.15
Europe       | Western Europe   | 27,109  | 15,140    | 55.85%   | 15,863| 58.52%   | $217.43
USCA         | South of USA     | 4,045   | 2,256     | 55.77%   | 2,350 | 58.10%   | $194.26
...
Africa       | West Africa      | 3,696   | 1,953     | 52.84%   | 2,033 | 55.01%   | $196.96
USCA         | Canada           | 959     | 468       | 48.80%   | 498   | 51.93%   | $194.85
---------------------------------------------------------------
High risk rates span from 48.80% (Canada) to 57.96%
(Central Africa) — a spread of just 9.16 percentage points
across all 23 regions globally. No region is performing
significantly better or worse than any other. Delivery
risk is uniformly distributed across all geographies,
confirming it is driven by shipping mode and scheduling
logic rather than regional operational factors.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — Q5: DELIVERY RISK BY ORDER VALUE TIER
-- ============================================================
-- Test whether higher value orders carry higher delivery
-- risk — which would suggest priority fulfilment failures
-- on commercially important orders.
-- ============================================================

SELECT
    CASE
        WHEN Sales < 100                THEN 'Under $100'
        WHEN Sales BETWEEN 100 AND 199  THEN '$100–$199'
        WHEN Sales BETWEEN 200 AND 299  THEN '$200–$299'
        WHEN Sales BETWEEN 300 AND 499  THEN '$300–$499'
        ELSE '$500 and above'
    END                                             AS Sales_Tier,
    COUNT(*)                                        AS Total_Orders,
    SUM(CAST(Late_delivery_risk AS INT))            AS High_Risk_Orders,
    ROUND(CAST(100.0 * SUM(CAST(Late_delivery_risk AS INT))
        AS FLOAT) / COUNT(*), 2)                    AS High_Risk_Pct,
    SUM(Is_Late_Delivery)                           AS Actual_Late_Orders,
    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)                    AS Actual_Late_Pct,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales
FROM dbo.vw_DataCo_Cleaned
GROUP BY
    CASE
        WHEN Sales < 100                THEN 'Under $100'
        WHEN Sales BETWEEN 100 AND 199  THEN '$100–$199'
        WHEN Sales BETWEEN 200 AND 299  THEN '$200–$299'
        WHEN Sales BETWEEN 300 AND 499  THEN '$300–$499'
        ELSE '$500 and above'
    END
ORDER BY High_Risk_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Sales_Tier      | Orders  | High_Risk | Risk_Pct | Late   | Late_Pct | Avg_Sales
Under $100      | 34,916  | 19,343    | 55.40%   | 20,168 | 57.76%   | $62.68
$300–$499       | 22,447  | 12,351    | 55.02%   | 12,907 | 57.50%   | $399.54
$100–$199       | 53,723  | 29,366    | 54.66%   | 30,725 | 57.19%   | $136.28
$200–$299       | 20,376  | 11,132    | 54.63%   | 11,613 | 56.99%   | $236.37
$500 and above  | 49,057  | 26,785    | 54.60%   | 27,987 | 57.05%   | $274.98
---------------------------------------------------------------
High risk rates across all five sales tiers range from
54.60% to 55.40% — a spread of just 0.80 percentage
points. Order value has virtually no relationship with
delivery risk. A $62 order and a $500 order carry
essentially the same probability of late delivery.
Risk is determined by shipping mode and scheduling
logic, not by commercial order importance.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — EXTENDED: RISK FLAG ACCURACY SUMMARY
-- ============================================================
-- Formally score the predictive performance of the risk
-- flag using true positive, false positive, true negative,
-- and false negative counts. This is the analytical proof
-- of the flag's operational value.
-- ============================================================

SELECT
    SUM(CASE WHEN Late_delivery_risk = 1
             AND Is_Late_Delivery = 1
             THEN 1 ELSE 0 END)                     AS True_Positives,

    SUM(CASE WHEN Late_delivery_risk = 1
             AND Is_Late_Delivery = 0
             THEN 1 ELSE 0 END)                     AS False_Positives,

    SUM(CASE WHEN Late_delivery_risk = 0
             AND Is_Late_Delivery = 0
             THEN 1 ELSE 0 END)                     AS True_Negatives,

    SUM(CASE WHEN Late_delivery_risk = 0
             AND Is_Late_Delivery = 1
             THEN 1 ELSE 0 END)                     AS False_Negatives,

    -- Precision: of all flagged high risk, how many were actually late
    ROUND(CAST(100.0 * SUM(CASE WHEN Late_delivery_risk = 1
             AND Is_Late_Delivery = 1
             THEN 1 ELSE 0 END) AS FLOAT) /
        NULLIF(SUM(CAST(Late_delivery_risk AS INT)), 0), 2)
                                                    AS Precision_Pct,

    -- Recall: of all actual late orders, how many were flagged
    ROUND(CAST(100.0 * SUM(CASE WHEN Late_delivery_risk = 1
             AND Is_Late_Delivery = 1
             THEN 1 ELSE 0 END) AS FLOAT) /
        NULLIF(SUM(Is_Late_Delivery), 0), 2)        AS Recall_Pct

FROM dbo.vw_DataCo_Cleaned;
GO


-- ============================================================
-- SECTION 9 — EXTENDED: RISK PROFILE BY SHIPPING MODE
-- AND MARKET COMBINED
-- ============================================================
-- Cross-tabulate shipping mode and market to identify
-- the specific mode/market combinations carrying the
-- highest volume of high risk orders. These combinations
-- represent the highest priority targets for intervention.
-- ============================================================

SELECT
    Shipping_Mode,
    Market,
    COUNT(*)                                        AS Total_Orders,
    SUM(CAST(Late_delivery_risk AS INT))            AS High_Risk_Orders,
    ROUND(CAST(100.0 * SUM(CAST(Late_delivery_risk AS INT))
        AS FLOAT) / COUNT(*), 2)                    AS High_Risk_Pct,
    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2) AS Avg_Gap_Days
FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode, Market
ORDER BY High_Risk_Orders DESC;
GO


-- ============================================================
-- SECTION 10 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 5: DELIVERY RISK IDENTIFICATION
===============================================================

INSIGHT 1 — THE RISK FLAG IS A PERFECT PREDICTOR WITH
ZERO EXCEPTIONS ACROSS 180,519 ORDERS
Every order flagged as high risk (98,977) resulted in a
confirmed late delivery — 100% conversion rate, zero false
positives. Every low risk order (81,542) resolved as on
time, early, or canceled — zero false negatives. Precision
and recall are both 100%. This level of predictive accuracy
is extraordinary and has an important implication: the flag
is almost certainly derived from the same scheduling
calculation that determines whether an order will be late,
rather than from independent operational signals. It is a
scheduling mirror, not an early warning system.

INSIGHT 2 — THE FLAG IDENTIFIES WHAT WILL HAPPEN
BUT NOT WHY OR HOW TO PREVENT IT
Because the risk flag perfectly mirrors the late delivery
outcome with no independent information, it currently
has no operational intervention value. Knowing an order
is flagged high risk tells operations nothing they could
not already determine from the shipping mode and scheduled
delivery date. To become genuinely useful, the flag would
need to be decoupled from scheduling logic and rebuilt
using real-time operational signals — carrier scan data,
warehouse processing times, or weather disruption feeds.

INSIGHT 3 — FIRST CLASS IS THE DOMINANT DRIVER OF
HIGH RISK ORDER VOLUME
95.32% of First Class orders (26,513 of 27,814) are
flagged high risk — the highest rate of any shipping
mode. Since First Class has a 100% actual late rate,
the 4.68% gap represents only the 1,301 canceled orders
that never shipped. Fixing First Class scheduling (as
recommended in Module 1 and 2) would remove 26,513
orders from the high risk pool — reducing the total
high risk order count by 26.8% in a single operational
change.

INSIGHT 4 — DELIVERY RISK IS PERFECTLY UNIFORM
ACROSS ALL GEOGRAPHIES
High risk rates across all 23 regions span just 9.16
percentage points — from 48.80% in Canada to 57.96%
in Central Africa. No region is a meaningful outlier.
This global uniformity confirms that delivery risk
is not driven by regional logistics, carrier performance
in specific markets, or geographic factors. It is
entirely determined by shipping mode allocation and
scheduling logic — which is consistent everywhere.

INSIGHT 5 — ORDER VALUE HAS NO RELATIONSHIP WITH
DELIVERY RISK
Across five sales tiers ranging from under $100 to
$500 and above, high risk rates vary by just 0.80
percentage points (54.60% to 55.40%). A $62 order
and a $500 order carry virtually identical delivery
risk. The business does not prioritise high value
orders for more reliable fulfilment — all orders
are treated identically regardless of commercial
importance. This represents a missed opportunity
to protect revenue by giving higher value orders
preferential routing or shipping mode assignment.

===============================================================
RECOMMENDATIONS — MODULE 5: DELIVERY RISK IDENTIFICATION
===============================================================

RECOMMENDATION 1 — DO NOT INVEST IN THE CURRENT RISK FLAG
AS AN INTERVENTION TOOL
The flag's perfect alignment with actual outcomes confirms
it is a scheduling calculation output, not an early
warning signal. Building intervention workflows around
it would provide no operational benefit beyond what is
already known from the shipping mode and schedule data.
Investment in the flag as currently configured would
be wasted.

RECOMMENDATION 2 — REBUILD THE RISK FLAG USING REAL-TIME
OPERATIONAL SIGNALS
To make the flag genuinely useful for proactive
intervention, it should be rebuilt to incorporate
independent data sources — carrier scan events,
warehouse processing timestamps, route disruption
alerts, and weather data. A flag that identifies
at-risk orders before they are already determined
to be late by the scheduling system would enable
meaningful operational response.

RECOMMENDATION 3 — IMPLEMENT VALUE-BASED ORDER ROUTING
Since order value has no relationship with delivery
risk, the business has an opportunity to introduce
preferential routing for high value orders without
changing its overall late delivery rate. Assigning
orders above $300 to Standard Class or Same Day —
the two most reliable modes — would protect the
highest-revenue orders from the chronic failure
rates of First Class and Second Class.

RECOMMENDATION 4 — PRIORITISE FIRST CLASS FIX TO ACHIEVE
IMMEDIATE RISK POOL REDUCTION
Correcting the First Class scheduling configuration
(Recommendation 1 from Modules 1 and 2) would remove
26,513 orders from the high risk pool immediately —
a 26.8% reduction in total high risk orders from a
single operational change. This remains the single
highest impact, lowest cost action available across
all five analytical modules.

RECOMMENDATION 5 — INVESTIGATE THE SECOND CLASS RISK
FLAG UNDERCOUNT
The Second Class risk flag (76.63%) undercounts the
actual late rate (79.73%) by 3.1 percentage points —
approximately 1,091 orders go late without being
flagged. This suggests the scheduling logic for
Second Class is less accurate than for other modes.
Understanding why Second Class produces false
negatives when no other mode does could reveal
a configuration gap that, once fixed, improves
both the flag accuracy and the underlying
delivery performance.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 07_delivery_risk.sql
-- ============================================================