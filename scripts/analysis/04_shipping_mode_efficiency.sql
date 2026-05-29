-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 04_shipping_mode_efficiency.sql
-- MODULE   : 2 — Shipping Mode Efficiency
-- PURPOSE  : Evaluate whether each shipping mode is delivering
--            on its promised timeline and identify where
--            performance gaps are costing the business
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
DataCo offers four shipping modes — Same Day, First Class,
Second Class, and Standard Class — each carrying a different
delivery promise and cost structure. There is a growing
concern that actual delivery performance does not consistently
match what was promised to customers at the time of order,
and that resource allocation across shipping modes may not
be optimised for either cost or reliability.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We're paying for premium shipping options and promising
faster delivery, but I'm not confident we're consistently
delivering on that. Are our shipping mode commitments
actually being met?"
— Director of Logistics

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Misalignment between shipping mode promises and actual
delivery performance undermines customer confidence in
DataCo's fulfilment capability. It also creates financial
inefficiency — if premium shipping modes are failing at a
higher rate than standard modes, the cost premium paid by
customers or absorbed by the business is generating no
value. With 63,030 orders across First Class and Second
Class alone, the scale of misdirected premium spend is
significant.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. What is the order volume and share of each shipping mode?
Q2. What is the average scheduled vs actual delivery time
    per shipping mode?
Q3. What is the on-time delivery rate and delivery status
    breakdown per shipping mode?
Q4. How does shipping mode performance vary across markets?
Q5. Is shipping mode performance improving or deteriorating
    year over year?

---------------------------------------------------------------
LATE DELIVERY DEFINITION
---------------------------------------------------------------
An order is classified as late when:
Days_for_shipping_real > Days_for_shipment_scheduled
Derived column Is_Late_Delivery = 1 in vw_DataCo_Cleaned
---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1: ORDER VOLUME AND SHARE BY SHIPPING MODE
-- ============================================================
-- Establish the scale of each shipping mode before evaluating
-- performance. Volume context determines the business impact
-- of each mode's failure rate.
-- ============================================================

SELECT
    Shipping_Mode,

    COUNT(*)                                AS Total_Orders,

    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)           AS Order_Share_Pct

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY Total_Orders DESC;

/*
---------------------------------------------------------------
RESULT — Q1
---------------------------------------------------------------
Shipping_Mode  | Total_Orders | Order_Share_Pct
Standard Class | 107,752      | 59.69%
Second Class   | 35,216       | 19.51%
First Class    | 27,814       | 15.41%
Same Day       | 9,737        | 5.39%
---------------------------------------------------------------
Standard Class dominates at nearly 60% of all orders.
First Class and Second Class together represent 34.92%
of all orders — over 63,000 orders riding on premium
shipping modes that the data will show are underperforming.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: SCHEDULED VS ACTUAL DELIVERY DAYS
-- ============================================================
-- Compare the delivery promise (scheduled days) against
-- actual delivery performance (real days) for each mode.
-- The gap between them is the measure of broken commitment.
-- ============================================================

SELECT
    Shipping_Mode,

    ROUND(AVG(CAST(Days_for_shipment_scheduled AS FLOAT)), 2)
                                            AS Avg_Scheduled_Days,

    ROUND(AVG(CAST(Days_for_shipping_real AS FLOAT)), 2)
                                            AS Avg_Actual_Days,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Gap_Days,

    MIN(Days_for_shipping_real)             AS Min_Actual_Days,
    MAX(Days_for_shipping_real)             AS Max_Actual_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY Avg_Scheduled_Days;

/*
---------------------------------------------------------------
RESULT — Q2
---------------------------------------------------------------
Shipping_Mode  | Scheduled | Actual | Gap  | Min | Max
Same Day       | 0 days    | 0.48   | 0.48 | 0   | 1
First Class    | 1 day     | 2.00   | 1.00 | 2   | 2
Second Class   | 2 days    | 3.99   | 1.99 | 2   | 6
Standard Class | 4 days    | 4.00   | 0.00 | 2   | 6
---------------------------------------------------------------
Key observation: First Class has a perfectly uniform actual
delivery time of exactly 2 days on every order — min and
max are both 2. The scheduled promise is 1 day. This rigid,
zero-variance gap is the signature of a scheduling
misconfiguration, not carrier inconsistency.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: DELIVERY STATUS BREAKDOWN BY SHIPPING MODE
-- ============================================================
-- Break down every delivery outcome by shipping mode to
-- understand not just late vs on-time but the full
-- distribution of outcomes including advance shipping
-- and cancellations.
-- ============================================================

SELECT
    Shipping_Mode,
    Delivery_Status,

    COUNT(*)                                AS Order_Count,

    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Shipping_Mode), 2) AS Pct_Within_Mode

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode, Delivery_Status
ORDER BY Shipping_Mode, Order_Count DESC;

/*
---------------------------------------------------------------
RESULT — Q3
---------------------------------------------------------------
Shipping_Mode  | Delivery_Status    | Orders  | Pct_Within_Mode
First Class    | Late delivery      | 26,513  | 95.32%
First Class    | Shipping canceled  | 1,301   |  4.68%
----------
Same Day       | Shipping on time   | 4,839   | 49.70%
Same Day       | Late delivery      | 4,454   | 45.74%
Same Day       | Shipping canceled  | 444     |  4.56%
----------
Second Class   | Late delivery      | 26,987  | 76.63%
Second Class   | Shipping on time   | 6,819   | 19.36%
Second Class   | Shipping canceled  | 1,410   |  4.00%
----------
Standard Class | Advance shipping   | 41,592  | 38.60%
Standard Class | Late delivery      | 41,023  | 38.07%
Standard Class | Shipping on time   | 20,538  | 19.06%
Standard Class | Shipping canceled  | 4,599   |  4.27%
---------------------------------------------------------------
Critical finding: First Class has zero on-time and zero
advance shipping records. Every non-canceled order is late.
Standard Class is the only mode generating advance shipping
at meaningful scale — 38.60% of its orders arrive early.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q4: SHIPPING MODE PERFORMANCE BY MARKET
-- ============================================================
-- Determine whether shipping mode underperformance is
-- consistent across all markets or concentrated in specific
-- geographies. Consistent failure across markets points to
-- a mode-level problem. Variable failure points to
-- market-specific logistics or carrier issues.
-- ============================================================

SELECT
    Shipping_Mode,
    Market,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Pct,

    ROUND(AVG(CAST(Delivery_Gap_Days AS FLOAT)), 2)
                                            AS Avg_Gap_Days

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode, Market
ORDER BY Shipping_Mode, Late_Pct DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Shipping_Mode  | Market       | Orders  | Late   | Late_Pct | Gap
First Class    | Africa       | 1,727   | 1,727  | 100.00%  | 1.00
First Class    | Europe       | 7,892   | 7,892  | 100.00%  | 1.00
First Class    | Pacific Asia | 6,301   | 6,301  | 100.00%  | 1.00
First Class    | USCA         | 4,008   | 4,008  | 100.00%  | 1.00
First Class    | LATAM        | 7,886   | 7,886  | 100.00%  | 1.00
----------
Same Day       | LATAM        | 2,650   | 1,354  | 51.09%   | 0.51
Same Day       | Europe       | 2,759   | 1,341  | 48.60%   | 0.49
Same Day       | Africa       | 668     | 317    | 47.46%   | 0.47
Same Day       | USCA         | 1,434   | 647    | 45.12%   | 0.45
Same Day       | Pacific Asia | 2,226   | 998    | 44.83%   | 0.45
----------
Second Class   | Pacific Asia | 8,147   | 6,552  | 80.42%   | 2.00
Second Class   | Africa       | 2,164   | 1,732  | 80.04%   | 1.98
Second Class   | Europe       | 9,861   | 7,887  | 79.98%   | 2.00
Second Class   | USCA         | 5,105   | 4,061  | 79.55%   | 1.98
Second Class   | LATAM        | 9,939   | 7,846  | 78.94%   | 1.98
----------
Standard Class | Africa       | 7,055   | 2,822  | 40.00%   | 0.02
Standard Class | Europe       | 29,740  | 11,869 | 39.91%   | -0.01
Standard Class | Pacific Asia | 24,586  | 9,798  | 39.85%   | 0.00
Standard Class | LATAM        | 31,119  | 12,334 | 39.63%   | -0.01
Standard Class | USCA         | 15,252  | 6,028  | 39.52%   | 0.00
---------------------------------------------------------------
First Class fails at exactly 100% in every single market
with an identical 1-day gap — no market variation whatsoever.
Standard Class average gap is effectively 0 across all
markets, confirming it as the only mode meeting its promise
globally. Second Class is consistently around 80% late
across all markets regardless of geography.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — Q5: YEAR-OVER-YEAR PERFORMANCE BY SHIPPING MODE
-- ============================================================
-- Track whether each shipping mode is improving, worsening,
-- or staying flat over the 2015–2018 period. Flat or
-- worsening trends confirm structural rather than
-- situational problems.
-- ============================================================

SELECT
    Shipping_Mode,
    YEAR(order_date_DateOrders)             AS Order_Year,

    COUNT(*)                                AS Total_Orders,

    SUM(Is_Late_Delivery)                   AS Late_Orders,

    ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
        AS FLOAT) / COUNT(*), 2)            AS Late_Pct

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode, YEAR(order_date_DateOrders)
ORDER BY Shipping_Mode, Order_Year;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Shipping_Mode  | Year | Orders | Late   | Late_Pct
First Class    | 2015 | 9,673  | 9,673  | 100.00%
First Class    | 2016 | 9,792  | 9,792  | 100.00%
First Class    | 2017 | 8,021  | 8,021  | 100.00%
First Class    | 2018 | 328    | 328    | 100.00%
----------
Same Day       | 2015 | 3,315  | 1,542  | 46.52%
Same Day       | 2016 | 3,407  | 1,513  | 44.41%
Same Day       | 2017 | 2,895  | 1,548  | 53.47%
Same Day       | 2018 | 120    | 54     | 45.00%
----------
Second Class   | 2015 | 12,241 | 9,812  | 80.16%
Second Class   | 2016 | 12,174 | 9,697  | 79.65%
Second Class   | 2017 | 10,356 | 8,209  | 79.27%
Second Class   | 2018 | 445    | 360    | 80.90%
----------
Standard Class | 2015 | 37,421 | 14,850 | 39.68%
Standard Class | 2016 | 37,177 | 14,839 | 39.91%
Standard Class | 2017 | 31,924 | 12,658 | 39.65%
Standard Class | 2018 | 1,230  | 504    | 40.98%
---------------------------------------------------------------
No shipping mode shows meaningful improvement across four
years. First Class is 100% every year. Second Class holds
between 79.27%–80.90%. Standard Class holds between
39.65%–40.98%. Same Day shows the only fluctuation —
a spike to 53.47% in 2017 — but no sustained improvement.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — EXTENDED ANALYSIS: DELIVERY PROMISE SCORECARD
-- ============================================================
-- Summarise each shipping mode against its core promise:
-- is it delivering what it advertised? This is the
-- executive-level view for leadership decision-making.
-- ============================================================

SELECT
    Shipping_Mode,

    COUNT(*)                                AS Total_Orders,

    -- Promise: scheduled days
    ROUND(AVG(CAST(Days_for_shipment_scheduled AS FLOAT)), 2)
                                            AS Promised_Days,

    -- Reality: actual days
    ROUND(AVG(CAST(Days_for_shipping_real AS FLOAT)), 2)
                                            AS Actual_Days,

    -- On-time rate (Is_Late_Delivery = 0)
    ROUND(CAST(100.0 * SUM(CASE WHEN Is_Late_Delivery = 0
        THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*), 2)
                                            AS OnTime_Pct,

    -- Early delivery rate (Delivery_Status = Advance shipping)
    ROUND(CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Advance shipping'
        THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*), 2)
                                            AS Early_Delivery_Pct,

    -- Cancellation rate
    ROUND(CAST(100.0 * SUM(CASE WHEN Delivery_Status = 'Shipping canceled'
        THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*), 2)
                                            AS Cancellation_Pct,

    -- Promise met: Yes/No verdict
    CASE
        WHEN ROUND(CAST(100.0 * SUM(Is_Late_Delivery)
            AS FLOAT) / COUNT(*), 2) > 50.0
        THEN 'NO — Majority late'
        ELSE 'YES — Majority on time'
    END                                     AS Promise_Met

FROM dbo.vw_DataCo_Cleaned
GROUP BY Shipping_Mode
ORDER BY OnTime_Pct DESC;
GO


-- ============================================================
-- SECTION 9 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 2: SHIPPING MODE EFFICIENCY
===============================================================

INSIGHT 1 — FIRST CLASS HAS NEVER DELIVERED A SINGLE ORDER
ON TIME IN FOUR YEARS
Across 27,814 orders, 5 markets, and 4 years (2015–2018),
First Class recorded a 100% late delivery rate with zero
exceptions. Every order arrived exactly 1 day late — no
more, no less. The scheduled promise is 1 day; the actual
delivery is always 2 days. This rigid, zero-variance pattern
across all geographies and all years is the unmistakable
signature of a system configuration error. The scheduled
delivery window for First Class appears to have been set
1 day shorter than what is operationally achievable.
This is not a carrier performance issue — it is a
configuration issue that can be fixed without changing
any physical logistics.

INSIGHT 2 — CUSTOMERS PAYING FOR FASTER SHIPPING ARE
RECEIVING WORSE SERVICE
The relationship between price tier and reliability is
inverted. Standard Class — the slowest option — is the
most reliable mode at 39.77% late. Same Day is next at
47.83% late. Second Class follows at 79.73% late. First
Class is last at 100% late. A customer who selects the
premium First Class option receives a worse delivery
experience — guaranteed — than one who selects the
cheapest standard option. This is a direct breach of
the value proposition DataCo offers to its customers.

INSIGHT 3 — STANDARD CLASS IS THE ONLY MODE THAT EXCEEDS
ITS OWN PROMISE
38.60% of Standard Class orders (41,592 of 107,752) arrive
ahead of schedule — classified as Advance shipping. Standard
Class is the only mode generating early deliveries at
meaningful scale. Its average delivery gap across all
markets is effectively zero, and in Europe and LATAM it
is slightly negative — meaning it runs marginally early
on average. Standard Class does not just meet its promise;
it routinely beats it.

INSIGHT 4 — SECOND CLASS FAILURE IS STRUCTURAL AND GLOBAL
Second Class late delivery rates range from 78.94% to
80.42% across all five markets — a spread of less than
2 percentage points globally. Year over year, rates hold
between 79.27% and 80.90% with no improvement trajectory.
This level of consistency across geographies and time
eliminates operational or regional explanations. Second
Class has a structural performance problem that is
embedded in how the mode is configured or contracted,
not in how it is executed in any specific market.

INSIGHT 5 — SAME DAY IS THE MOST VOLATILE SHIPPING MODE
Same Day is the only mode showing meaningful year-over-year
fluctuation — late rates moved from 46.52% in 2015 to
44.41% in 2016, then spiked to 53.47% in 2017 before
recovering to 45.00% in 2018. This volatility, combined
with market-level variation (44.83% in Pacific Asia vs
51.09% in LATAM), suggests Same Day performance is
sensitive to operational conditions in ways the other
modes are not. It is the only mode where targeted
improvement efforts are likely to produce measurable
results in the short term.

INSIGHT 6 — CANCELLATIONS ARE CONSISTENT ACROSS ALL MODES
All four shipping modes show a cancellation rate between
4.00% and 4.68% — remarkably consistent regardless of
mode. This suggests cancellations are driven by customer
or order-level factors rather than shipping mode selection,
and are unlikely to be reduced through logistics
improvements alone.

===============================================================
RECOMMENDATIONS — MODULE 2: SHIPPING MODE EFFICIENCY
===============================================================

RECOMMENDATION 1 — FIX THE FIRST CLASS SCHEDULING
CONFIGURATION BEFORE ANY OTHER ACTION
The 100% late delivery rate on First Class is almost
certainly caused by a scheduled delivery window set 1 day
shorter than operationally achievable. This should be
investigated and corrected in the order management system
immediately. The fix costs nothing operationally and
would reclassify all 27,814 First Class orders from late
to on time — reducing the company's overall late delivery
rate from 57.28% to approximately 42% overnight. No
carrier negotiation, no logistics investment, and no
process change is required. This is the highest-impact,
lowest-cost action available to the business.

RECOMMENDATION 2 — CONDUCT A FORMAL SECOND CLASS CARRIER
PERFORMANCE REVIEW
Second Class failure at 79.73% globally and consistently
across all markets and years cannot be resolved by a
scheduling fix alone. The delivery gap ranges from 0 to
4 days, indicating genuine operational variance. A formal
review of Second Class carrier contracts, SLA terms, and
routing configurations is required. If the carrier cannot
demonstrate a credible improvement plan, alternative
carriers or route restructuring should be evaluated.

RECOMMENDATION 3 — REVISE CUSTOMER-FACING DELIVERY PROMISES
FOR FIRST CLASS AND SECOND CLASS IMMEDIATELY
Until fixes are implemented, the delivery promises shown
to customers at checkout for First Class (1 day) and
Second Class (2 days) should be revised to reflect actual
performance. Showing a 1-day promise that fails 100% of
the time actively damages customer trust on every order.
A conservative promise that is consistently met will
generate more customer satisfaction than an ambitious
promise that is never kept.

RECOMMENDATION 4 — INVESTIGATE THE SAME DAY 2017 SPIKE
Same Day late delivery spiked from 44.41% in 2016 to
53.47% in 2017 — a 9-percentage-point deterioration —
before recovering in 2018. Understanding what caused
this spike (carrier change, volume surge, routing issue)
would provide operational intelligence that could be
applied proactively to prevent recurrence and further
improve Same Day reliability below its current 47.83%
baseline.

RECOMMENDATION 5 — LEVERAGE STANDARD CLASS AS THE
OPERATIONAL BENCHMARK
Standard Class consistently meets its delivery promise
across all markets and all years with near-zero average
gap. The operational practices, carrier relationships,
and routing configurations behind Standard Class should
be documented and used as the internal benchmark when
diagnosing and improving the other three modes.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 04_shipping_mode_efficiency.sql
-- ============================================================