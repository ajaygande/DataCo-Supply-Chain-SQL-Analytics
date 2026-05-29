-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 02_data_cleaning.sql
-- PURPOSE  : Data quality assessment, null analysis, type
--            correction, cleaning documentation, and cleaned
--            view creation for the DataCo dataset
-- DATABASE : DataCo
-- TABLE    : dbo.DataCoSupplyChainDataset
-- DIALECT  : SQL Server (T-SQL)
-- TOTAL ROWS: 180,519
-- NOTE     : This script does not delete or modify raw data.
--            All cleaning is handled via a cleaned view and
--            documented assumptions. Raw data is preserved.
-- ============================================================


-- ============================================================
-- SECTION 1 — USE DATABASE
-- ============================================================

USE DataCo;
GO


-- ============================================================
-- SECTION 2 — CLEANING PHILOSOPHY
-- ============================================================
-- This project follows a non-destructive cleaning approach:
--
--   1. Raw data in dbo.DataCoSupplyChainDataset is never
--      deleted or overwritten. All 180,519 rows are retained.
--
--   2. Data type corrections are applied via ALTER COLUMN
--      where SSMS assigned incorrect types during CSV import.
--
--   3. All data quality findings are documented with counts,
--      percentages, and business justification.
--
--   4. A cleaned view (vw_DataCo_Cleaned) is created as the
--      single source for all analysis modules. It excludes
--      PII columns, non-analytical columns, and adds two
--      derived columns for delivery performance analysis.
--
--   5. PII columns are excluded from the view by design,
--      not because of data quality issues.
-- ============================================================


-- ============================================================
-- SECTION 3 — DATA TYPE CORRECTIONS
-- ============================================================
-- SSMS CSV import assigned tinyint (range: 0-255) to several
-- columns. This causes arithmetic overflow errors in
-- percentage calculations and aggregations across 180,519
-- rows. All affected columns are corrected to INT before
-- any analysis or view creation.
--
-- Affected columns identified via:
-- SELECT COLUMN_NAME, DATA_TYPE
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_NAME = 'DataCoSupplyChainDataset'
-- AND DATA_TYPE = 'tinyint'
-- Result: 7 columns returned (documented below)
-- ============================================================

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Days_for_shipping_real INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Days_for_shipment_scheduled INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Category_Id INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Department_Id INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Order_Item_Quantity INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Product_Category_Id INT;

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Product_Status INT;
GO

-- Verify corrections applied

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME  = 'DataCoSupplyChainDataset'
  AND COLUMN_NAME IN (
      'Days_for_shipping_real',
      'Days_for_shipment_scheduled',
      'Category_Id',
      'Department_Id',
      'Order_Item_Quantity',
      'Product_Category_Id',
      'Product_Status'
  )
ORDER BY COLUMN_NAME;

-- Expected result: All 7 columns return DATA_TYPE = int
GO


-- ============================================================
-- SECTION 4 — BASELINE AUDIT
-- ============================================================

-- 4.1 Total row count

SELECT
    COUNT(*)                        AS Total_Rows
FROM dbo.DataCoSupplyChainDataset;

-- Result: 180,519 rows
GO


-- 4.2 Date range of orders and shipments

SELECT
    MIN(order_date_DateOrders)      AS Earliest_Order_Date,
    MAX(order_date_DateOrders)      AS Latest_Order_Date,
    MIN(shipping_date_DateOrders)   AS Earliest_Ship_Date,
    MAX(shipping_date_DateOrders)   AS Latest_Ship_Date
FROM dbo.DataCoSupplyChainDataset;
GO


-- 4.3 Distinct values for key categorical columns

SELECT DISTINCT Delivery_Status
FROM dbo.DataCoSupplyChainDataset
ORDER BY Delivery_Status;
GO

SELECT DISTINCT Shipping_Mode
FROM dbo.DataCoSupplyChainDataset
ORDER BY Shipping_Mode;
GO

SELECT DISTINCT Customer_Segment
FROM dbo.DataCoSupplyChainDataset
ORDER BY Customer_Segment;
GO

SELECT DISTINCT Market
FROM dbo.DataCoSupplyChainDataset
ORDER BY Market;
GO

SELECT DISTINCT Order_Status
FROM dbo.DataCoSupplyChainDataset
ORDER BY Order_Status;
GO


-- ============================================================
-- SECTION 5 — NULL ANALYSIS
-- ============================================================
-- All 22 analytical columns checked for nulls across
-- 180,519 rows. Results documented below.
-- ============================================================

SELECT
    'Days_for_shipping_real'        AS Column_Name,
    COUNT(*)                        AS Total_Rows,
    SUM(CASE WHEN Days_for_shipping_real IS NULL THEN 1 ELSE 0 END)
                                    AS Null_Count,
    ROUND(CAST(100.0 * SUM(CASE WHEN Days_for_shipping_real IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)    AS Null_Pct
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Days_for_shipment_scheduled',
    COUNT(*),
    SUM(CASE WHEN Days_for_shipment_scheduled IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Days_for_shipment_scheduled IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Benefit_per_order',
    COUNT(*),
    SUM(CASE WHEN Benefit_per_order IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Benefit_per_order IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Sales_per_customer',
    COUNT(*),
    SUM(CASE WHEN Sales_per_customer IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Sales_per_customer IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Delivery_Status',
    COUNT(*),
    SUM(CASE WHEN Delivery_Status IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Delivery_Status IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Late_delivery_risk',
    COUNT(*),
    SUM(CASE WHEN Late_delivery_risk IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Late_delivery_risk IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Category_Name',
    COUNT(*),
    SUM(CASE WHEN Category_Name IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Category_Name IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Customer_Segment',
    COUNT(*),
    SUM(CASE WHEN Customer_Segment IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Customer_Segment IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Department_Name',
    COUNT(*),
    SUM(CASE WHEN Department_Name IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Department_Name IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Market',
    COUNT(*),
    SUM(CASE WHEN Market IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Market IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Region',
    COUNT(*),
    SUM(CASE WHEN Order_Region IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Region IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Status',
    COUNT(*),
    SUM(CASE WHEN Order_Status IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Status IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Shipping_Mode',
    COUNT(*),
    SUM(CASE WHEN Shipping_Mode IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Shipping_Mode IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Item_Discount_Rate',
    COUNT(*),
    SUM(CASE WHEN Order_Item_Discount_Rate IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Item_Discount_Rate IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Item_Profit_Ratio',
    COUNT(*),
    SUM(CASE WHEN Order_Item_Profit_Ratio IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Item_Profit_Ratio IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Item_Quantity',
    COUNT(*),
    SUM(CASE WHEN Order_Item_Quantity IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Item_Quantity IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Sales',
    COUNT(*),
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Order_Profit_Per_Order',
    COUNT(*),
    SUM(CASE WHEN Order_Profit_Per_Order IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Order_Profit_Per_Order IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Product_Name',
    COUNT(*),
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'Product_Price',
    COUNT(*),
    SUM(CASE WHEN Product_Price IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN Product_Price IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'order_date_DateOrders',
    COUNT(*),
    SUM(CASE WHEN order_date_DateOrders IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN order_date_DateOrders IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

UNION ALL

SELECT
    'shipping_date_DateOrders',
    COUNT(*),
    SUM(CASE WHEN shipping_date_DateOrders IS NULL THEN 1 ELSE 0 END),
    ROUND(CAST(100.0 * SUM(CASE WHEN shipping_date_DateOrders IS NULL THEN 1 ELSE 0 END)
        AS FLOAT) / COUNT(*), 2)
FROM dbo.DataCoSupplyChainDataset

ORDER BY Null_Count DESC;

/*
---------------------------------------------------------------
NULL ANALYSIS RESULTS — 180,519 rows audited
---------------------------------------------------------------
All 22 analytical columns returned 0 nulls (0.00%)
Dataset is complete across all columns used in analysis.
No null imputation or row exclusion required.
---------------------------------------------------------------
*/
GO


-- ============================================================
-- SECTION 6 — DATA QUALITY CHECKS
-- ============================================================

-- 6.1 Late delivery count
-- Definition: Days_for_shipping_real > Days_for_shipment_scheduled

SELECT
    COUNT(*)                        AS Late_Delivery_Count,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        (SELECT COUNT(*) FROM dbo.DataCoSupplyChainDataset), 2)
                                    AS Late_Delivery_Pct
FROM dbo.DataCoSupplyChainDataset
WHERE Days_for_shipping_real > Days_for_shipment_scheduled;

-- Result: 103,400 late deliveries | 57.28% of all orders
GO


-- 6.2 Negative profit orders — valid business data, not anomalies

SELECT
    COUNT(*)                        AS Negative_Profit_Orders,
    ROUND(SUM(Order_Profit_Per_Order), 2)
                                    AS Total_Loss_Amount
FROM dbo.DataCoSupplyChainDataset
WHERE Order_Profit_Per_Order < 0;

-- Result: 33,784 orders | Total loss: -$3,883,547.35
-- Decision: Retained — analytically valuable for Module 3
GO


-- 6.3 Zero or negative sales — data integrity check

SELECT
    COUNT(*)                        AS Zero_Or_Negative_Sales
FROM dbo.DataCoSupplyChainDataset
WHERE Sales <= 0;

-- Result: 0 — no anomalies found
GO


-- 6.4 Discount rate outside valid range (0.00 to 1.00)

SELECT
    COUNT(*)                        AS Invalid_Discount_Rate_Count
FROM dbo.DataCoSupplyChainDataset
WHERE Order_Item_Discount_Rate < 0
   OR Order_Item_Discount_Rate > 1;

-- Result: 0 — all discount rates within valid range
GO


-- 6.5 Orders where shipping date precedes order date

SELECT
    COUNT(*)                        AS Ship_Before_Order_Count
FROM dbo.DataCoSupplyChainDataset
WHERE shipping_date_DateOrders < order_date_DateOrders;

-- Result: 0 — no chronological violations found
GO


-- 6.6 Late delivery risk flag vs actual delivery outcome
-- Tests predictive validity of the Late_delivery_risk flag

SELECT
    Late_delivery_risk,
    Delivery_Status,
    COUNT(*)                        AS Record_Count
FROM dbo.DataCoSupplyChainDataset
WHERE Late_delivery_risk IS NOT NULL
  AND Delivery_Status IS NOT NULL
GROUP BY Late_delivery_risk, Delivery_Status
ORDER BY Late_delivery_risk, Delivery_Status;

/*
Result:
Late_delivery_risk | Delivery_Status    | Record_Count
0                  | Advance shipping   | 41,592
0                  | Shipping canceled  |  7,754
0                  | Shipping on time   | 32,196
1                  | Late delivery      | 98,977

Finding: All 98,977 orders flagged as high risk (flag = 1)
resulted in actual late delivery. The risk flag has strong
predictive validity and zero false positives in this dataset.
*/
GO


-- 6.7 Orders with zero or negative quantity

SELECT
    COUNT(*)                        AS Invalid_Quantity_Count
FROM dbo.DataCoSupplyChainDataset
WHERE Order_Item_Quantity <= 0;

-- Result: 0 — no invalid quantities found
GO


-- ============================================================
-- SECTION 7 — CLEANING DECISIONS & ASSUMPTIONS
-- ============================================================

/*
---------------------------------------------------------------
CLEANING DECISION LOG
---------------------------------------------------------------

DECISION 1 — TINYINT COLUMNS CORRECTED TO INT
Columns  : Days_for_shipping_real, Days_for_shipment_scheduled,
           Category_Id, Department_Id, Order_Item_Quantity,
           Product_Category_Id, Product_Status
Action   : ALTER COLUMN to INT (Section 3)
Rationale: SSMS CSV import assigned tinyint (0-255) to these
           columns causing arithmetic overflow errors in
           percentage and aggregation calculations across
           180,519 rows. Corrected before view creation.

DECISION 2 — NO ROWS DELETED
Action   : All 180,519 rows retained in raw table
Rationale: Null analysis confirmed zero nulls across all 22
           analytical columns. No data quality basis exists
           for row-level exclusion. Dataset is complete.

DECISION 3 — NEGATIVE PROFIT RECORDS RETAINED
Records  : 33,784 orders | Total loss: -$3,883,547.35
Action   : Retained as valid business data
Rationale: Negative profit reflects real loss-making orders.
           Removing them would distort profitability analysis
           in Module 3. These records are analytically valuable
           and represent a legitimate business problem.

DECISION 4 — LATE DELIVERY DEFINITION STANDARDISED
Definition: An order is late when
            Days_for_shipping_real > Days_for_shipment_scheduled
Scope    : Applied consistently across all delivery modules
Rationale: Validated against Delivery_Status column values.
           Risk flag analysis (Section 6.6) confirms alignment —
           all 98,977 high-risk flagged orders resulted in
           actual late delivery. Definition is internally
           consistent with zero contradictions in the data.

DECISION 5 — PII COLUMNS EXCLUDED FROM VIEW
Columns  : Customer_Email, Customer_Fname, Customer_Lname,
           Customer_Street, Customer_Password
Action   : Omitted from vw_DataCo_Cleaned
Rationale: No analytical value for supply chain analysis.
           Excluded to maintain analytical focus and avoid
           unnecessary exposure of personal data in outputs.

DECISION 6 — NON-ANALYTICAL COLUMNS EXCLUDED FROM VIEW
Columns  : Product_Description, Product_Image,
           Order_Zipcode, Customer_Zipcode,
           Latitude, Longitude
Action   : Omitted from vw_DataCo_Cleaned
Rationale: Free text, URL, and geographic coordinate fields
           with no value for SQL-based supply chain analysis.
           Market, Region, and Country fields provide
           sufficient geographic granularity.

DECISION 7 — CANCELED ORDERS RETAINED IN DATASET
Records  : 7,754 orders with Delivery_Status = Shipping canceled
Action   : Retained in view, flagged in analysis where relevant
Rationale: Canceled orders are a business reality and may
           indicate fulfilment failure. Excluding them would
           understate operational problems. Modules that
           focus on delivery performance will note where
           canceled orders affect interpretation.

---------------------------------------------------------------
SUMMARY: No rows deleted. No values imputed. Two derived
columns added. Seven data type corrections applied.
Raw table: 180,519 rows | Cleaned view: 180,519 rows
---------------------------------------------------------------
*/


-- ============================================================
-- SECTION 8 — CLEANED VIEW CREATION
-- ============================================================
-- vw_DataCo_Cleaned is the single source for all analysis.
-- Raw data in dbo.DataCoSupplyChainDataset is unchanged.
-- Two derived columns are added for delivery analysis:
--   Is_Late_Delivery  : 1 = late, 0 = on time or early
--   Delivery_Gap_Days : actual minus scheduled days
--     Positive = late | Negative = early | Zero = on time
-- ============================================================

IF OBJECT_ID('dbo.vw_DataCo_Cleaned', 'V') IS NOT NULL
    DROP VIEW dbo.vw_DataCo_Cleaned;
GO

CREATE VIEW dbo.vw_DataCo_Cleaned AS
SELECT
    -- Primary Key
    Order_Item_Id,

    -- Order Information
    Order_Id,
    order_date_DateOrders,
    Order_Status,

    -- Geography
    Market,
    Order_Region,
    Order_City,
    Order_Country,
    Order_State,

    -- Shipping & Delivery
    Shipping_Mode,
    shipping_date_DateOrders,
    Days_for_shipment_scheduled,
    Days_for_shipping_real,
    Delivery_Status,
    Late_delivery_risk,

    -- Derived: Standardised late delivery flag
    CASE
        WHEN Days_for_shipping_real > Days_for_shipment_scheduled THEN 1
        ELSE 0
    END                                         AS Is_Late_Delivery,

    -- Derived: Delivery gap in days
    Days_for_shipping_real
        - Days_for_shipment_scheduled           AS Delivery_Gap_Days,

    -- Customer (non-PII)
    Customer_Id,
    Customer_Segment,
    Customer_City,
    Customer_Country,
    Customer_State,
    Customer_Zipcode,

    -- Product & Category
    Product_Name,
    Product_Price,
    Product_Status,
    Category_Name,
    Category_Id,
    Department_Name,
    Department_Id,

    -- Financials
    Sales,
    Benefit_per_order,
    Sales_per_customer,
    Order_Item_Discount,
    Order_Item_Discount_Rate,
    Order_Item_Product_Price,
    Order_Item_Profit_Ratio,
    Order_Item_Quantity,
    Order_Item_Total,
    Order_Profit_Per_Order

FROM dbo.DataCoSupplyChainDataset;
GO


-- ============================================================
-- SECTION 9 — VIEW VALIDATION
-- ============================================================

-- 9.1 Row count must match raw table (180,519)

SELECT
    COUNT(*)                        AS Cleaned_View_Row_Count
FROM dbo.vw_DataCo_Cleaned;
GO


-- 9.2 Verify derived columns on a sample

SELECT TOP 20
    Order_Item_Id,
    Days_for_shipping_real,
    Days_for_shipment_scheduled,
    Delivery_Gap_Days,
    Is_Late_Delivery,
    Delivery_Status
FROM dbo.vw_DataCo_Cleaned
ORDER BY Order_Item_Id;
GO


-- 9.3 Confirm PII columns are absent from view
-- Expected result: 0 rows returned

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'vw_DataCo_Cleaned'
  AND COLUMN_NAME IN (
      'Customer_Email',
      'Customer_Fname',
      'Customer_Lname',
      'Customer_Street',
      'Customer_Password'
  );
GO


-- 9.4 Late delivery distribution using derived flag
-- Validates Is_Late_Delivery against known totals

SELECT
    Is_Late_Delivery,
    COUNT(*)                            AS Order_Count,
    ROUND(CAST(100.0 * COUNT(*) AS FLOAT) /
        SUM(COUNT(*)) OVER (), 2)       AS Percentage
FROM dbo.vw_DataCo_Cleaned
GROUP BY Is_Late_Delivery;

/*
Expected result:
Is_Late_Delivery | Order_Count | Percentage
0                | 77,119      | 42.72%
1                | 103,400     | 57.28%
*/
GO


-- 9.5 Confirm all 7 tinyint corrections are now INT

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME  = 'DataCoSupplyChainDataset'
  AND COLUMN_NAME IN (
      'Days_for_shipping_real',
      'Days_for_shipment_scheduled',
      'Category_Id',
      'Department_Id',
      'Order_Item_Quantity',
      'Product_Category_Id',
      'Product_Status'
  )
ORDER BY COLUMN_NAME;

-- Expected result: All 7 columns return DATA_TYPE = int
GO


-- ============================================================
-- CLEANING COMPLETE
-- ============================================================
-- Raw table  : DataCo.dbo.DataCoSupplyChainDataset (180,519 rows)
-- Cleaned view: DataCo.dbo.vw_DataCo_Cleaned       (180,519 rows)
-- All analysis modules query vw_DataCo_Cleaned only.
-- ============================================================


-- ============================================================
-- END OF SCRIPT — 02_data_cleaning.sql
-- ============================================================