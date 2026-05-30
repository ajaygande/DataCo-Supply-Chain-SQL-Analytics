-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 09_product_category.sql
-- MODULE   : 7 — Product Category Performance
-- PURPOSE  : Evaluate sales, profit, margin, and loss
--            distribution across all product categories
--            and departments to identify portfolio strengths,
--            weaknesses, and rationalisation opportunities
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
The company sells products across multiple departments and
categories. Some categories consistently drive high revenue
and profit while others generate volume without meaningful
margin contribution. The product team lacks a structured
view of category-level performance and is making ranging
and promotional decisions without clear data on what is
and is not working commercially.

---------------------------------------------------------------
STAKEHOLDER CONCERN
---------------------------------------------------------------
"We have a wide product range but I suspect we're carrying
categories that aren't pulling their weight. I'd like to
know which categories are genuinely performing and which
ones we should be reviewing."
— Head of Merchandising

---------------------------------------------------------------
BUSINESS IMPACT
---------------------------------------------------------------
An unrationalised product portfolio inflates supply chain
complexity, increases logistics costs, and dilutes
commercial focus. With 50 product categories across
11 departments, identifying where profit is genuinely
being created versus where volume is masking loss exposure
is essential for sustainable commercial decision-making.
Analysis reveals that every single category carries
loss-making orders, and that net profit across the
portfolio is the thin margin between two large opposing
forces of profit and loss on either side.

---------------------------------------------------------------
ANALYTICAL QUESTIONS
---------------------------------------------------------------
Q1. Which product categories generate the highest total
    sales and total profit?
Q2. Which categories have the highest and lowest average
    profit margins?
Q3. Are there high-volume categories generating
    negative or near-zero profit?
Q4. Which departments are the strongest contributors
    to overall revenue and margin?
Q5. How does product category performance vary across
    different markets?

---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — Q1 & Q2: CATEGORY PERFORMANCE RANKED BY PROFIT
-- ============================================================
-- Establish the full category performance landscape —
-- which categories are generating the most commercial
-- value and which are underperforming relative to their
-- sales volume.
-- ============================================================

SELECT
    Category_Name,
    Department_Name,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)           AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER (), 2)                 AS Sales_Share_Pct,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2) AS Profit_Share_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name, Department_Name
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q1 & Q2 (Top 10 categories)
---------------------------------------------------------------
Category             | Dept        | Orders  | Sales          | Profit       | Avg_Prof | Ratio  | Sales% | Profit%
Fishing              | Fan Shop    | 17,325  | $6,929,653.69  | $756,220.77  | $43.65   | 0.1214 | 18.84% | 19.06%
Cleats               | Apparel     | 24,551  | $4,431,942.78  | $494,636.92  | $20.15   | 0.1246 | 12.05% | 12.47%
Camping & Hiking     | Fan Shop    | 13,729  | $4,118,425.57  | $427,455.57  | $31.14   | 0.1159 | 11.20% | 10.78%
Cardio Equipment     | Footwear    | 12,487  | $3,694,843.20  | $383,011.10  | $30.67   | 0.1188 | 10.04% | 9.66%
Women's Apparel      | Golf        | 21,035  | $3,147,800.00  | $350,421.03  | $16.66   | 0.1222 | 8.56%  | 8.83%
Water Sports         | Fan Shop    | 15,540  | $3,113,844.68  | $325,146.96  | $20.92   | 0.1165 | 8.47%  | 8.20%
Indoor/Outdoor Games | Fan Shop    | 19,298  | $2,888,993.91  | $318,451.43  | $16.50   | 0.1239 | 7.85%  | 8.03%
Men's Footwear       | Apparel     | 22,246  | $2,891,757.66  | $311,902.82  | $14.02   | 0.1201 | 7.86%  | 7.86%
Shop By Sport        | Golf        | 10,984  | $1,309,522.04  | $129,813.96  | $11.82   | 0.1122 | 3.56%  | 3.27%
Computers            | Technology  | 442     | $663,000.00    | $69,656.81   | $157.59  | 0.1171 | 1.80%  | 1.76%
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 4 — Q2: HIGH SALES LOW MARGIN CATEGORIES
-- ============================================================
-- Identify categories generating significant revenue but
-- contributing disproportionately low profit margins.
-- Filtered to categories with over $500,000 in sales
-- to focus on commercially significant segments.
-- ============================================================

SELECT
    Category_Name,
    Department_Name,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) /
        NULLIF(SUM(Sales), 0), 2)                   AS Profit_Margin_Pct,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio,
    ROUND(AVG(Order_Item_Discount_Rate), 4)         AS Avg_Discount_Rate
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name, Department_Name
HAVING SUM(Sales) > 500000
ORDER BY Profit_Margin_Pct ASC;

/*
---------------------------------------------------------------
RESULT — Q2
---------------------------------------------------------------
Category             | Dept       | Orders  | Sales          | Profit       | Margin  | Ratio  | Disc_Rate
Shop By Sport        | Golf       | 10,984  | $1,309,522.04  | $129,813.96  | 9.91%   | 0.1122 | 0.1014
Cardio Equipment     | Footwear   | 12,487  | $3,694,843.20  | $383,011.10  | 10.37%  | 0.1188 | 0.1017
Camping & Hiking     | Fan Shop   | 13,729  | $4,118,425.57  | $427,455.57  | 10.38%  | 0.1159 | 0.1017
Water Sports         | Fan Shop   | 15,540  | $3,113,844.68  | $325,146.96  | 10.44%  | 0.1165 | 0.1017
Computers            | Technology | 442     | $663,000.00    | $69,656.81   | 10.51%  | 0.1171 | 0.1022
Men's Footwear       | Apparel    | 22,246  | $2,891,757.66  | $311,902.82  | 10.79%  | 0.1201 | 0.1017
Fishing              | Fan Shop   | 17,325  | $6,929,653.69  | $756,220.77  | 10.91%  | 0.1214 | 0.1017
Indoor/Outdoor Games | Fan Shop   | 19,298  | $2,888,993.91  | $318,451.43  | 11.02%  | 0.1239 | 0.1015
Women's Apparel      | Golf       | 21,035  | $3,147,800.00  | $350,421.03  | 11.13%  | 0.1222 | 0.1017
Cleats               | Apparel    | 24,551  | $4,431,942.78  | $494,636.92  | 11.16%  | 0.1246 | 0.1016
---------------------------------------------------------------
All top 10 categories have virtually identical discount
rates of ~10.17% — a uniform commercial approach applied
regardless of category margin strength or competitive
position. Profit margins span just 1.25 percentage points
(9.91%–11.16%) across categories generating $25M+ in
combined sales. There is no margin differentiation by
category in the current commercial model.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 5 — Q3: LOSS-MAKING ORDER ANALYSIS BY CATEGORY
-- ============================================================
-- Every category carries loss-making orders. This section
-- quantifies the scale of losses per category and identifies
-- where gross losses are highest relative to gross profit.
-- ============================================================

SELECT
    Category_Name,
    Department_Name,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END)                          AS Loss_Orders,
    ROUND(CAST(100.0 * SUM(CASE WHEN
        Order_Profit_Per_Order < 0
        THEN 1 ELSE 0 END) AS FLOAT) /
        COUNT(*), 2)                                AS Loss_Order_Pct,
    ROUND(SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN Order_Profit_Per_Order
        ELSE 0 END), 2)                             AS Total_Loss_Amount
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name, Department_Name
ORDER BY Total_Loss_Amount ASC;

/*
---------------------------------------------------------------
RESULT — Q3 (Top loss categories)
---------------------------------------------------------------
Category             | Orders  | Profit       | Loss_Orders | Loss_Pct | Total_Loss
Fishing              | 17,325  | $756,220.77  | 3,209       | 18.52%   | -$728,570.95
Cleats               | 24,551  | $494,636.92  | 4,590       | 18.70%   | -$452,594.21
Camping & Hiking     | 13,729  | $427,455.57  | 2,590       | 18.87%   | -$443,082.23
Cardio Equipment     | 12,487  | $383,011.10  | 2,332       | 18.68%   | -$402,647.26
Water Sports         | 15,540  | $325,146.96  | 2,924       | 18.82%   | -$334,569.63
Women's Apparel      | 21,035  | $350,421.03  | 3,923       | 18.65%   | -$323,772.87
Men's Footwear       | 22,246  | $311,902.82  | 4,169       | 18.74%   | -$309,269.70
Indoor/Outdoor Games | 19,298  | $318,451.43  | 3,617       | 18.74%   | -$298,637.48
---------------------------------------------------------------
CRITICAL FINDING: Every single category in the portfolio
carries loss-making orders. Loss order rates are uniform
across all categories — between 13% and 24% regardless
of category size, margin, or department. This is not a
category-specific problem — it is a structural company-
wide pricing or discount issue affecting every product
line equally.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — Q4: DEPARTMENT LEVEL PERFORMANCE SUMMARY
-- ============================================================
-- Aggregate category performance to department level for
-- executive reporting. Identifies which departments
-- anchor the portfolio and which are peripheral.
-- ============================================================

SELECT
    Department_Name,
    COUNT(DISTINCT Category_Name)                   AS Category_Count,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Order_Profit_Per_Order), 2)           AS Avg_Profit_Per_Order,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio,
    ROUND(CAST(100.0 * SUM(Sales) AS FLOAT) /
        SUM(SUM(Sales)) OVER (), 2)                 AS Sales_Share_Pct,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) /
        SUM(SUM(Order_Profit_Per_Order)) OVER (), 2) AS Profit_Share_Pct,
    ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
        AS FLOAT) /
        NULLIF(SUM(Sales), 0), 2)                   AS Profit_Margin_Pct
FROM dbo.vw_DataCo_Cleaned
GROUP BY Department_Name
ORDER BY Total_Profit DESC;

/*
---------------------------------------------------------------
RESULT — Q4
---------------------------------------------------------------
Department      | Cats | Orders  | Sales           | Profit          | Avg_Prof | Ratio  | Sales% | Profit% | Margin
Fan Shop        | 6    | 66,861  | $17,113,870.94  | $1,834,155.44   | $27.43   | 0.1200 | 46.52% | 46.24%  | 10.72%
Apparel         | 7    | 48,998  | $7,976,255.34   | $881,882.93     | $18.00   | 0.1228 | 21.68% | 22.23%  | 11.06%
Golf            | 3    | 33,220  | $4,609,028.24   | $497,523.56     | $14.98   | 0.1188 | 12.53% | 12.54%  | 10.79%
Footwear        | 6    | 14,525  | $4,006,498.77   | $410,222.50     | $28.24   | 0.1192 | 10.89% | 10.34%  | 10.24%
Outdoors        | 12   | 9,686   | $1,253,351.45   | $145,251.46     | $15.00   | 0.1258 | 3.41%  | 3.66%   | 11.59%
Technology      | 3    | 1,465   | $1,039,598.97   | $113,170.01     | $77.25   | 0.1258 | 2.83%  | 2.85%   | 10.89%
Fitness         | 7    | 2,479   | $397,050.89     | $46,538.06      | $18.77   | 0.1312 | 1.08%  | 1.17%   | 11.72%
Discs Shop      | 4    | 2,026   | $228,887.73     | $24,193.12      | $11.94   | 0.1097 | 0.62%  | 0.61%   | 10.57%
Health & Beauty | 1    | 362     | $106,080.48     | $9,493.63       | $26.23   | 0.0956 | 0.29%  | 0.24%   | 8.95%
Pet Shop        | 1    | 492     | $41,524.80      | $3,589.26       | $7.30    | 0.0941 | 0.11%  | 0.09%   | 8.64%
Book Shop       | 1    | 405     | $12,587.40      | $883.01         | $2.18    | 0.0791 | 0.03%  | 0.02%   | 7.02%
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 7 — Q5: TOP CATEGORY PERFORMANCE BY MARKET
-- ============================================================
-- Analyse whether the top 5 categories perform consistently
-- across all markets or show geographic variation that
-- would indicate market-specific product strategies.
-- ============================================================

SELECT
    Category_Name,
    Market,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(Sales), 2)                            AS Total_Sales,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Total_Profit,
    ROUND(AVG(Order_Item_Profit_Ratio), 4)          AS Avg_Profit_Ratio,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER
            (PARTITION BY Category_Name), 2)        AS Market_Share_Within_Category
FROM dbo.vw_DataCo_Cleaned
WHERE Category_Name IN (
    'Fishing', 'Cleats', 'Camping & Hiking',
    'Cardio Equipment', 'Women''s Apparel'
)
GROUP BY Category_Name, Market
ORDER BY Category_Name, Total_Sales DESC;

/*
---------------------------------------------------------------
RESULT — Q5
---------------------------------------------------------------
Category         | Market       | Orders | Sales          | Profit       | Ratio  | Share
Camping & Hiking | LATAM        | 4,200  | $1,259,916.05  | $123,755.19  | 0.1103 | 30.59%
Camping & Hiking | Europe       | 3,793  | $1,137,824.18  | $116,472.93  | 0.1135 | 27.63%
Camping & Hiking | Pacific Asia | 2,798  | $839,344.07    | $91,489.78   | 0.1212 | 20.38%
Camping & Hiking | USCA         | 2,054  | $616,158.94    | $70,647.67   | 0.1285 | 14.96%
Camping & Hiking | Africa       | 884    | $265,182.33    | $25,090.00   | 0.1078 | 6.44%
Cardio Equipment | LATAM        | 3,759  | $1,114,119.45  | $128,470.71  | 0.1266 | 30.10%
Cardio Equipment | Europe       | 3,511  | $1,037,066.91  | $98,722.06   | 0.1130 | 28.12%
Cardio Equipment | Pacific Asia | 2,563  | $751,895.40    | $69,278.77   | 0.1098 | 20.53%
Cardio Equipment | USCA         | 1,800  | $534,586.95    | $53,141.10   | 0.1107 | 14.41%
Cardio Equipment | Africa       | 854    | $257,174.49    | $33,398.46   | 0.1529 | 6.84%
Cleats           | LATAM        | 7,280  | $1,312,641.23  | $149,565.18  | 0.1253 | 29.65%
Cleats           | Europe       | 6,805  | $1,229,016.60  | $147,595.54  | 0.1297 | 27.72%
Cleats           | Pacific Asia | 5,081  | $917,187.14    | $97,028.51   | 0.1236 | 20.70%
Cleats           | USCA         | 3,723  | $674,647.56    | $69,225.58   | 0.1195 | 15.16%
Cleats           | Africa       | 1,662  | $298,450.26    | $31,222.11   | 0.1152 | 6.77%
Fishing          | LATAM        | 5,084  | $2,033,498.38  | $223,265.75  | 0.1216 | 29.34%
Fishing          | Europe       | 4,815  | $1,925,903.75  | $207,658.61  | 0.1206 | 27.79%
Fishing          | Pacific Asia | 3,673  | $1,469,126.58  | $148,673.22  | 0.1133 | 21.20%
Fishing          | USCA         | 2,568  | $1,027,148.67  | $128,388.72  | 0.1389 | 14.82%
Fishing          | Africa       | 1,185  | $473,976.31    | $48,234.46   | 0.1117 | 6.84%
Women's Apparel  | LATAM        | 6,280  | $945,400.00    | $102,492.47  | 0.1182 | 29.86%
Women's Apparel  | Europe       | 5,912  | $883,800.00    | $103,713.43  | 0.1295 | 28.11%
Women's Apparel  | Pacific Asia | 4,209  | $631,500.00    | $62,905.95   | 0.1112 | 20.01%
Women's Apparel  | USCA         | 3,215  | $478,000.00    | $60,893.42   | 0.1361 | 15.28%
Women's Apparel  | Africa       | 1,419  | $209,100.00    | $20,415.76   | 0.1103 | 6.75%
---------------------------------------------------------------
Market distribution mirrors the global split for every
category — LATAM ~30%, Europe ~28%, Pacific Asia ~21%,
USCA ~15%, Africa ~7%. No category has a geographic
concentration. One notable exception: Africa's Cardio
Equipment profit ratio (0.1529) and USCA's Fishing
profit ratio (0.1389) are meaningfully above their
respective category averages — indicating untapped
margin potential in specific market-category combinations.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 8 — EXTENDED: GROSS PROFIT VS GROSS LOSS
-- ============================================================
-- Compare gross profit generated against gross losses
-- incurred per category. Net profit is the residual
-- between two large opposing forces — understanding
-- the gross components reveals the true risk profile
-- of each category.
-- ============================================================

SELECT
    Category_Name,
    Department_Name,
    COUNT(*)                                        AS Total_Orders,
    ROUND(SUM(CASE WHEN Order_Profit_Per_Order > 0
        THEN Order_Profit_Per_Order ELSE 0 END), 2) AS Gross_Profit,
    ROUND(ABS(SUM(CASE WHEN Order_Profit_Per_Order < 0
        THEN Order_Profit_Per_Order ELSE 0 END)), 2) AS Gross_Loss,
    ROUND(SUM(Order_Profit_Per_Order), 2)           AS Net_Profit,
    ROUND(CAST(100.0 * ABS(SUM(CASE WHEN
        Order_Profit_Per_Order < 0
        THEN Order_Profit_Per_Order ELSE 0 END))
        AS FLOAT) /
        NULLIF(SUM(CASE WHEN Order_Profit_Per_Order > 0
        THEN Order_Profit_Per_Order ELSE 0 END), 0), 2)
                                                    AS Loss_As_Pct_Of_Gross_Profit
FROM dbo.vw_DataCo_Cleaned
GROUP BY Category_Name, Department_Name
HAVING SUM(Sales) > 500000
ORDER BY Loss_As_Pct_Of_Gross_Profit DESC;
GO


-- ============================================================
-- SECTION 9 — EXTENDED: CATEGORY EFFICIENCY MATRIX
-- ============================================================
-- Score each category on two dimensions simultaneously:
-- sales volume rank and profit margin rank. Categories
-- that rank high on volume but low on margin are
-- volume-without-value segments requiring review.
-- ============================================================

WITH Category_Metrics AS (
    SELECT
        Category_Name,
        Department_Name,
        COUNT(*)                                    AS Total_Orders,
        ROUND(SUM(Sales), 2)                        AS Total_Sales,
        ROUND(SUM(Order_Profit_Per_Order), 2)       AS Total_Profit,
        ROUND(CAST(100.0 * SUM(Order_Profit_Per_Order)
            AS FLOAT) /
            NULLIF(SUM(Sales), 0), 2)               AS Profit_Margin_Pct
    FROM dbo.vw_DataCo_Cleaned
    GROUP BY Category_Name, Department_Name
)
SELECT
    Category_Name,
    Department_Name,
    Total_Orders,
    Total_Sales,
    Total_Profit,
    Profit_Margin_Pct,
    RANK() OVER (ORDER BY Total_Sales DESC)         AS Sales_Volume_Rank,
    RANK() OVER (ORDER BY Profit_Margin_Pct DESC)   AS Margin_Rank,
    RANK() OVER (ORDER BY Total_Sales DESC) -
    RANK() OVER (ORDER BY Profit_Margin_Pct DESC)   AS Volume_Margin_Gap
FROM Category_Metrics
ORDER BY Volume_Margin_Gap DESC;
GO


-- ============================================================
-- SECTION 10 — MODULE SUMMARY
-- ============================================================

/*
===============================================================
BUSINESS INSIGHTS — MODULE 7: PRODUCT CATEGORY PERFORMANCE
===============================================================

INSIGHT 1 — EVERY CATEGORY IN THE PORTFOLIO CARRIES
LOSS-MAKING ORDERS WITHOUT EXCEPTION
All 50 product categories contain orders generating
negative profit. Loss order rates are remarkably uniform
— between 13% and 24% across every category regardless
of volume, margin, or department. This uniformity
conclusively rules out category-specific causes. The
loss-making order problem is a company-wide structural
issue — almost certainly driven by the uniform ~10.17%
discount rate applied across all categories — rather
than a product portfolio problem that can be solved
by removing specific categories.

INSIGHT 2 — FISHING IS THE COMMERCIAL ANCHOR OF
THE PRODUCT PORTFOLIO
Fishing generates $756,220.77 in total profit (19.06%
of company profit) on $6,929,653.69 in sales (18.84%
of company sales) — the highest of any category on
both measures. Its average profit per order ($43.65)
is more than double the company average ($21.97) and
more than double the next highest volume category.
Fishing is not only the largest profit contributor
but also the most efficient high-volume category in
the portfolio. Any reduction in Fishing investment
would have an immediate and disproportionate impact
on company profitability.

INSIGHT 3 — COMPUTERS GENERATE THE HIGHEST PROFIT
PER ORDER IN THE ENTIRE PORTFOLIO BUT ARE BARELY PRESENT
Computers average $157.59 profit per order — 7.2 times
the company average — on just 442 orders representing
1.80% of sales. The Technology department overall
averages $77.25 profit per order — the highest of any
department — on 1,465 orders. The business has its
most efficient product category generating less than
2% of its revenue. This is the single largest
unrealised commercial opportunity in the portfolio.

INSIGHT 4 — NET PROFIT IS A THIN MARGIN BETWEEN
TWO LARGE OPPOSING FORCES
Fishing's $756,220.77 net profit sits alongside
-$728,570.95 in gross losses — meaning 49.1% of
Fishing's gross profit is being destroyed by
loss-making orders within the same category.
This pattern repeats across all top categories.
The business is not running a profitable portfolio
with some weak spots — it is running a portfolio
where every category simultaneously generates
significant profit and significant losses, with
net profit as the precarious residual between them.

INSIGHT 5 — FAN SHOP DOMINATES BY VOLUME BUT NOT
BY EFFICIENCY
Fan Shop generates 46.52% of total sales and 46.24%
of total profit — but its margin (10.72%) is below
Apparel (11.06%), Outdoors (11.59%), Fitness (11.72%),
and Technology (10.89%). Fan Shop wins purely on order
volume across its 6 categories. If Fan Shop order
volume declined by 10%, the company would need a
significant margin improvement across other departments
to compensate. The business is heavily dependent on
a single department with below-average efficiency.

INSIGHT 6 — BOOK SHOP, PET SHOP AND HEALTH & BEAUTY
ARE STRUCTURALLY MARGINAL DEPARTMENTS
Book Shop generates $883.01 in total profit on $12,587.40
in sales — a 7.02% margin and 0.02% of company profit.
Pet Shop generates $3,589.26 at 8.64% margin. Health
& Beauty generates $9,493.63 at 8.95% margin. All three
sit below the company average margin of 10.78% and
together contribute less than 0.35% of total company
profit. The supply chain complexity of maintaining
three separate department structures for this level
of commercial return warrants a formal portfolio review.

INSIGHT 7 — DISCOUNT RATE IS UNIFORM ACROSS ALL CATEGORIES
REGARDLESS OF MARGIN STRENGTH
Every top 10 category applies an average discount rate
of approximately 10.17% — identical within 0.07
percentage points across categories with meaningfully
different margin profiles. Shop By Sport (9.91% margin)
receives the same discount treatment as Cleats (11.16%
margin). This one-size-fits-all discount policy prevents
the business from using discounting as a strategic tool
to protect margins in weaker categories or drive volume
in stronger ones.

===============================================================
RECOMMENDATIONS — MODULE 7: PRODUCT CATEGORY PERFORMANCE
===============================================================

RECOMMENDATION 1 — PROTECT FISHING AT ALL COSTS
Fishing is 19.06% of company profit with the highest
per-order efficiency of any high-volume category. No
promotional, ranging, or supply chain decision should
reduce Fishing's commercial priority without a full
impact assessment showing how the profit gap would be
closed elsewhere. It should be treated as a protected
commercial asset.

RECOMMENDATION 2 — BUILD A GROWTH PLAN FOR TECHNOLOGY
AND COMPUTERS SPECIFICALLY
Computers at $157.59 average profit per order and the
Technology department at $77.25 are the most efficient
in the business. A dedicated growth initiative — expanded
product ranging, targeted B2B channel development, or
increased marketing investment — could meaningfully
increase Technology's contribution without requiring
any improvement in per-order efficiency. Doubling
Technology order volume from 1,465 to 3,000 orders
would add approximately $113,000 in profit — equivalent
to the entire Outdoors department's current contribution.

RECOMMENDATION 3 — IMPLEMENT CATEGORY-DIFFERENTIATED
DISCOUNT POLICY
The uniform ~10.17% discount rate applied across all
categories is the most likely structural cause of the
company-wide loss-making order problem. The business
should implement a category-specific discount governance
framework: higher-margin categories (Cleats at 11.16%,
Women's Apparel at 11.13%) can absorb moderate discounts;
lower-margin categories (Shop By Sport at 9.91%, Cardio
Equipment at 10.37%) should have tighter discount caps
to protect already thin margins.

RECOMMENDATION 4 — CONDUCT A FORMAL PORTFOLIO REVIEW
FOR BOOK SHOP, PET SHOP, AND HEALTH & BEAUTY
Three departments contributing less than 0.35% of total
company profit at below-average margins are consuming
supply chain capacity, warehouse space, and operational
attention. A formal review should assess whether these
departments can reach viable scale within 12–18 months
or whether the business should exit these categories
and redeploy resources toward Technology and Fishing
growth.

RECOMMENDATION 5 — ADDRESS THE GROSS PROFIT VS GROSS
LOSS IMBALANCE BEFORE EXPANDING ANY CATEGORY
The finding that Fishing destroys 49.1% of its gross
profit through loss-making orders — and that this
pattern repeats across all categories — means that
expanding any category without first fixing the
underlying loss-making order mechanism would simply
scale both profit and loss proportionally. The discount
governance recommendation (Rec 3) should be implemented
before any volume growth initiatives are launched.

===============================================================
*/


-- ============================================================
-- END OF SCRIPT — 09_product_category.sql
-- ============================================================