-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 06_regional_sales.sql
-- MODULE   : 4 — Regional Sales Imbalance
-- PURPOSE  : Investigate sales distribution, revenue
--            concentration, and regional performance gaps
--            across all markets and regions
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
DataCo operates across five international markets with
multiple regions within each. Sales performance data
suggests that revenue and order volume are heavily
concentrated in a small number of regions while others
remain persistently underperforming. Leadership wants
to understand whether this reflects genuine demand
differences, operational constraints, or untapped
commercial opportunity.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"Our sales are not evenly distributed and I don't think
it's purely a demand issue. Some regions might be
underserved, or we may be missing an opportunity to
rebalance our focus. I'd like to see where the
concentration sits."
— VP of Commercial Strategy

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Over-reliance on a small number of high-performing regions
creates commercial concentration risk. If those regions
experience economic disruption, the company's revenue
base is disproportionately exposed. Conversely,
underperforming regions with healthy margins may represent
addressable opportunity currently being left unrealised.
Analysis reveals that a single city — Caguas, Puerto Rico
— accounts for 37% of total company sales, representing
an extreme concentration risk that demands immediate
commercial attention.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. Which markets generate the highest total sales and
    order volume?
Q2. What is the revenue contribution of each region as
    a percentage of total sales?
Q3. Which regions are underperforming relative to the
    market average?
Q4. Are there high-volume regions generating
    disproportionately low profit?
Q5. Which customer cities generate the highest sales
    concentration?

---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1: SALES AND PROFIT BY MARKET
-- ============================================================
-- Establish market-level performance as the top-level view
-- of where revenue and profit are being generated globally.
-- ============================================================

SELECT
    Market,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales_Per_Order,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER (), 2)                 AS Sales_Share_Pct,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)                   AS Order_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q1
---------------------------------------------------------------
Market       | Orders  | Total_Sales     | Avg_Order | Profit          | Sales_Share | Order_Share
Europe       | 50,252  | $10,872,396.80  | $216.36   | $1,169,442.96   | 29.56%      | 27.84%
LATAM        | 51,594  | $10,277,612.84  | $199.20   | $1,123,321.61   | 27.94%      | 28.58%
Pacific Asia | 41,260  | $8,273,743.74   | $200.53   | $857,753.44     | 22.49%      | 22.86%
USCA         | 25,799  | $5,066,528.71   | $196.38   | $564,313.78     | 13.77%      | 14.29%
Africa       | 11,614  | $2,294,452.93   | $197.56   | $252,071.18     | 6.24%       | 6.43%
---------------------------------------------------------------
Europe leads on sales ($10.87M, 29.56%) with LATAM close
behind ($10.28M, 27.94%). Together they represent 57.50%
of total company sales. Africa contributes just 6.24%
of sales on 6.43% of orders — proportional but the
smallest market by significant distance.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: SALES AND PROFIT BY REGION
-- ============================================================
-- Drill below market level to identify which specific
-- regions drive revenue concentration within each market
-- and which are underweight relative to their market.
-- ============================================================

SELECT
    Market,
    Order_Region,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Sales), 2)                            AS Avg_Sales_Per_Order,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER (), 2)                 AS Sales_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q2 (Top 10 regions by sales)
---------------------------------------------------------------
Market       | Region           | Orders  | Total_Sales    | Avg_Order | Profit        | Ratio  | Share
Europe       | Western Europe   | 27,109  | $5,894,380.77  | $217.43   | $625,446.08   | 0.1220 | 16.02%
LATAM        | Central America  | 28,341  | $5,665,712.10  | $199.91   | $616,341.57   | 0.1204 | 15.40%
LATAM        | South America    | 14,935  | $2,960,881.41  | $198.25   | $335,154.40   | 0.1249 | 8.05%
Europe       | Northern Europe  | 9,792   | $2,155,830.65  | $220.16   | $233,450.60   | 0.1238 | 5.86%
Europe       | Southern Europe  | 9,431   | $2,047,918.82  | $217.15   | $230,829.23   | 0.1254 | 5.57%
Pacific Asia | Oceania          | 10,148  | $2,016,654.20  | $198.72   | $201,478.02   | 0.1136 | 5.48%
Pacific Asia | Southeast Asia   | 9,539   | $1,932,495.57  | $202.59   | $211,342.82   | 0.1169 | 5.25%
LATAM        | Caribbean        | 8,318   | $1,651,019.33  | $198.49   | $171,825.64   | 0.1173 | 4.49%
USCA         | West of USA      | 7,993   | $1,571,415.96  | $196.60   | $164,940.66   | 0.1169 | 4.27%
Pacific Asia | South Asia       | 7,731   | $1,553,680.92  | $200.97   | $165,703.90   | 0.1198 | 4.22%
...
Pacific Asia | Central Asia     | 553     | $109,839.93    | $198.63   | $13,045.28    | 0.1329 | 0.30%
USCA         | Canada           | 959     | $186,861.04    | $194.85   | $23,900.71    | 0.1357 | 0.51%
---------------------------------------------------------------
Western Europe alone contributes 16.02% of total company
sales — more than the entire Africa market (6.24%).
Central Asia is the smallest region at just 0.30% share
despite a healthy profit ratio of 0.1329.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: UNDERPERFORMING REGIONS
-- ============================================================
-- Identify regions performing below the global average
-- order value ($203.77) and below their market average.
-- Regions with healthy margins but low volume are the
-- highest-priority commercial development opportunities.
-- ============================================================

WITH Market_Averages AS (
    SELECT
        Market,
        ROUND(AVG(Sales), 2)                        AS Market_Avg_Order_Value,
        ROUND(SUM(Sales), 2)                        AS Market_Total_Sales,
        COUNT(*)                                    AS Market_Total_Orders
    FROM dbo.vw_DataCo_Cleaned
    GROUP BY Market
)
SELECT
    v.Market,
    v.Order_Region,
    COUNT(*)                                        AS Region_Orders,
    ROUND(SUM(v.Sales), 2)                          AS Region_Sales,
    ROUND(AVG(v.Sales), 2)                          AS Region_Avg_Order_Value,
    ma.Market_Avg_Order_Value,
    ROUND(AVG(v.Sales) - ma.Market_Avg_Order_Value, 2)
                                                    AS Gap_vs_Market_Avg,
    ROUND(AVG(v.Order_Item_Profit_Ratio), 4)        AS Avg_Profit_Ratio,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        ma.Market_Total_Orders, 2)                  AS Region_Order_Share_In_Market
FROM dbo.vw_DataCo_Cleaned v
JOIN Market_Averages ma ON v.Market = ma.Market
GROUP BY
    v.Market,
    v.Order_Region,
    ma.Market_Avg_Order_Value,
    ma.Market_Total_Sales,
    ma.Market_Total_Orders
ORDER BY Gap_vs_Market_Avg ASC;
GO


-- ============================================================
-- SECTION 6 — Q4: HIGH VOLUME LOW PROFIT REGIONS
-- ============================================================
-- Identify regions generating significant order volume
-- but contributing disproportionately low profit margins.
-- These are volume-without-value segments where commercial
-- strategy may need to be reviewed.
-- ============================================================

SELECT
    Market,
    Order_Region,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) / NULLIF(SUM(Sales), 0), 2)       AS Profit_Margin_Pct,
    ROUND(AVG(CAST(Sales AS FLOAT)), 2)             AS Avg_Order_Value
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
ORDER BY Total_Orders DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Market       | Region           | Orders  | Sales          | Profit        | Margin  | Avg_Order
LATAM        | Central America  | 28,341  | $5,665,712.10  | $616,341.57   | 10.88%  | $199.91
Europe       | Western Europe   | 27,109  | $5,894,380.77  | $625,446.08   | 10.61%  | $217.43
LATAM        | South America    | 14,935  | $2,960,881.41  | $335,154.40   | 11.32%  | $198.25
Pacific Asia | Oceania          | 10,148  | $2,016,654.20  | $201,478.02   | 9.99%   | $198.72
Europe       | Northern Europe  | 9,792   | $2,155,830.65  | $233,450.60   | 10.83%  | $220.16
Pacific Asia | Southeast Asia   | 9,539   | $1,932,495.57  | $211,342.82   | 10.94%  | $202.59
Europe       | Southern Europe  | 9,431   | $2,047,918.82  | $230,829.23   | 11.27%  | $217.15
LATAM        | Caribbean        | 8,318   | $1,651,019.33  | $171,825.64   | 10.41%  | $198.49
USCA         | West of USA      | 7,993   | $1,571,415.96  | $164,940.66   | 10.50%  | $196.60
Pacific Asia | South Asia       | 7,731   | $1,553,680.92  | $165,703.90   | 10.67%  | $200.97
...
Africa       | Southern Africa  | 1,157   | $228,251.59    | $30,826.05    | 13.51%  | $197.28
USCA         | Canada           | 959     | $186,861.04    | $23,900.71    | 12.79%  | $194.85
Pacific Asia | Central Asia     | 553     | $109,839.93    | $13,045.28    | 11.88%  | $198.63
---------------------------------------------------------------
No region operates at a loss. Profit margins are tightly
clustered between 9.91% and 13.51% globally. The highest
margins belong to low-volume regions — Southern Africa
(13.51%), East Africa (13.97%), and Canada (12.79%) —
suggesting untapped commercial potential in these markets.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — Q5: TOP CUSTOMER CITIES BY SALES
-- ============================================================
-- Identify where sales are geographically concentrated
-- at city level. High concentration in a single city
-- represents commercial risk if that market is disrupted.
-- ============================================================

SELECT TOP 10
    Customer_Country,
    Customer_State,
    Customer_City,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Sales), 2)                            AS Avg_Order_Value,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER (), 2)                 AS Sales_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Country, Customer_State, Customer_City
ORDER BY Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Country    | State | City          | Orders | Total_Sales     | Profit          | Avg_Order | Share
Puerto Rico| PR    | Caguas        | 66,770 | $13,610,266.21  | $1,450,506.77   | $203.84   | 37.00%
EE. UU.    | IL    | Chicago       | 3,885  | $797,614.21     | $85,725.92      | $205.31   | 2.17%
EE. UU.    | CA    | Los Angeles   | 3,417  | $697,887.42     | $80,584.82      | $204.24   | 1.90%
EE. UU.    | NY    | Brooklyn      | 3,412  | $676,419.78     | $67,231.87      | $198.25   | 1.84%
EE. UU.    | NY    | New York      | 1,816  | $361,217.10     | $39,302.14      | $198.91   | 0.98%
EE. UU.    | PA    | Philadelphia  | 1,577  | $315,705.51     | $30,163.09      | $200.19   | 0.86%
EE. UU.    | NY    | Bronx         | 1,500  | $308,905.01     | $40,944.77      | $205.94   | 0.84%
EE. UU.    | CA    | San Diego     | 1,437  | $293,830.52     | $26,133.64      | $204.47   | 0.80%
EE. UU.    | FL    | Miami         | 1,314  | $270,368.20     | $35,480.25      | $205.76   | 0.74%
EE. UU.    | TX    | Houston       | 1,297  | $267,347.92     | $30,684.53      | $206.13   | 0.73%
---------------------------------------------------------------
CRITICAL FINDING: Caguas, Puerto Rico accounts for 37% of
total company sales ($13,610,266.21) from 66,770 orders.
The next largest city — Chicago — contributes just 2.17%.
This extreme concentration in a single city almost certainly
reflects a data recording anomaly (default billing address
or warehouse location) rather than genuine customer demand.
This should be investigated and validated before any
commercial decisions are made based on city-level data.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — YEAR OVER YEAR SALES TREND BY MARKET
-- ============================================================
-- Track whether sales are growing, declining, or shifting
-- between markets over the 2015–2018 period.
-- Note: Dataset has uneven year coverage per market —
-- some markets show data gaps in certain years which
-- reflects dataset composition, not zero sales.
-- ============================================================

SELECT
    Market,
    YEAR(order_date_DateOrders)                     AS Order_Year,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(AVG(Sales), 2)                            AS Avg_Order_Value,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, YEAR(order_date_DateOrders)
ORDER BY Market, Order_Year;

/*
---------------------------------------------------------------
RESULT — YEAR OVER YEAR TREND
---------------------------------------------------------------
Market       | Year | Orders | Total_Sales    | Avg_Order | Profit
Africa       | 2016 | 10,356 | $2,046,622.76  | $197.63   | $221,898.63
Africa       | 2017 | 1,258  | $247,830.16    | $197.00   | $30,172.55
Europe       | 2015 | 24,914 | $4,913,405.44  | $197.21   | $534,427.25
Europe       | 2016 | 3,872  | $761,323.34    | $196.62   | $80,113.46
Europe       | 2017 | 21,466 | $5,197,668.01  | $242.13   | $554,902.25
LATAM        | 2015 | 25,775 | $5,072,188.47  | $196.79   | $541,853.74
LATAM        | 2017 | 25,819 | $5,205,424.37  | $201.61   | $581,467.87
Pacific Asia | 2015 | 11,961 | $2,355,237.53  | $196.91   | $242,575.91
Pacific Asia | 2016 | 22,641 | $4,452,405.70  | $196.65   | $447,979.76
Pacific Asia | 2017 | 4,535  | $1,134,450.40  | $250.15   | $133,355.88
Pacific Asia | 2018 | 2,123  | $331,650.12    | $156.22   | $33,841.89
USCA         | 2016 | 25,681 | $5,043,465.52  | $196.39   | $560,127.22
USCA         | 2017 | 118    | $23,063.19     | $195.45   | $4,186.56
---------------------------------------------------------------
NOTE: Missing years per market (e.g. Africa has no 2015
data, LATAM has no 2016) reflect uneven dataset coverage
rather than actual zero sales periods. Year-over-year
comparisons should be interpreted with this caveat.
Europe 2017 shows a notable average order value increase
to $242.13 vs $197.21 in 2015 — worth further investigation.
Pacific Asia 2018 average order value drops to $156.22 —
the lowest recorded across any market-year combination.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 9 — EXTENDED: WITHIN MARKET CONCENTRATION
-- ============================================================
-- Measure how concentrated sales are within each market.
-- A market dominated by one region carries higher risk
-- than one distributed evenly across regions.
-- ============================================================

SELECT
    Market,
    Order_Region,
    ROUND(SUM(Sales), 2)                            AS Region_Sales,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER
            (PARTITION BY Market), 2)               AS Share_Within_Market,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Market), 2)               AS Order_Share_Within_Market
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
ORDER BY Market, Region_Sales DESC;
GO


-- ============================================================
-- SECTION 10 — EXTENDED: MARGIN LEADERS BY REGION
-- ============================================================
-- Surface the regions with the highest profit margins —
-- these are the most commercially efficient regions and
-- represent the best targets for volume growth investment.
-- ============================================================

SELECT
    Market,
    Order_Region,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) / NULLIF(SUM(Sales), 0), 2)       AS Profit_Margin_Pct,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market, Order_Region
HAVING COUNT(*) >= 500
ORDER BY Profit_Margin_Pct DESC;
GO
