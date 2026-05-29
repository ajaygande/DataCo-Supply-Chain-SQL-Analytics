-- ============================================================
-- PROJECT  : DataCo Supply Chain SQL Analytics
-- FILE     : 01_schema.sql
-- PURPOSE  : Schema documentation, data type reference, and
--            constraint enforcement for the DataCo dataset
-- DATABASE : DataCo
-- TABLE    : dbo.DataCoSupplyChainDataset
-- DIALECT  : SQL Server (T-SQL)
-- NOTE     : Table was imported via CSV. This script documents
--            the intended schema and enforces the primary key
--            constraint on Order_Item_Id.
-- ============================================================


-- ============================================================
-- SECTION 1 — USE DATABASE
-- ============================================================

USE DataCo;
GO


-- ============================================================
-- SECTION 2 — SCHEMA REFERENCE
-- ============================================================
-- This section documents the full intended schema for the
-- DataCoSupplyChainDataset table. It serves as the source of
-- truth for column names, data types, nullability, and the
-- business meaning of each field.
--
-- When importing via CSV in SSMS, SQL Server may assign
-- incorrect data types (e.g. NVARCHAR for numeric columns).
-- Refer to this reference when auditing or correcting types.
-- ============================================================

/*
-------------------------------------------------------------
COLUMN REFERENCE — dbo.DataCoSupplyChainDataset
-------------------------------------------------------------

COLUMN NAME                     DATA TYPE           NULLABLE    DESCRIPTION
------------------------------  ------------------  --------    ------------------------------------------
Order_Item_Id                   INT                 NOT NULL    Primary key. Unique identifier per order line item.
Days_for_shipping_real          INT                 NULL        Actual number of days taken to ship the order.
Days_for_shipment_scheduled     INT                 NULL        Scheduled/promised number of days for shipment.
Benefit_per_order               DECIMAL(18,2)       NULL        Benefit amount generated per order.
Sales_per_customer              DECIMAL(18,2)       NULL        Total sales value attributed to the customer.
Delivery_Status                 NVARCHAR(50)        NULL        Delivery outcome (e.g. Late delivery, Advance shipping).
Late_delivery_risk              INT                 NULL        Binary flag: 1 = high risk of late delivery, 0 = low risk.
Category_Id                     INT                 NULL        Numeric identifier for the product category.
Category_Name                   NVARCHAR(100)       NULL        Name of the product category.
Customer_City                   NVARCHAR(100)       NULL        City of the customer.
Customer_Country                NVARCHAR(100)       NULL        Country of the customer.
Customer_Email                  NVARCHAR(150)       NULL        Email address of the customer (excluded from analysis outputs).
Customer_Fname                  NVARCHAR(100)       NULL        First name of the customer (excluded from analysis outputs).
Customer_Id                     INT                 NULL        Unique identifier for the customer.
Customer_Lname                  NVARCHAR(100)       NULL        Last name of the customer (excluded from analysis outputs).
Customer_Password               NVARCHAR(255)       NULL        Customer password hash (excluded from all analysis — PII).
Customer_Segment                NVARCHAR(50)        NULL        Customer segment (Consumer, Corporate, Home Office).
Customer_State                  NVARCHAR(100)       NULL        State of the customer.
Customer_Street                 NVARCHAR(255)       NULL        Street address of the customer (excluded from analysis outputs).
Customer_Zipcode                NVARCHAR(20)        NULL        Zip/postal code of the customer.
Department_Id                   INT                 NULL        Numeric identifier for the department.
Department_Name                 NVARCHAR(100)       NULL        Name of the department.
Latitude                        DECIMAL(10,6)       NULL        Latitude coordinate of the order location.
Longitude                       DECIMAL(10,6)       NULL        Longitude coordinate of the order location.
Market                          NVARCHAR(50)        NULL        Market region (Africa, Europe, LATAM, Pacific Asia, USCA).
Order_City                      NVARCHAR(100)       NULL        City where the order was placed.
Order_Country                   NVARCHAR(100)       NULL        Country where the order was placed.
Order_Customer_Id               INT                 NULL        Customer ID linked to the order (foreign reference).
order_date_DateOrders           DATETIME            NULL        Date and time the order was placed.
Order_Id                        INT                 NULL        Unique identifier for the order.
Order_Item_Cardprod_Id          INT                 NULL        Card product identifier linked to the order item.
Order_Item_Discount             DECIMAL(18,2)       NULL        Discount amount applied to the order item.
Order_Item_Discount_Rate        DECIMAL(5,4)        NULL        Discount rate applied (0.00 to 1.00).
Order_Item_Product_Price        DECIMAL(18,2)       NULL        Original listed price of the product on the order item.
Order_Item_Profit_Ratio         DECIMAL(5,4)        NULL        Profit ratio at the order item level (0.00 to 1.00).
Order_Item_Quantity             INT                 NULL        Quantity of the product ordered.
Sales                           DECIMAL(18,2)       NULL        Total sales value for the order item.
Order_Item_Total                DECIMAL(18,2)       NULL        Total value of the order item after discount.
Order_Profit_Per_Order          DECIMAL(18,2)       NULL        Total profit generated by the order.
Order_Region                    NVARCHAR(100)       NULL        Region where the order was placed.
Order_State                     NVARCHAR(100)       NULL        State where the order was placed.
Order_Status                    NVARCHAR(50)        NULL        Current status of the order (e.g. COMPLETE, PENDING, CANCELED).
Order_Zipcode                   NVARCHAR(20)        NULL        Zip/postal code of the order location.
Product_Card_Id                 INT                 NULL        Card product identifier linked to the product.
Product_Category_Id             INT                 NULL        Category identifier linked to the product.
Product_Description             NVARCHAR(MAX)       NULL        Full text description of the product.
Product_Image                   NVARCHAR(500)       NULL        URL or path to the product image.
Product_Name                    NVARCHAR(255)       NULL        Name of the product.
Product_Price                   DECIMAL(18,2)       NULL        Listed price of the product.
Product_Status                  INT                 NULL        Status flag for the product (0 = inactive, 1 = active).
shipping_date_DateOrders        DATETIME            NULL        Date and time the order was shipped.
Shipping_Mode                   NVARCHAR(50)        NULL        Shipping method used (Same Day, First Class, Second Class, Standard Class).

-------------------------------------------------------------
TOTAL COLUMNS : 53
PRIMARY KEY   : Order_Item_Id (NOT NULL)
-------------------------------------------------------------
*/


-- ============================================================
-- SECTION 3 — CONSTRAINT ENFORCEMENT
-- ============================================================
-- The CSV import does not enforce constraints. This section
-- enforces the NOT NULL constraint and PRIMARY KEY on
-- Order_Item_Id to ensure data integrity for all analysis.
-- ============================================================

-- Step 1: Verify there are no NULL values in Order_Item_Id
-- before enforcing the constraint. Run this first.

SELECT
    COUNT(*) AS Null_Order_Item_Id_Count
FROM dbo.DataCoSupplyChainDataset
WHERE Order_Item_Id IS NULL;

-- Expected result: 0
-- If result > 0, investigate before proceeding.
GO


-- Step 2: Verify there are no duplicate values in Order_Item_Id
-- before enforcing the PRIMARY KEY constraint.

SELECT
    Order_Item_Id,
    COUNT(*) AS Duplicate_Count
FROM dbo.DataCoSupplyChainDataset
GROUP BY Order_Item_Id
HAVING COUNT(*) > 1;

-- Expected result: 0 rows returned
-- If duplicates exist, investigate before proceeding.
GO


-- Step 3: Enforce NOT NULL on Order_Item_Id

ALTER TABLE dbo.DataCoSupplyChainDataset
ALTER COLUMN Order_Item_Id INT NOT NULL;
GO


-- Step 4: Primary key already exists from CSV import.
-- Verified via INFORMATION_SCHEMA check in Section 4.3.
-- No action required.

-- ALTER TABLE dbo.DataCoSupplyChainDataset
-- ADD CONSTRAINT PK_DataCo_OrderItemId PRIMARY KEY (Order_Item_Id);

-- ============================================================
-- SECTION 4 — SCHEMA VALIDATION CHECKS
-- ============================================================
-- Run these checks after constraint enforcement to confirm
-- the table is correctly structured for analysis.
-- ============================================================

-- 4.1 Confirm total row count

SELECT
    COUNT(*) AS Total_Rows
FROM dbo.DataCoSupplyChainDataset;
GO


-- 4.2 Confirm column count and data types as imported
-- Use this to compare against the schema reference above
-- and identify columns that may need type correction.

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DataCoSupplyChainDataset'
ORDER BY ORDINAL_POSITION;
GO


-- 4.3 Confirm PRIMARY KEY constraint is in place

SELECT
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'DataCoSupplyChainDataset'
  AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';
GO


-- 4.4 Preview first 10 rows to confirm data loaded correctly

SELECT TOP 10 *
FROM dbo.DataCoSupplyChainDataset;
GO


-- ============================================================
-- SECTION 5 — PII COLUMN NOTE
-- ============================================================
-- The following columns contain personally identifiable
-- information (PII) and are excluded from all analytical
-- queries in this project:
--
--   Customer_Email
--   Customer_Fname
--   Customer_Lname
--   Customer_Street
--   Customer_Password
--
-- These columns remain in the table but will not appear
-- in any SELECT statements across the analysis scripts.
-- ============================================================


-- ============================================================
-- END OF SCRIPT — 01_schema.sql
-- ============================================================