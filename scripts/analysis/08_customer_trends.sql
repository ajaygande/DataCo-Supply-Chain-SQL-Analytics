-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 08_customer_trends.sql
-- MODULE   : 6 — Customer Order Trends
-- PURPOSE  : Analyse order behaviour, segment performance,
--            category preferences, and customer value
--            distribution across the DataCo customer base
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
Customer behaviour data is embedded within the order dataset
but has never been systematically analysed. The business
does not have a clear picture of how order frequency, sales
value, and product preferences differ across customer
segments. Without this visibility, marketing and commercial
decisions are made on intuition rather than evidence.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We talk about our customer segments a lot, but I'm not
sure we actually know how they behave differently. Who are
our most valuable customers? What do they buy? How often
do they order? That's the information I want."
— Head of Customer Strategy

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Without customer-level behavioural insight, the business
cannot personalise its commercial approach, prioritise
retention investment, or design segment-specific promotions.
High-value customers may be receiving the same experience
as low-value customers, and churn signals may go undetected.
The data reveals that all three segments — Consumer,
Corporate, and Home Office — are behaving identically
across every measurable dimension, suggesting the business
has no effective segmentation strategy in place.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. How does order frequency and value differ across
    customer segments?
Q2. Which customer segment generates the highest total
    revenue and profit?
Q3. What are the most frequently ordered product categories
    by customer segment?
Q4. Which markets have the highest concentration of
    orders by segment?
Q5. Are there customers with unusually high order volumes
    or sales values that warrant individual attention?

---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1 & Q2: ORDER FREQUENCY AND VALUE BY SEGMENT
-- ============================================================
-- Establish whether segments differ meaningfully in how
-- often they order, how much they spend, and how much
-- profit they generate per order.
-- ============================================================

SELECT
    Customer_Segment,
    COUNT(*)                                        AS Total_Orders,
    COUNT(DISTINCT Customer_Id)                     AS Unique_Customers,
    ROUND(CAST(COUNT(*) AS FLOAT) /
        COUNT(DISTINCT Customer_Id), 2)             AS Avg_Orders_Per_Customer,
    ROUND(AVG(Sales), 2)                            AS Avg_Order_Value,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Order_Profit_Per_Order), 2)           AS Avg_Profit_Per_Order,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Segment
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q1 & Q2
---------------------------------------------------------------
Segment     | Orders  | Customers | Avg_Orders | Avg_Value | Total_Sales     | Avg_Profit | Total_Profit
Consumer    | 93,504  | 10,695    | 8.74       | $204.22   | $19,095,790.16  | $22.18     | $2,073,487.67
Corporate   | 54,789  | 6,239     | 8.78       | $203.84   | $11,168,406.84  | $21.95     | $1,202,574.96
Home Office | 32,226  | 3,718     | 8.67       | $202.34   | $6,520,538.02   | $21.44     | $690,840.34
---------------------------------------------------------------
All three segments are commercially indistinguishable.
Orders per customer (8.67–8.78), average order value
($202.34–$204.22), and average profit per order
($21.44–$22.18) are virtually identical across all three.
Consumer leads total sales and profit purely because it
has the most customers — not because it is more valuable
per customer or per order.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q3: TOP PRODUCT CATEGORIES BY SEGMENT
-- ============================================================
-- Identify whether segments have meaningfully different
-- product preferences — which would indicate genuine
-- segment differentiation — or whether all segments
-- buy the same products in the same proportions.
-- ============================================================

SELECT
    Customer_Segment,
    Category_Name,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Customer_Segment), 2)     AS Pct_Within_Segment
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Segment, Category_Name
ORDER BY Customer_Segment, Total_Orders DESC;

/*
---------------------------------------------------------------
RESULT — Q3 (Top 9 categories per segment)
---------------------------------------------------------------
CONSUMER segment top categories:
Category              | Orders | Pct_Within
Cleats                | 12,700 | 13.58%
Men's Footwear        | 11,472 | 12.27%
Women's Apparel       | 10,864 | 11.62%
Indoor/Outdoor Games  | 9,959  | 10.65%
Fishing               | 9,023  | 9.65%
Water Sports          | 8,111  | 8.67%
Camping & Hiking      | 7,043  | 7.53%
Cardio Equipment      | 6,513  | 6.97%
Shop By Sport         | 5,766  | 6.17%

CORPORATE segment top categories:
Category              | Orders | Pct_Within
Cleats                | 7,347  | 13.41%
Men's Footwear        | 6,817  | 12.44%
Women's Apparel       | 6,418  | 11.71%
Indoor/Outdoor Games  | 5,974  | 10.90%
Fishing               | 5,237  | 9.56%
Water Sports          | 4,677  | 8.54%
Camping & Hiking      | 4,213  | 7.69%
Cardio Equipment      | 3,786  | 6.91%
Shop By Sport         | 3,267  | 5.96%

HOME OFFICE segment top categories:
Category              | Orders | Pct_Within
Cleats                | 4,504  | 13.98%
Men's Footwear        | 3,957  | 12.28%
Women's Apparel       | 3,753  | 11.65%
Indoor/Outdoor Games  | 3,365  | 10.44%
Fishing               | 3,065  | 9.51%
Water Sports          | 2,752  | 8.54%
Camping & Hiking      | 2,473  | 7.67%
Cardio Equipment      | 2,188  | 6.79%
Shop By Sport         | 1,951  | 6.05%
---------------------------------------------------------------
The top 9 categories are identical across all three
segments in the same rank order with near-identical
percentage shares. There is no measurable difference
in product preference between Consumer, Corporate,
and Home Office customers. All three segments buy
the same products at the same rates.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q4: MARKET CONCENTRATION BY SEGMENT
-- ============================================================
-- Determine whether customer segments are geographically
-- concentrated in specific markets or distributed evenly.
-- Geographic concentration by segment would indicate
-- different regional demand profiles per segment.
-- ============================================================

SELECT
    Customer_Segment,
    Market,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Customer_Segment), 2)     AS Order_Share_In_Segment
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Segment, Market
ORDER BY Customer_Segment, Total_Orders DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Segment     | Market       | Orders  | Sales           | Profit        | Share
Consumer    | LATAM        | 26,598  | $5,289,638.78   | $568,246.21   | 28.45%
Consumer    | Europe       | 26,108  | $5,671,565.35   | $627,099.00   | 27.92%
Consumer    | Pacific Asia | 21,284  | $4,286,860.71   | $445,629.43   | 22.76%
Consumer    | USCA         | 13,507  | $2,660,291.21   | $302,912.14   | 14.45%
Consumer    | Africa       | 6,007   | $1,187,434.09   | $129,600.89   |  6.42%
Corporate   | LATAM        | 15,699  | $3,139,114.84   | $350,573.82   | 28.65%
Corporate   | Europe       | 15,313  | $3,303,070.67   | $355,412.12   | 27.95%
Corporate   | Pacific Asia | 12,508  | $2,515,592.59   | $258,109.51   | 22.83%
Corporate   | USCA         | 7,741   | $1,510,871.23   | $162,718.14   | 14.13%
Corporate   | Africa       | 3,528   | $699,757.51     | $75,761.37    |  6.44%
Home Office | LATAM        | 9,297   | $1,848,859.22   | $204,501.58   | 28.85%
Home Office | Europe       | 8,831   | $1,897,760.77   | $186,931.84   | 27.40%
Home Office | Pacific Asia | 7,468   | $1,471,290.44   | $154,014.50   | 23.17%
Home Office | USCA         | 4,551   | $895,366.27     | $98,683.50    | 14.12%
Home Office | Africa       | 2,079   | $407,261.32     | $46,708.92    |  6.45%
---------------------------------------------------------------
Market distribution is virtually identical across all three
segments. LATAM leads at ~28.5%, Europe at ~27.9%,
Pacific Asia at ~22.8%, USCA at ~14.1%, Africa at ~6.4%
for every segment. No segment has a geographic skew.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q5: TOP 10 HIGHEST VALUE CUSTOMERS
-- ============================================================
-- Identify individual customers generating the highest
-- total sales. High value customers warrant priority
-- retention investment and personalised engagement.
-- ============================================================

SELECT TOP 10
    Customer_Id,
    Customer_Segment,
    Customer_City,
    Customer_Country,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Sales), 2)                            AS Avg_Order_Value,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Id, Customer_Segment,
         Customer_City, Customer_Country
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Cust_Id | Segment    | City       | Country     | Orders | Sales      | Profit     | Ratio
791     | Corporate  | Canton     | EE. UU.     | 43     | $10,524.17 | -$866.38   | -0.0381
9371    | Consumer   | Meridian   | EE. UU.     | 44     | $9,299.03  | $1,346.58  | 0.1441
8766    | Corporate  | Caguas     | Puerto Rico | 38     | $9,296.14  | $1,495.16  | 0.1850
1657    | Consumer   | Caguas     | Puerto Rico | 42     | $9,223.71  | $2,196.92  | 0.2712
2641    | Consumer   | Carrollton | EE. UU.     | 43     | $9,130.92  | $2,441.97  | 0.2523
1288    | Home Office| Caguas     | Puerto Rico | 42     | $9,019.11  | $403.11    | 0.0510
3710    | Consumer   | Springfield| EE. UU.     | 42     | $9,019.10  | $1,055.13  | 0.1519
4249    | Consumer   | Caguas     | Puerto Rico | 39     | $8,918.85  | $439.71    | 0.0331
5654    | Home Office| Caguas     | Puerto Rico | 47     | $8,904.95  | $1,045.36  | 0.1283
5624    | Consumer   | Caguas     | Puerto Rico | 38     | $8,761.98  | $1,178.15  | 0.1603
---------------------------------------------------------------
6 of the top 10 customers are from Caguas, Puerto Rico —
consistent with the data concentration anomaly flagged in
Module 4. Customer 791 (Canton) is generating negative
total profit (-$866.38) across 43 orders despite being
the highest sales value customer — the business is losing
money on its top customer. Profit ratios vary widely
(−0.0381 to 0.2712) among top customers, suggesting
no consistent value-based account management.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — ORDER TREND BY SEGMENT AND YEAR
-- ============================================================
-- Track whether segment order volumes and values are
-- growing, declining, or shifting year over year.
-- ============================================================

SELECT
    Customer_Segment,
    YEAR(order_date_DateOrders)                     AS Order_Year,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Sales), 2)                            AS Avg_Order_Value,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Segment, YEAR(order_date_DateOrders)
ORDER BY Customer_Segment, Order_Year;

/*
---------------------------------------------------------------
RESULT — YEAR OVER YEAR TREND
---------------------------------------------------------------
Segment     | Year | Orders | Sales          | Avg_Value | Profit
Consumer    | 2015 | 32,278 | $6,374,924.37  | $197.50   | $691,205.28
Consumer    | 2016 | 32,712 | $6,453,409.22  | $197.28   | $692,275.42
Consumer    | 2017 | 27,445 | $6,104,626.32  | $222.43   | $678,045.72
Consumer    | 2018 | 1,069  | $162,830.24    | $152.32   | $11,961.25
Corporate   | 2015 | 19,165 | $3,778,905.37  | $197.18   | $397,465.92
Corporate   | 2016 | 18,754 | $3,671,523.60  | $195.77   | $394,545.34
Corporate   | 2017 | 16,251 | $3,613,247.68  | $222.34   | $398,666.30
Corporate   | 2018 | 619    | $104,730.19    | $169.19   | $11,897.40
Home Office | 2015 | 11,207 | $2,187,001.68  | $195.15   | $230,185.70
Home Office | 2016 | 11,084 | $2,178,884.50  | $196.58   | $223,298.31
Home Office | 2017 | 9,500  | $2,090,562.15  | $220.06   | $227,373.09
Home Office | 2018 | 435    | $64,089.68     | $147.33   | $9,983.24
---------------------------------------------------------------
All three segments show an identical average order value
spike in 2017 — Consumer +$25.15, Corporate +$26.57,
Home Office +$23.48 — each increasing by approximately
$25 in the same year. This simultaneous uniform increase
across all segments strongly indicates a company-wide
pricing change or product mix shift in 2017 rather than
any segment-specific behaviour change.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — EXTENDED: CUSTOMER VALUE DISTRIBUTION
-- ============================================================
-- Segment customers by total lifetime sales value to
-- identify the concentration of revenue among high,
-- medium, and low value customers.
-- ============================================================

WITH Customer_Totals AS (
    SELECT
        Customer_Id,
        Customer_Segment,
        COUNT(*)                                    AS Total_Orders,
        ROUND(SUM(Sales), 2)                        AS Lifetime_Sales,
        ROUND(SUM(Order_Profit_Per_Order), 2)       AS Lifetime_Profit
    FROM dbo.vw_DataCo_Cleaned
    GROUP BY Customer_Id, Customer_Segment
)
SELECT
    Customer_Segment,
    CASE
        WHEN Lifetime_Sales >= 5000  THEN 'High Value — $5,000+'
        WHEN Lifetime_Sales >= 2000  THEN 'Mid Value — $2,000–$4,999'
        WHEN Lifetime_Sales >= 1000  THEN 'Low-Mid Value — $1,000–$1,999'
        ELSE 'Low Value — Under $1,000'
    END                                             AS Value_Tier,
    COUNT(*)                                        AS Customer_Count,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Customer_Segment), 2)     AS Pct_Of_Segment,
    ROUND(SUM(Lifetime_Sales), 2)                   AS Segment_Sales_From_Tier,
    ROUND(AVG(Lifetime_Profit), 2)                  AS Avg_Lifetime_Profit
FROM Customer_Totals
GROUP BY Customer_Segment,
    CASE
        WHEN Lifetime_Sales >= 5000  THEN 'High Value — $5,000+'
        WHEN Lifetime_Sales >= 2000  THEN 'Mid Value — $2,000–$4,999'
        WHEN Lifetime_Sales >= 1000  THEN 'Low-Mid Value — $1,000–$1,999'
        ELSE 'Low Value — Under $1,000'
    END
ORDER BY Customer_Segment,
    MIN(Lifetime_Sales) DESC;
GO


-- ============================================================
-- SECTION 9 — EXTENDED: LOSS MAKING TOP CUSTOMERS
-- ============================================================
-- Identify customers generating high order volumes but
-- negative total profit. These are commercially active
-- but financially damaging relationships that require
-- account-level review.
-- ============================================================

WITH Customer_Totals AS (
    SELECT
        Customer_Id,
        Customer_Segment,
        Customer_City,
        Customer_Country,
        COUNT(*)                                    AS Total_Orders,
        ROUND(SUM(Sales), 2)                        AS Total_Sales,
        ROUND(SUM(Order_Profit_Per_Order), 2)       AS Total_Profit,
        ROUND(AVG(Order_Item_Discount_Rate), 4)     AS Avg_Discount_Rate
    FROM dbo.vw_DataCo_Cleaned
    GROUP BY Customer_Id, Customer_Segment,
             Customer_City, Customer_Country
)
SELECT TOP 10
    Customer_Id,
    Customer_Segment,
    Customer_City,
    Customer_Country,
    Total_Orders,
    Total_Sales,
    Total_Profit,
    Avg_Discount_Rate
FROM Customer_Totals
WHERE Total_Profit < 0
ORDER BY Total_Profit ASC;
GO


-- ============================================================
-- SECTION 10 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 6: CUSTOMER ORDER TRENDS
===============================================================

INSIGHT 1 — THE BUSINESS HAS THREE SEGMENT LABELS BUT
EFFECTIVELY ONE CUSTOMER PROFILE
Consumer, Corporate, and Home Office segments are
commercially indistinguishable across every measurable
dimension. Orders per customer (8.67–8.78), average order
value ($202.34–$204.22), average profit per order
($21.44–$22.18), top product categories (identical rank
order), and market distribution (within 1% across all
five markets) are virtually identical for all three.
The segmentation exists as a label but has not translated
into any differentiated commercial behaviour, pricing
strategy, or product preference. DataCo is not operating
with three segments — it is operating with one.

INSIGHT 2 — CONSUMER LEADS TOTAL REVENUE AND PROFIT
PURELY BY VOLUME NOT BY QUALITY
Consumer generates $19,095,790.16 in total sales (52.27%
of total profit) — but only because it has 10,695 customers
vs Corporate's 6,239 and Home Office's 3,718. On a per-
customer and per-order basis, all three segments are
essentially equal. There is no evidence that Consumer
customers are more valuable, more loyal, or more
profitable than Corporate or Home Office customers.

INSIGHT 3 — THE SAME NINE CATEGORIES DOMINATE ALL
THREE SEGMENTS IN THE SAME ORDER
Cleats, Men's Footwear, Women's Apparel, Indoor/Outdoor
Games, Fishing, Water Sports, Camping & Hiking, Cardio
Equipment, and Shop By Sport are the top 9 categories
for every segment — in the same rank order with near-
identical percentage shares (within 1% point per
category). No segment has a distinctive product
preference. The business is selling the same products
to all customers regardless of how they are labelled.

INSIGHT 4 — A 2017 PRICING OR MIX SHIFT AFFECTED ALL
SEGMENTS SIMULTANEOUSLY AND EQUALLY
Average order value increased by approximately $25 in
2017 for all three segments simultaneously — Consumer
from $197.28 to $222.43, Corporate from $195.77 to
$222.34, Home Office from $196.58 to $220.06. The
uniformity and simultaneity of this increase across
all segments rules out segment-specific explanations.
This is a company-wide event — likely a price increase,
product mix shift toward higher-value items, or a
change in promotional activity — that affected every
customer equally.

INSIGHT 5 — THE TOP CUSTOMER IS GENERATING A NET LOSS
Customer 791 (Corporate, Canton) is the highest sales
value customer at $10,524.17 across 43 orders but is
generating a total profit of -$866.38 — the business's
most commercially active customer is a loss-making
relationship. This indicates the account is likely
receiving excessive discounting or is concentrated
in low-margin products. Without account-level
commercial review, high-activity loss-making customers
are invisible in aggregate reporting.

INSIGHT 6 — CAGUAS CONCENTRATION CONTAMINATES
CUSTOMER-LEVEL ANALYSIS
6 of the top 10 highest value customers are from Caguas,
Puerto Rico — consistent with the data anomaly identified
in Module 4. If Caguas represents a recording default
rather than actual customer locations, individual
customer records from this city may not represent real
distinct customers. Customer-level analysis should be
treated with caution until the Caguas data issue is
resolved.

===============================================================
RECOMMENDATIONS — MODULE 6: CUSTOMER ORDER TRENDS
===============================================================

RECOMMENDATION 1 — REDESIGN THE CUSTOMER SEGMENTATION
FRAMEWORK AROUND MEASURABLE BEHAVIOURAL DIFFERENCES
The current three-segment model (Consumer, Corporate,
Home Office) has no analytical foundation — all three
behave identically. The business should build a new
segmentation framework based on actual behavioural
signals: order frequency, lifetime value, category
concentration, discount sensitivity, and delivery
mode preference. A value-based segmentation (High,
Mid, Low value tiers) would immediately enable more
targeted commercial decisions than the current labels.

RECOMMENDATION 2 — CONDUCT AN ACCOUNT REVIEW FOR
ALL LOSS-MAKING CUSTOMERS
Customer 791 (Corporate, Canton) is generating -$866.38
in total profit across 43 high-frequency orders. This
pattern — high activity, negative profit — typically
indicates excessive discounting at the account level.
A systematic review of all customers with negative
lifetime profit should be conducted, with the goal of
either renegotiating terms, adjusting product mix, or
in extreme cases, exiting the relationship.

RECOMMENDATION 3 — INVESTIGATE THE 2017 ORDER VALUE
INCREASE AND ASSESS REPLICABILITY
The $25 average order value increase in 2017 across
all segments represents a meaningful revenue uplift.
Understanding what caused it — whether a deliberate
pricing decision, a product ranging change, or an
external market factor — would allow the business to
assess whether it can be sustained or replicated in
subsequent periods. If it was a deliberate action, it
should be documented as a successful commercial lever.

RECOMMENDATION 4 — BUILD SEGMENT-SPECIFIC CATEGORY
PROMOTIONS TO CREATE GENUINE DIFFERENTIATION
Since all three segments currently buy the same products
at the same rates, there is an opportunity to design
segment-specific promotional calendars that create
genuine behavioural differentiation. For example,
Corporate customers could be offered bulk pricing
on high-volume categories, while Home Office customers
receive curated bundles. Even modest differentiation
would improve the commercial relevance of the
segmentation model.

RECOMMENDATION 5 — RESOLVE THE CAGUAS DATA ISSUE
BEFORE BUILDING ANY CUSTOMER RETENTION MODELS
Any customer lifetime value model, retention programme,
or personalisation initiative built on this dataset
will be distorted by the Caguas concentration anomaly.
This data quality issue should be resolved as a
prerequisite to any customer analytics investment.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 08_customer_trends.sql
-- ============================================================