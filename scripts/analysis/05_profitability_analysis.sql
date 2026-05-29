-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 05_profitability_analysis.sql
-- MODULE   : 3 — Profitability & Margin Analysis
-- PURPOSE  : Investigate profit distribution, loss-making
--            segments, discount impact, and margin drivers
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
Revenue figures look acceptable at the aggregate level, but
finance leadership has flagged that profit margins are
inconsistent and in some areas deeply negative. There is a
suspicion that certain product categories, customer segments,
or markets are being served at a loss — cross-subsidised by
higher-performing segments without anyone having clearly
identified the pattern.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We're generating sales, but I'm not convinced we're
generating profit in the right places. I want to know which
parts of the business are genuinely profitable and which
ones are quietly losing us money."
— Chief Financial Officer

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
Serving unprofitable segments at scale is a structural risk.
Without visibility into where margins are negative, the
business cannot make informed decisions about pricing,
discount policy, product portfolio, or market prioritisation.
With 33,784 loss-making orders generating -$3,883,547.35
in losses against total profit of $3,966,902.97, the
business is barely profitable in aggregate — losses are
nearly equal to gains.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. What is the overall profitability baseline?
Q2. Which product categories generate the highest and lowest
    profit margins?
Q3. Which customer segments are most and least profitable?
Q4. Are there markets operating at a net loss?
Q5. What is the relationship between discount rate and
    profitability?
Q6. Which department contributes most to total profit?

---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1: OVERALL PROFITABILITY BASELINE
-- ============================================================

SELECT
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)        AS Avg_Profit_Per_Order,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(AVG(Sales), 2)                         AS Avg_Sales_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio,
    SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END)                       AS Loss_Making_Orders,
    SUM(CASE WHEN Order_Profit_Per_Order = 0
        THEN 1 ELSE 0 END)                       AS Zero_Profit_Orders,
    SUM(CASE WHEN Order_Profit_Per_Order > 0
        THEN 1 ELSE 0 END)                       AS Profitable_Orders
FROM dbo.vw_DataCo_Cleaned;

/*
---------------------------------------------------------------
RESULT — Q1
---------------------------------------------------------------
Total_Profit   | Avg_Profit | Total_Sales    | Avg_Sales | Avg_Ratio | Loss_Orders | Zero | Profitable
$3,966,902.97  | $21.97     | $36,784,735.01 | $203.77   | 0.1206    | 33,784      | 1,177| 145,558
---------------------------------------------------------------
The business generated $3.97M in total profit on $36.78M
in sales — an effective margin of 10.78%. However, 33,784
loss-making orders generated -$3,883,547.35 in losses,
nearly wiping out total profit. The business is one bad
quarter away from aggregate loss.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: PROFITABILITY BY PRODUCT CATEGORY
-- ============================================================

SELECT
    Category_Name,
    COUNT(*)                                     AS Total_Orders,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)        AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order) AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2)
                                                 AS Profit_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q2 (Top 10 and Bottom 5)
---------------------------------------------------------------
Category              | Orders  | Total_Profit  | Avg_Profit | Ratio  | Sales
Fishing               | 17,325  | $756,220.77   | $43.65     | 0.1214 | $6,929,653.69
Cleats                | 24,551  | $494,636.92   | $20.15     | 0.1246 | $4,431,942.78
Camping & Hiking      | 13,729  | $427,455.57   | $31.14     | 0.1159 | $4,118,425.57
Cardio Equipment      | 12,487  | $383,011.10   | $30.67     | 0.1188 | $3,694,843.20
Women's Apparel       | 21,035  | $350,421.03   | $16.66     | 0.1222 | $3,147,800.00
Water Sports          | 15,540  | $325,146.96   | $20.92     | 0.1165 | $3,113,844.68
Indoor/Outdoor Games  | 19,298  | $318,451.43   | $16.50     | 0.1239 | $2,888,993.91
Men's Footwear        | 22,246  | $311,902.82   | $14.02     | 0.1201 | $2,891,757.66
Shop By Sport         | 10,984  | $129,813.96   | $11.82     | 0.1122 | $1,309,522.04
Computers             | 442     | $69,656.81    | $157.59    | 0.1171 | $663,000.00
...
Strength Training     | 111     | $332.31       | $2.99      | 0.0595 | $54,895.53
CDs                   | 271     | $383.85       | $1.42      | 0.1359 | $3,059.59
Books                 | 405     | $883.01       | $2.18      | 0.0791 | $12,587.40
Toys                  | 529     | $900.71       | $1.70      | 0.1619 | $6,104.66
Video Games           | 838     | $2,717.52     | $3.24      | 0.0917 | $33,310.50
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: PROFITABILITY BY CUSTOMER SEGMENT
-- ============================================================

SELECT
    Customer_Segment,
    COUNT(*)                                     AS Total_Orders,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)        AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order) AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2)
                                                 AS Profit_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Customer_Segment
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q3
---------------------------------------------------------------
Segment      | Orders  | Total_Profit    | Avg_Profit | Ratio  | Sales           | Share
Consumer     | 93,504  | $2,073,487.67   | $22.18     | 0.1212 | $19,095,790.16  | 52.27%
Corporate    | 54,789  | $1,202,574.96   | $21.95     | 0.1209 | $11,168,406.84  | 30.32%
Home Office  | 32,226  | $690,840.34     | $21.44     | 0.1186 | $6,520,538.02   | 17.42%
---------------------------------------------------------------
All three segments have nearly identical average profit per
order ($21.44–$22.18) and profit ratios (0.1186–0.1212).
Profit distribution mirrors order volume — Consumer leads
because it has the most orders, not because it is more
profitable per order.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q4: PROFITABILITY BY MARKET
-- ============================================================

SELECT
    Market,
    COUNT(*)                                     AS Total_Orders,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)        AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order) AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2)
                                                 AS Profit_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Market
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Market       | Orders  | Total_Profit    | Avg_Profit | Ratio  | Sales           | Share
Europe       | 50,252  | $1,169,442.96   | $23.27     | 0.1224 | $10,872,396.80  | 29.48%
LATAM        | 51,594  | $1,123,321.61   | $21.77     | 0.1212 | $10,277,612.84  | 28.32%
Pacific Asia | 41,260  | $857,753.44     | $20.79     | 0.1159 | $8,273,743.74   | 21.62%
USCA         | 25,799  | $564,313.78     | $21.87     | 0.1218 | $5,066,528.71   | 14.23%
Africa       | 11,614  | $252,071.18     | $21.70     | 0.1250 | $2,294,452.93   | 6.35%
---------------------------------------------------------------
No market is operating at a net loss. However, average
profit per order is virtually identical across all five
markets ($20.79–$23.27). Profit differences are driven
purely by order volume, not by market-level efficiency
or pricing power.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — Q5: DISCOUNT RATE VS PROFITABILITY
-- ============================================================

SELECT
    CASE
        WHEN Order_Item_Discount_Rate = 0     THEN '0% — No Discount'
        WHEN Order_Item_Discount_Rate <= 0.05 THEN '1–5%'
        WHEN Order_Item_Discount_Rate <= 0.10 THEN '6–10%'
        WHEN Order_Item_Discount_Rate <= 0.15 THEN '11–15%'
        WHEN Order_Item_Discount_Rate <= 0.20 THEN '16–20%'
        ELSE 'Above 20%'
    END                                            AS Discount_Tier,
    COUNT(*)                                       AS Total_Orders,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)         AS Avg_Profit_Ratio,
    ROUND(AVG(Order_Profit_Per_Order), 2)          AS Avg_Profit_Per_Order,
    ROUND(SUM(Order_Profit_Per_Order), 2)          AS Total_Profit,
    SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END)                         AS Loss_Making_Orders
FROM dbo.vw_DataCo_Cleaned
GROUP BY
    CASE
        WHEN Order_Item_Discount_Rate = 0     THEN '0% — No Discount'
        WHEN Order_Item_Discount_Rate <= 0.05 THEN '1–5%'
        WHEN Order_Item_Discount_Rate <= 0.10 THEN '6–10%'
        WHEN Order_Item_Discount_Rate <= 0.15 THEN '11–15%'
        WHEN Order_Item_Discount_Rate <= 0.20 THEN '16–20%'
        ELSE 'Above 20%'
    END
ORDER BY Avg_Profit_Ratio DESC;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Discount_Tier    | Orders  | Avg_Ratio | Avg_Profit | Total_Profit   | Loss_Orders
0% No Discount   | 10,028  | 0.1275    | $26.67     | $267,412.40    | 1,843
6–10%            | 40,116  | 0.1245    | $23.51     | $943,058.54    | 7,395
Above 20%        | 20,058  | 0.1197    | $18.41     | $369,209.46    | 3,817
1–5%             | 40,114  | 0.1196    | $23.26     | $933,213.85    | 7,496
11–15%           | 30,087  | 0.1189    | $21.47     | $646,082.47    | 5,660
16–20%           | 40,116  | 0.1179    | $20.14     | $807,926.25    | 7,573
---------------------------------------------------------------
Clear inverse relationship: as discount rate increases,
profit ratio and average profit per order both decline.
Orders with no discount generate the highest average
profit ratio (0.1275) and highest average profit per
order ($26.67). Every discount tier above 15% pushes
average profit meaningfully below the overall average
of $21.97.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — Q6: PROFITABILITY BY DEPARTMENT
-- ============================================================

SELECT
    Department_Name,
    COUNT(*)                                     AS Total_Orders,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)        AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order) AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2)
                                                 AS Profit_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Department_Name
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q6
---------------------------------------------------------------
Department      | Orders  | Total_Profit    | Avg_Profit | Ratio  | Sales           | Share
Fan Shop        | 66,861  | $1,834,155.44   | $27.43     | 0.1200 | $17,113,870.94  | 46.24%
Apparel         | 48,998  | $881,882.93     | $18.00     | 0.1228 | $7,976,255.34   | 22.23%
Golf            | 33,220  | $497,523.56     | $14.98     | 0.1188 | $4,609,028.24   | 12.54%
Footwear        | 14,525  | $410,222.50     | $28.24     | 0.1192 | $4,006,498.77   | 10.34%
Outdoors        | 9,686   | $145,251.46     | $15.00     | 0.1258 | $1,253,351.45   |  3.66%
Technology      | 1,465   | $113,170.01     | $77.25     | 0.1258 | $1,039,598.97   |  2.85%
Fitness         | 2,479   | $46,538.06      | $18.77     | 0.1312 | $397,050.89     |  1.17%
Discs Shop      | 2,026   | $24,193.12      | $11.94     | 0.1097 | $228,887.73     |  0.61%
Health & Beauty | 362     | $9,493.63       | $26.23     | 0.0956 | $106,080.48     |  0.24%
Pet Shop        | 492     | $3,589.26       | $7.30      | 0.0941 | $41,524.80      |  0.09%
Book Shop       | 405     | $883.01         | $2.18      | 0.0791 | $12,587.40      |  0.02%
---------------------------------------------------------------
Fan Shop dominates at 46.24% of total profit. Technology
is the hidden gem — only 1,465 orders but $77.25 average
profit per order, the highest of any department.
Book Shop generates almost no profit despite 405 orders.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 9 — EXTENDED: LOSS CONCENTRATION BY CATEGORY
-- ============================================================
-- Identify which categories are generating the most
-- loss-making orders and the highest total losses.
-- ============================================================

SELECT
    Category_Name,
    COUNT(*)                                     AS Total_Orders,
    SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END)                       AS Loss_Orders,
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*), 2)
                                                 AS Loss_Order_Pct,
    ROUND(SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN Order_Profit_Per_Order ELSE 0 END), 2)
                                                 AS Total_Loss_Amount
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name
HAVING SUM(CASE WHEN Order_Profit_Per_Order < 0
    THEN 1 ELSE 0 END) > 0
ORDER BY Total_Loss_Amount ASC;
GO


-- ============================================================
-- SECTION 10 — EXTENDED: HIGH SALES LOW PROFIT CATEGORIES
-- ============================================================
-- Identify categories generating significant sales revenue
-- but contributing disproportionately low profit.
-- These are volume-without-value segments.
-- ============================================================

SELECT
    Category_Name,
    ROUND(SUM(Sales), 2)                         AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)        AS Total_Profit,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order) AS FLOAT) /
        NULLIF(SUM(Sales), 0), 2)                AS Profit_Margin_Pct,
    COUNT(*)                                     AS Total_Orders,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)       AS Avg_Profit_Ratio
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name
HAVING SUM(Sales) > 500000
ORDER BY Profit_Margin_Pct ASC;
GO


-- ============================================================
-- SECTION 11 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 3: PROFITABILITY & MARGIN ANALYSIS
===============================================================

INSIGHT 1 — THE BUSINESS IS BARELY PROFITABLE IN AGGREGATE
Total profit of $3,966,902.97 on $36,784,735.01 in sales
represents an effective margin of 10.78%. However, 33,784
loss-making orders generated -$3,883,547.35 in losses —
nearly equal to total profit. If loss-making order volume
increases by even a small percentage, the business tips
into aggregate loss. The profitability position is fragile.

INSIGHT 2 — FISHING IS THE MOST PROFITABLE CATEGORY
Fishing generated $756,220.77 in total profit — 19.06%
of total company profit — from 17,325 orders at an average
of $43.65 profit per order. It is not the highest volume
category (Cleats has 24,551 orders) but it generates the
highest profit per order among high-volume categories,
making it the single most valuable product category in
the portfolio.

INSIGHT 3 — TECHNOLOGY DELIVERS THE HIGHEST PROFIT PER ORDER
The Technology department generated $77.25 average profit
per order — more than double any other department — on
just 1,465 orders. Despite contributing only 2.85% of
total profit due to low volume, its per-order economics
are the strongest in the business. Increasing Technology
order volume represents a high-margin growth opportunity
that the business appears not to be pursuing.

INSIGHT 4 — NO CUSTOMER SEGMENT IS MEANINGFULLY MORE
PROFITABLE THAN ANOTHER
Consumer, Corporate, and Home Office segments show nearly
identical average profit per order ($21.44–$22.18) and
profit ratios (0.1186–0.1212). Profit differences between
segments are driven entirely by order volume, not by
pricing power, product mix, or customer value. There is
no evidence that the business has differentiated its
commercial approach by segment — all three are treated
and performing identically.

INSIGHT 5 — DISCOUNTING IS ERODING MARGINS WITH NO VOLUME
COMPENSATION
As discount rate increases from 0% to above 20%, average
profit ratio falls from 0.1275 to 0.1179 and average
profit per order falls from $26.67 to $18.41. The 16–20%
discount tier alone contains 40,116 orders — the same
volume as the 6–10% tier — generating $134 less total
profit per 1,000 orders. Discounts above 15% are being
applied at high volume without evidence of generating
compensating order volume that would justify the margin
sacrifice.

INSIGHT 6 — FAN SHOP DOMINATES PROFIT BUT FOOTWEAR PUNCHES
ABOVE ITS WEIGHT
Fan Shop contributes 46.24% of total profit ($1,834,155.44)
and is clearly the commercial anchor of the business.
However, Footwear generates $28.24 average profit per
order — higher than Fan Shop's $27.43 — on 14,525 orders.
Footwear is the second most profitable department on a
per-order basis and represents an underdeveloped segment
relative to its margin potential.

===============================================================
RECOMMENDATIONS — MODULE 3: PROFITABILITY & MARGIN ANALYSIS
===============================================================

RECOMMENDATION 1 — PROTECT AND GROW FISHING CATEGORY VOLUME
Fishing is the highest total-profit category with strong
per-order economics. Any reduction in Fishing category
investment, ranging, or promotional activity should be
avoided. The business should analyse what drives Fishing's
above-average profit per order and explore whether those
factors — product mix, pricing, supplier terms — can be
replicated in adjacent outdoor categories.

RECOMMENDATION 2 — BUILD A BUSINESS CASE FOR TECHNOLOGY
VOLUME GROWTH
Technology's $77.25 average profit per order is the
strongest unit economics in the business. With only 1,465
orders, it is massively underrepresented relative to its
margin potential. A targeted initiative to increase
Technology order volume — through expanded ranging,
dedicated marketing, or B2B channel development — could
generate significant profit uplift without requiring any
improvement in per-order efficiency.

RECOMMENDATION 3 — IMPLEMENT A DISCOUNT GOVERNANCE POLICY
Discounts above 15% are being applied to 60,174 orders
(33.33% of all orders) and are generating measurably lower
profit ratios and per-order profit than lower discount
tiers. The business should establish a discount approval
policy requiring commercial justification for any discount
above 15%, with particular scrutiny on the above 20% tier
which generates the lowest average profit of any group.

RECOMMENDATION 4 — INVESTIGATE LOSS-MAKING ORDER ROOT CAUSES
33,784 orders generated losses totalling -$3,883,547.35.
This analysis identifies the scale but not the cause.
A follow-up investigation should determine whether losses
are concentrated in specific products, customers, discount
events, or shipping modes, and whether they represent
deliberate commercial decisions (promotional pricing,
customer acquisition) or operational inefficiencies that
can be eliminated.

RECOMMENDATION 5 — DEVELOP SEGMENT-DIFFERENTIATED
COMMERCIAL STRATEGIES
The identical profit per order across Consumer, Corporate,
and Home Office segments suggests the business is applying
a uniform commercial approach to all three. Corporate and
Home Office customers typically have higher order values
and longer relationships — building segment-specific
pricing, service levels, and product offerings could
unlock higher margins in these segments without volume
risk.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 05_profitability_analysis.sql
-- ============================================================