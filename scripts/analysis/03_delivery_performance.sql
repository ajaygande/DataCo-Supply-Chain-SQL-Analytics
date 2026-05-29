-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 03_delivery_performance.sql
-- MODULE   : 1 — Delivery Performance & Shipping Delays
-- PURPOSE  : Investigate the scale, distribution, and patterns
--            of late deliveries across the DataCo dataset
-- DATABASE : DataCo
-- VIEW     : dbo.vw_DataCo_Cleaned
-- DIALECT  : SQL Server (T-SQL)
-- ROWS     : 180,519
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
A significant portion of customer orders are arriving later
than the scheduled delivery date. Customer service teams are
reporting increased complaint volumes and repeat order rates
in certain regions have begun to decline. Operations management
suspects the problem is systemic but lacks the data visibility
to confirm where the breakdowns are occurring.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We know deliveries are running late, but we don't know how
widespread the problem is, which regions are worst affected,
or whether certain shipping modes are more reliable than
others. We need a clear picture before we can act."
— Head of Supply Chain Operations

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Late deliveries damage customer satisfaction and retention.
At scale, chronic delays translate into lost lifetime customer
value, increased customer service costs, and reputational
risk. With 180,519 orders in the dataset, even a 10% late
delivery rate represents thousands of affected customers.
At 57.28%, the business is failing the majority of its
customers on every order.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. What percentage of all orders are delivered late?
Q2. How does the late delivery rate vary by shipping mode?
Q3. Which markets and regions have the highest concentration
    of late deliveries?
Q4. What is the average delivery gap across shipping modes?
Q5. Are late deliveries concentrated in specific order
    statuses?

---------------------------------------------------------------
LATE DELIVERY DEFINITION
---------------------------------------------------------------
An order is classified as late when:
Days_for_shipping_real > Days_for_shipment_scheduled
Derived column Is_Late_Delivery = 1 in vw_DataCo_Cleaned
---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1: OVERALL LATE DELIVERY RATE
-- ============================================================
-- Establish the headline figure — what proportion of all
-- 180,519 orders failed to arrive on or before the
-- scheduled delivery date.
-- ============================================================

SELECT
    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    COUNT(*) - SUM(Is_Late_Delivery)        AS OnTime_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(CAST(100.0 * (COUNT(*) - SUM(Is_Late_Delivery))
        AS FLOAT) / COUNT(*), 2)            AS OnTime_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days

FROM dbo.vw_DataCo_Cleaned;

/*
---------------------------------------------------------------
RESULT — Q1
---------------------------------------------------------------
Total_Orders | Late_Orders | OnTime_Orders | Late_Pct | OnTime_Pct | Avg_Gap
180,519      | 103,400     | 77,119        | 57.28%   | 42.72%     | 0.57 days
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: LATE DELIVERY RATE BY SHIPPING MODE
-- ============================================================
-- Determine whether late delivery is distributed evenly
-- across shipping modes or concentrated in specific ones.
-- This identifies whether the problem is carrier-specific
-- or operational across all fulfilment channels.
-- ============================================================

SELECT
    Shipping_Mode,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    COUNT(*) - SUM(Is_Late_Delivery)        AS OnTime_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days,

    MIN(Delivery_Gap_Days)                  AS Min_Gap_Days,
    MAX(Delivery_Gap_Days)                  AS Max_Gap_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY Late_Delivery_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q2
---------------------------------------------------------------
Shipping_Mode   | Total   | Late   | OnTime | Late_Pct | Avg_Gap | Min | Max
First Class     | 27,814  | 27,814 | 0      | 100.00%  | 1.00    | 1   | 1
Second Class    | 35,216  | 28,078 | 7,138  | 79.73%   | 1.99    | 0   | 4
Same Day        | 9,737   | 4,657  | 5,080  | 47.83%   | 0.48    | 0   | 1
Standard Class  | 107,752 | 42,851 | 64,901 | 39.77%   | 0.00    | -2  | 2
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: LATE DELIVERY RATE BY MARKET
-- ============================================================
-- Identify which international markets carry the highest
-- concentration of late deliveries. Market-level visibility
-- allows operations leadership to prioritise intervention
-- geographically rather than treating the problem globally.
-- ============================================================

SELECT
    Market,
    Order_Region,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days,

    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)           AS Market_Order_Share_Pct

FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
ORDER BY Late_Delivery_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q3
---------------------------------------------------------------
Market        | Region           | Orders  | Late   | Late_Pct | Avg_Gap | Share
Africa        | Central Africa   | 1,677   | 1,018  | 60.70%   | 0.64    | 0.93%
Europe        | Western Europe   | 27,109  | 15,863 | 58.52%   | 0.60    | 15.02%
Pacific Asia  | South Asia       | 7,731   | 4,523  | 58.50%   | 0.60    | 4.28%
USCA          | South of USA     | 4,045   | 2,350  | 58.10%   | 0.58    | 2.24%
USCA          | East of USA      | 6,915   | 4,009  | 57.98%   | 0.58    | 3.83%
Pacific Asia  | Southeast Asia   | 9,539   | 5,531  | 57.98%   | 0.56    | 5.29%
Pacific Asia  | West Asia        | 6,009   | 3,455  | 57.50%   | 0.57    | 3.33%
Europe        | Eastern Europe   | 3,920   | 2,252  | 57.45%   | 0.58    | 2.17%
Africa        | East Africa      | 1,852   | 1,064  | 57.45%   | 0.57    | 1.03%
LATAM         | Central America  | 28,341  | 16,224 | 57.25%   | 0.56    | 15.70%
LATAM         | South America    | 14,935  | 8,548  | 57.23%   | 0.56    | 8.27%
Pacific Asia  | Central Asia     | 553     | 316    | 57.14%   | 0.65    | 0.31%
USCA          | US Center        | 5,887   | 3,363  | 57.13%   | 0.59    | 3.26%
Europe        | Southern Europe  | 9,431   | 5,350  | 56.73%   | 0.52    | 5.22%
Pacific Asia  | Eastern Asia     | 7,280   | 4,130  | 56.73%   | 0.57    | 4.03%
Africa        | North Africa     | 3,232   | 1,832  | 56.68%   | 0.55    | 1.79%
USCA          | West of USA      | 7,993   | 4,524  | 56.60%   | 0.56    | 4.43%
Europe        | Northern Europe  | 9,792   | 5,524  | 56.41%   | 0.55    | 5.42%
Africa        | Southern Africa  | 1,157   | 651    | 56.27%   | 0.48    | 0.64%
Pacific Asia  | Oceania          | 10,148  | 5,694  | 56.11%   | 0.56    | 5.62%
LATAM         | Caribbean        | 8,318   | 4,648  | 55.88%   | 0.55    | 4.61%
Africa        | West Africa      | 3,696   | 2,033  | 55.01%   | 0.55    | 2.05%
USCA          | Canada           | 959     | 498    | 51.93%   | 0.39    | 0.53%
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q3 EXTENDED: TOP 10 WORST PERFORMING CITIES
-- ============================================================
-- City-level granularity for operations teams who need
-- precise geographic targeting for logistics improvements.
-- Filtered to cities with at least 100 orders to avoid
-- small-sample distortion.
-- ============================================================

SELECT TOP 10
    Order_Country,
    Order_Region,
    Order_City,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Order_Country, Order_Region, Order_City
HAVING COUNT(*) >= 100
ORDER BY Late_Delivery_Pct DESC;
GO


-- ============================================================
-- SECTION 7 — Q4: AVERAGE DELIVERY GAP BY SHIPPING MODE
-- ============================================================
-- Quantify how many days late each shipping mode runs on
-- average. This moves the analysis from binary (late/on time)
-- to magnitude — understanding not just that deliveries are
-- late but by how much.
-- ============================================================

SELECT
    Shipping_Mode,

    COUNT(*)                                AS Total_Orders,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Gap_All_Orders,

    ROUND(AVG(CAST(
        CASE WHEN Is_Late_Delivery = 1
             THEN Delivery_Gap_Days END
        AS FLOAT)), 2)                      AS Avg_Gap_Late_Orders_Only,

    ROUND(AVG(CAST(Days_for_shipment_scheduled AS FLOAT)), 2)
                                            AS Avg_Scheduled_Days,

    ROUND(AVG(CAST(Days_for_shipping_real AS FLOAT)), 2)
                                            AS Avg_Actual_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY Avg_Gap_All_Orders DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Shipping_Mode  | Orders  | Avg_Gap | Late_Gap | Scheduled | Actual
Second Class   | 35,216  | 1.99    | 2.50     | 2.00      | 3.99
First Class    | 27,814  | 1.00    | 1.00     | 1.00      | 2.00
Same Day       | 9,737   | 0.48    | 1.00     | 0.00      | 0.48
Standard Class | 107,752 | 0.00    | 1.51     | 4.00      | 4.00
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — Q5: LATE DELIVERIES BY ORDER STATUS
-- ============================================================
-- Determine whether late deliveries are concentrated in
-- specific order statuses. This reveals whether the problem
-- is at the fulfilment stage, the shipping stage, or both.
-- ============================================================

SELECT
    Order_Status,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)           AS Status_Share_Pct

FROM dbo.vw_DataCo_Cleaned
GROUP BY Order_Status
ORDER BY Late_Orders DESC;
GO


-- ============================================================
-- SECTION 9 — EXTENDED: SHIPPING MODE × MARKET
-- ============================================================
-- Cross-tabulate shipping mode performance against market
-- to identify whether certain mode/market combinations are
-- systematically underperforming. Supports targeted carrier
-- renegotiation at the market level.
-- ============================================================

SELECT
    Market,
    Shipping_Mode,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Shipping_Mode
ORDER BY Market, Late_Delivery_Pct DESC;
GO


-- ============================================================
-- SECTION 10 — EXTENDED: YEAR-OVER-YEAR TREND (2015–2018)
-- ============================================================
-- Track whether late delivery rates are improving, worsening,
-- or staying flat over the analysis period.
-- ============================================================

SELECT
    YEAR(order_date_DateOrders)             AS Order_Year,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Delivery_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Delivery_Gap_Days

FROM dbo.vw_DataCo_Cleaned
WHERE order_date_DateOrders IS NOT NULL
GROUP BY YEAR(order_date_DateOrders)
ORDER BY Order_Year;

/*
---------------------------------------------------------------
RESULT — YEAR-OVER-YEAR TREND
---------------------------------------------------------------
Year | Total_Orders | Late_Orders | Late_Pct | Avg_Gap
2015 | 62,650       | 35,877      | 57.27%   | 0.56
2016 | 62,550       | 35,841      | 57.30%   | 0.57
2017 | 53,196       | 30,436      | 57.21%   | 0.56
2018 | 2,123        | 1,246       | 58.69%   | 0.61
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 11 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 1: DELIVERY PERFORMANCE
===============================================================

INSIGHT 1 — THE MAJORITY OF CUSTOMERS RECEIVE LATE DELIVERIES
57.28% of all orders (103,400 of 180,519) were delivered
after the scheduled date. This is not an edge case or a
seasonal spike — more than half of every order placed with
DataCo fails to arrive on time. The average customer
experience is a late delivery.

INSIGHT 2 — FIRST CLASS SHIPPING HAS A 100% FAILURE RATE
Every single First Class order (27,814 of 27,814) was
delivered late with a perfectly consistent gap of exactly
1 day. The uniformity of this failure — identical gap across
all orders, zero exceptions — points to a scheduling
misconfiguration rather than an operational breakdown.
First Class is not underperforming; it appears to have been
set up with an impossible delivery promise from the start.

INSIGHT 3 — SECOND CLASS IS THE SECOND WORST PERFORMER
79.73% of Second Class orders (28,078 of 35,216) were late,
averaging a 2-day gap on failed deliveries. Combined, First
Class and Second Class account for 63,030 orders (34.9% of
all orders) and are responsible for a disproportionate share
of the late delivery problem.

INSIGHT 4 — STANDARD CLASS IS THE MOST RELIABLE SHIPPING MODE
Standard Class — the slowest and typically cheapest option —
has the lowest late delivery rate at 39.77%. It also carries
the highest order volume (107,752 orders, 59.7% of all
orders). Customers who select the slowest shipping mode are
more likely to receive their orders on time than those who
pay for faster options. This is a fundamental inversion of
the value proposition DataCo offers.

INSIGHT 5 — LATE DELIVERY IS A GLOBAL PROBLEM WITH NO SAFE REGION
All 23 regions across 5 markets show late delivery rates
between 51.93% and 60.70%. The best performing region
(Canada, 51.93%) still fails more than half its orders.
The worst (Central Africa, 60.70%) fails nearly two-thirds.
No market or region is performing acceptably. This confirms
the problem is structural and systemic — not geographic.

INSIGHT 6 — THE PROBLEM HAS NOT IMPROVED IN FOUR YEARS
Late delivery rates held flat at 57.21%–57.30% from 2015
through 2017. The marginal rise to 58.69% in 2018 (though
based on a partial year sample of 2,123 orders) suggests
no improvement trajectory. Four years of consistent failure
at this scale indicates an operational ceiling that the
business has not been able to break through.

===============================================================
RECOMMENDATIONS — MODULE 1: DELIVERY PERFORMANCE
===============================================================

RECOMMENDATION 1 — AUDIT FIRST CLASS SCHEDULING IMMEDIATELY
The 100% late delivery rate with a perfectly consistent 1-day
gap on all 27,814 First Class orders is not a carrier
performance issue — it is almost certainly a system
configuration error where scheduled delivery days are set
one day shorter than operationally achievable. This should
be the first investigation: review the scheduled delivery
day setting for First Class and correct it. This single fix
could reclassify up to 27,814 orders from late to on time,
reducing the overall late delivery rate from 57.28% to
approximately 42%.

RECOMMENDATION 2 — REVIEW SECOND CLASS CARRIER CONTRACTS
Second Class has a genuine operational failure rate of
79.73% that cannot be explained by scheduling misconfiguration
alone (gaps range from 0 to 4 days). This warrants a formal
carrier performance review, SLA renegotiation, and
consideration of alternative carriers for this shipping tier.

RECOMMENDATION 3 — REALIGN CUSTOMER EXPECTATIONS FOR FAST SHIPPING
Until First Class and Second Class performance is corrected,
customer-facing delivery promises for these modes should be
revised. Showing customers a 1-day delivery promise that
fails 100% of the time actively damages trust. A more
conservative promise that is consistently met will improve
satisfaction more than an ambitious promise that is never
kept.

RECOMMENDATION 4 — INVESTIGATE REGIONAL CONCENTRATION WITHIN
HIGH-VOLUME LATE MARKETS
Western Europe (27,109 orders, 58.52% late) and Central
America (28,341 orders, 57.25% late) together represent
30.72% of all orders. Their late delivery rates are above
the global average despite their high volumes. A targeted
operational review of last-mile logistics in these two
regions offers the highest volume impact for improvement.

RECOMMENDATION 5 — SET A DELIVERY PERFORMANCE KPI AND TRACK IT
The year-over-year data shows no improvement over four years
without a defined performance target. The business should
establish a formal on-time delivery KPI (suggested target:
80% on-time within 12 months) and assign ownership to
operations leadership. Without a tracked target, the current
57.28% rate will persist indefinitely.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 03_delivery_performance.sql
-- ============================================================
