# Assumptions & Methodology
## DataCo Supply Chain Analytics

> *This document records all analytical assumptions, data decisions,
> methodological choices, and known limitations applied across the
> DataCo Supply Chain Analytics engagement. It exists to ensure
> transparency, reproducibility, and honest interpretation of all
> findings presented in this project.*

---

## Table of Contents

1. [Dataset Overview](#dataset-overview)
2. [Data Preparation](#data-preparation)
3. [Analytical Definitions](#analytical-definitions)
4. [Module-Level Assumptions](#module-level-assumptions)
5. [Known Limitations](#known-limitations)
6. [Reproducibility](#reproducibility)

---

## Dataset Overview

| Attribute | Detail |
|---|---|
| **Dataset Name** | DataCo Smart Supply Chain Dataset |
| **Source** | Kaggle |
| **Total Records** | 180,519 order line items |
| **Primary Key** | Order_Item_Id (NOT NULL, enforced via ALTER TABLE) |
| **Analysis Period** | 2015 – 2018 |
| **Markets** | Africa, Europe, LATAM, Pacific Asia, USCA |
| **Shipping Modes** | Same Day, First Class, Second Class, Standard Class |
| **Customer Segments** | Consumer, Corporate, Home Office |
| **Product Categories** | 50 |
| **Departments** | 11 |
| **Import Method** | CSV import via Microsoft SQL Server (SSMS) |
| **Analysis Environment** | Microsoft SQL Server — T-SQL dialect |
| **Query Source** | DataCo.dbo.vw_DataCo_Cleaned |

---

## Data Preparation

### 2.1 Import and Schema

The dataset was imported into Microsoft SQL Server via the SSMS
CSV import wizard. The following schema corrections were required
after import and are documented in `scripts/01_schema.sql` and
`scripts/02_data_cleaning.sql`.

**Data Type Corrections**

Seven columns were imported as `tinyint` (range 0–255) by the
SSMS import wizard, causing arithmetic overflow errors in
aggregation and percentage calculations across 180,519 rows.
All seven were corrected to `INT` via `ALTER COLUMN` before
any analysis was conducted.

| Column | Imported As | Corrected To |
|---|---|---|
| Days_for_shipping_real | tinyint | INT |
| Days_for_shipment_scheduled | tinyint | INT |
| Category_Id | tinyint | INT |
| Department_Id | tinyint | INT |
| Order_Item_Quantity | tinyint | INT |
| Product_Category_Id | tinyint | INT |
| Product_Status | tinyint | INT |

**Bit Column Handling**

`Late_delivery_risk` was imported as `BIT` by SSMS. SQL Server
does not support `SUM()` on `BIT` columns. All aggregations
referencing this column use `CAST(Late_delivery_risk AS INT)`
explicitly. The column was not altered — the cast is applied
at the query level in all analysis scripts.

**Primary Key Constraint**

`Order_Item_Id` was confirmed as the primary key. A null check
(result: 0 nulls) and duplicate check (result: 0 duplicates)
were run before constraint enforcement. SSMS had already applied
a primary key during CSV import — the `ALTER TABLE ADD PRIMARY KEY`
statement in `01_schema.sql` was skipped with the constraint
documented in place.

### 2.2 Null Analysis

All 22 analytical columns were audited for null values across
180,519 rows. Result: zero nulls in every column. No imputation,
row exclusion, or null substitution was required or applied.

| Audit Result | Value |
|---|---|
| Columns audited | 22 |
| Columns with nulls | 0 |
| Rows with nulls | 0 |
| Action taken | None required |

### 2.3 Cleaned View

A non-destructive cleaning approach was applied throughout.
The raw table `DataCo.dbo.DataCoSupplyChainDataset` was never
modified, deleted from, or overwritten. All analysis queries
target the cleaned view `DataCo.dbo.vw_DataCo_Cleaned`, which:

- Excludes all PII columns
- Excludes non-analytical columns
- Adds two derived columns for delivery analysis
- Reflects all 180,519 rows from the raw table

### 2.4 PII Exclusion

The following columns contain personally identifiable information
and are excluded from all analytical queries, outputs, and
findings documentation:

| Column | Reason for Exclusion |
|---|---|
| Customer_Email | Personal contact information |
| Customer_Fname | Personal identifier |
| Customer_Lname | Personal identifier |
| Customer_Street | Personal address |
| Customer_Password | Sensitive credential — excluded unconditionally |

---

## Analytical Definitions

The following definitions are applied consistently across all
seven analytical modules. Any deviation at the module level
is documented in Section 4.

### Late Delivery
An order is classified as late when actual shipping days
exceed scheduled shipping days:
Is_Late_Delivery = 1
WHERE Days_for_shipping_real > Days_for_shipment_scheduled

This definition is consistent with the `Delivery_Status`
column values and validated against the `Late_delivery_risk`
flag in Module 5.

### Delivery Gap
The delivery gap measures the difference in days between
actual and scheduled delivery. Positive values indicate
late delivery. Negative values indicate early delivery.
Zero indicates exact on-time delivery.
Delivery_Gap_Days = Days_for_shipping_real - Days_for_shipment_scheduled

### Profit Margin
Profit margin is calculated at the order item level as
total profit divided by total sales for a given group: Profit_Margin_Pct = (SUM(Order_Profit_Per_Order) /
SUM(Sales)) * 100

### Loss-Making Order
An order is classified as loss-making when order profit
is negative:Order_Profit_Per_Order < 0
Loss-making orders are retained in all analysis as valid
business data. They are not excluded or treated as anomalies.

### Average Orders Per Customer
Calculated as total order line items divided by distinct
customer IDs within the group being analysed:Avg_Orders_Per_Customer = COUNT(*) / COUNT(DISTINCT Customer_Id)

### High Delivery Risk
An order is classified as high delivery risk when the
`Late_delivery_risk` flag equals 1, as recorded in the
source dataset. This flag is not derived — it is a
pre-existing field in the raw data.

### On-Time Delivery
An order is classified as on time when actual shipping
days do not exceed scheduled shipping days:
Is_Late_Delivery = 0
WHERE Days_for_shipping_real <= Days_for_shipment_scheduled

This includes orders delivered exactly on schedule
(gap = 0) and orders delivered ahead of schedule (gap < 0).

---

## Module-Level Assumptions

### Module 1 — Delivery Performance

- Late delivery is defined consistently as
  `Days_for_shipping_real > Days_for_shipment_scheduled`
  across all queries in this module.
- Canceled orders (`Delivery_Status = Shipping canceled`)
  are retained in all counts and percentage calculations.
  They are flagged where their presence affects
  interpretation.
- The 2018 data point (2,123 orders) is treated as a
  partial year sample and noted as unreliable for
  year-over-year trend conclusions.

### Module 2 — Shipping Mode Efficiency

- The First Class 100% late delivery rate with a
  perfectly consistent 1-day gap is interpreted as
  a scheduling misconfiguration rather than carrier
  failure based on the zero-variance pattern across
  all markets and all years. This interpretation is
  stated as the most likely explanation — it has not
  been confirmed with system configuration data.
- Average delivery gap calculations include both late
  and on-time orders. Where late-only averages are
  presented, this is noted explicitly in the query
  comments.

### Module 3 — Profitability & Margin Analysis

- Profit is measured at the order item level using
  `Order_Profit_Per_Order`. This field reflects the
  profit recorded per order line item in the source
  dataset.
- Negative profit records are retained as valid
  business data representing genuine loss-making
  orders. They are not treated as data errors.
- The discount rate tiers used in Section 7 are
  defined as analytical groupings for this project.
  They do not necessarily reflect internal DataCo
  discount policy categories.

### Module 4 — Regional Sales Imbalance

- The Caguas, Puerto Rico concentration (37% of total
  sales from a single city) is flagged as a probable
  data recording anomaly — either a default billing
  address or a system fallback — rather than genuine
  customer demand. This interpretation is stated as
  the most likely explanation and has not been
  confirmed with source system data.
- City-level analysis is presented with the Caguas
  caveat clearly noted. Regional and market-level
  analysis is not materially affected by the Caguas
  anomaly as it aggregates above city level.
- Year-over-year market analysis is noted as
  unreliable due to uneven year coverage per market
  in the dataset. Missing years are treated as data
  gaps, not zero-sales periods.

### Module 5 — Delivery Risk Identification

- The `Late_delivery_risk` flag is a pre-existing
  field in the source dataset. Its calculation logic
  is not documented in the dataset metadata.
- The perfect predictive alignment between the risk
  flag and actual delivery outcomes (100% precision,
  100% recall, zero exceptions) leads to the
  interpretation that the flag is derived from the
  same scheduling calculation that determines
  `Is_Late_Delivery` — not from independent
  operational signals. This interpretation is
  analytically supported but not confirmed with
  source system documentation.
- The precision and recall calculation in Section 8
  treats canceled orders (flag = 0, Is_Late_Delivery
  = 0) as true negatives. This is methodologically
  consistent with the binary classification framework
  applied.

### Module 6 — Customer Order Trends

- Customer identity is based on `Customer_Id` as
  recorded in the dataset. No deduplication or
  identity resolution was performed beyond what
  exists in the source data.
- The top customer analysis (Section 6) is presented
  with the Caguas caveat. 6 of the top 10 customers
  by sales are from Caguas and should be interpreted
  with caution until the data anomaly is resolved.
- The 2017 average order value increase (~$25 across
  all segments simultaneously) is interpreted as a
  company-wide pricing or product mix event rather
  than segment-specific behaviour. This is based on
  the uniformity of the increase across segments —
  the specific cause has not been confirmed.
- Lifetime customer value calculations are based on
  order history within the 2015–2018 dataset period
  only. They do not reflect customer history outside
  this period.

### Module 7 — Product Category Performance

- Category assignment is taken directly from the
  `Category_Name` field as recorded in the source
  dataset. No recategorisation or reclassification
  was applied.
- The gross profit vs gross loss analysis in Section
  8 separates profitable and loss-making orders
  within each category to show the two-sided nature
  of category performance. Net profit is the residual
  between these two figures.
- The category efficiency matrix in Section 9 uses
  `RANK()` window functions to score categories on
  sales volume and profit margin simultaneously.
  Tied ranks are assigned the same rank value.
- The uniform discount rate finding (~10.17% across
  all top categories) is based on `AVG
  (Order_Item_Discount_Rate)`. It reflects the
  average applied rate, not a stated policy rate.

---

## Known Limitations

### L1 — Partial Year 2018 Data
The dataset contains only 2,123 orders in 2018 — 1.18%
of total records. Year-over-year comparisons involving
2018 should be treated as indicative only. The sharp
drop in average order value observed in 2018 across all
segments is likely a small-sample artefact rather than
a genuine trend signal.

### L2 — Uneven Year Coverage Per Market
Several markets show data gaps in specific years —
Africa has no 2015 records, LATAM has no 2016 records,
USCA has only 118 orders in 2017. These gaps prevent
reliable year-over-year trend analysis at the market
level. They are documented in Module 4 and noted
wherever year-over-year market comparisons appear.

### L3 — Caguas, Puerto Rico Data Anomaly
66,770 orders (37% of total) are attributed to Caguas,
Puerto Rico in the customer city field. This extreme
concentration is almost certainly a data recording
issue. All city-level analysis and individual customer
analysis should be treated with caution until this
is investigated and resolved by the data governance team.

### L4 — No External Benchmarking
All findings are measured against internal dataset
averages. No external industry benchmarks — such as
average supply chain on-time delivery rates, retail
profit margins, or e-commerce return rates — were
incorporated. Findings should be contextualised
against industry standards before operational
decisions are made.

### L5 — Delivery Risk Flag Logic Unknown
The `Late_delivery_risk` flag calculation logic is
not documented in the dataset metadata. The
interpretation that it is derived from scheduling
logic is analytically supported by the data but
has not been confirmed with source system
documentation. Module 5 findings should be
reviewed against the actual flag calculation
methodology before operational conclusions are acted on.

### L6 — No Cost Data Beyond Order Profit
The dataset captures `Order_Profit_Per_Order` as a
single field without breakdowns into cost of goods,
shipping costs, fulfilment costs, or overhead
allocation. Profitability analysis is limited to
the profit figure as recorded. True operational
profitability — accounting for all cost components
— may differ from the figures presented.

### L7 — Single Dataset Period
The analysis covers 2015–2018 only. No data exists
before or after this period within the dataset.
Trends identified may not reflect the current
operational state of the business and should be
validated against more recent data before strategic
decisions are made.

### L8 — Customer Identity Reliability
Customer identity is based on `Customer_Id` as
recorded in the source system. No identity
resolution was performed. If the source system
has duplicate customer records or shared IDs,
customer-level aggregations may be inaccurate.
This is particularly relevant given the Caguas
anomaly which may affect customer record integrity.

---

## Reproducibility

All analysis in this project is fully reproducible
from the source dataset using the scripts provided
in this repository.

### Reproduction Steps

1. Download the DataCo Smart Supply Chain dataset
   from Kaggle (see `/data/README.md` for the link)
2. Import the CSV into Microsoft SQL Server using
   the SSMS import wizard
3. Run `scripts/01_schema.sql` to enforce constraints
   and document the schema
4. Run `scripts/02_data_cleaning.sql` to apply data
   type corrections and create `vw_DataCo_Cleaned`
5. Run analysis scripts in order:
   `03_delivery_performance.sql` through
   `09_product_category.sql`
6. All query results should match the documented
   outputs in the findings section of each script

### Environment

| Component | Detail |
|---|---|
| Database | Microsoft SQL Server |
| Client | SQL Server Management Studio (SSMS) |
| SQL Dialect | T-SQL |
| Dataset | DataCo Smart Supply Chain (Kaggle) |
| Raw Table | DataCo.dbo.DataCoSupplyChainDataset |
| Cleaned View | DataCo.dbo.vw_DataCo_Cleaned |
| Total Rows | 180,519 |

### Script Execution Order

| Order | Script | Purpose |
|---|---|---|
| 1 | `scripts/01_schema.sql` | Schema documentation and constraint enforcement |
| 2 | `scripts/02_data_cleaning.sql` | Data type corrections, null audit, view creation |
| 3 | `scripts/analysis/03_delivery_performance.sql` | Module 1 analysis |
| 4 | `scripts/analysis/04_shipping_mode_efficiency.sql` | Module 2 analysis |
| 5 | `scripts/analysis/05_profitability_analysis.sql` | Module 3 analysis |
| 6 | `scripts/analysis/06_regional_sales.sql` | Module 4 analysis |
| 7 | `scripts/analysis/07_delivery_risk.sql` | Module 5 analysis |
| 8 | `scripts/analysis/08_customer_trends.sql` | Module 6 analysis |
| 9 | `scripts/analysis/09_product_category.sql` | Module 7 analysis |

---

*This document should be updated if the dataset, environment,
or analytical definitions change in future iterations of this project.*

*Last updated: May 2026*
*Project: DataCo-Supply-Chain-SQL-Analytics*
