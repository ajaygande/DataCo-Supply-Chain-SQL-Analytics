# DataCo Supply Chain SQL Analytics
### Solving Business Problems with SQL

> *A professional SQL portfolio project simulating a real-world
> business analytics engagement for a global supply chain and
> retail company. Every query investigates a genuine business
> problem. Every finding drives a specific recommendation.*

---

## What This Project Is

DataCo Supply Chain Analytics is a structured, end-to-end SQL
analysis of 180,519 orders from a global retail and supply chain
operation spanning five international markets and four years
(2015–2018).

This project does not demonstrate SQL syntax. It demonstrates
how SQL is used to solve real business problems — translating
stakeholder concerns into analytical questions, investigating
operational data, surfacing non-obvious insights, and producing
actionable recommendations that support business decision-making.

The analysis follows the same workflow a real analytics team
would use:     Business Situation → Stakeholder Concern → Business Impact
→ Analytical Questions → SQL Investigation → Findings
→ Business Insights → Recommendations
---

## Business Problems Investigated

| Module | Business Problem | Key Finding |
|---|---|---|
| 1 | Delivery Performance & Shipping Delays | 57.28% of all orders arrive late — unchanged for 4 years |
| 2 | Shipping Mode Efficiency | First Class shipping has a 100% late delivery rate |
| 3 | Profitability & Margin Analysis | Gross losses are 97.89% of total profit — the business is fragile |
| 4 | Regional Sales Imbalance | 37% of total sales come from a single city — a data anomaly |
| 5 | Delivery Risk Identification | The risk flag is a perfect predictor with no intervention value |
| 6 | Customer Order Trends | Three segments exist as labels — all behave identically |
| 7 | Product Category Performance | Every category carries loss-making orders — a structural problem |

---

## Key Business Metrics

| Metric | Value |
|---|---|
| Total Orders Analysed | 180,519 |
| Total Revenue | $36,784,735.01 |
| Total Profit | $3,966,902.97 |
| Overall Profit Margin | 10.78% |
| Late Delivery Rate | 57.28% |
| Loss-Making Orders | 33,784 (18.71%) |
| Total Gross Loss | $3,883,547.35 |
| Gross Loss as % of Profit | 97.89% |
| Markets | 5 |
| Regions | 23 |
| Product Categories | 50 |
| Customer Segments | 3 |
| Analysis Period | 2015 – 2018 |

---

## Top 5 Recommendations

| Priority | Recommendation | Expected Impact |
|---|---|---|
| 1 | Fix First Class scheduling configuration | Reduce late delivery rate from 57.28% to ~42% immediately |
| 2 | Implement category-differentiated discount policy | Reduce loss-making order rate below 18.71% |
| 3 | Investigate and resolve Caguas data anomaly | Restore integrity of all geographic and customer reporting |
| 4 | Build a Technology volume growth plan | Add ~$113K profit per 1,500 additional orders |
| 5 | Redesign customer segmentation around behaviour | Enable targeted strategy across 20,652 customers |

---

## Tech Stack

| Component | Detail |
|---|---|
| Language | SQL — T-SQL dialect |
| Database | Microsoft SQL Server |
| Client | SQL Server Management Studio (SSMS) |
| Dataset | DataCo Smart Supply Chain (Kaggle) |
| Documentation | Markdown |

---

## Repository Structure
DataCo-Supply-Chain-SQL-Analytics/
│
├── README.md                             ← You are here
│
├── data/
│   └── README.md                         ← Dataset source, column reference,
│                                           import instructions
│
├── docs/
│   ├── business_problems.md              ← Stakeholder problem brief —
│   │                                       business situations, concerns,
│   │                                       impact, and analytical questions
│   └── assumptions_methodology.md        ← All analytical definitions,
│                                           data decisions, and known
│                                           limitations
│
├── scripts/
│   ├── 01_schema.sql                     ← Schema documentation and
│   │                                       constraint enforcement
│   ├── 02_data_cleaning.sql              ← Data type corrections, null
│   │                                       audit, cleaned view creation
│   └── analysis/
│       ├── 03_delivery_performance.sql   ← Module 1
│       ├── 04_shipping_mode_efficiency.sql ← Module 2
│       ├── 05_profitability_analysis.sql ← Module 3
│       ├── 06_regional_sales.sql         ← Module 4
│       ├── 07_delivery_risk.sql          ← Module 5
│       ├── 08_customer_trends.sql        ← Module 6
│       └── 09_product_category.sql       ← Module 7
│
└── findings/
├── kpi_summary.md                    ← Consolidated KPIs across
│                                       all seven modules
└── recommendations.md               ← Full findings and prioritised
recommendations
---

## How to Navigate This Project

**If you want to understand the business problems:**
Start with [`docs/business_problems.md`](docs/business_problems.md).
This document defines every stakeholder concern, business impact,
and analytical question before a single query is written.

**If you want to see the SQL analysis:**
Go to [`scripts/analysis/`](scripts/analysis/). Each script
is self-contained — it opens with the business context, works
through the analytical questions, documents the real query
outputs, and closes with business insights and recommendations.
Scripts are numbered and can be read in any order.

**If you want the findings and recommendations:**
Go to [`findings/recommendations.md`](findings/recommendations.md).
This is the business-facing deliverable — a complete findings
and recommendations document written for operations leadership
and senior management.

**If you want the headline numbers:**
Go to [`findings/kpi_summary.md`](findings/kpi_summary.md).
This document consolidates every key metric across all seven
modules in one place.

**If you want to reproduce the analysis:**
Go to [`data/README.md`](data/README.md) for dataset download
instructions, then run the scripts in order starting from
`scripts/01_schema.sql`.

---

## How to Reproduce This Analysis

### Prerequisites
- Microsoft SQL Server (any recent version)
- SQL Server Management Studio (SSMS)
- A free Kaggle account to download the dataset

### Steps

**1. Get the dataset**

Download the DataCo Smart Supply Chain dataset from Kaggle: https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis

**2. Import into SQL Server**

- Open SSMS and connect to your SQL Server instance
- Create a new database named `DataCo`
- Use the SSMS import wizard to import `DataCoSupplyChain.csv`
- Name the table `DataCoSupplyChainDataset`

**3. Run the schema script**
scripts/01_schema.sql
Enforces the primary key constraint on `Order_Item_Id` and
documents the full schema with correct data types.

**4. Run the cleaning script**
scripts/02_data_cleaning.sql
Corrects data type issues from CSV import, audits data quality,
and creates the cleaned view `vw_DataCo_Cleaned` used by all
analysis scripts.

**5. Run the analysis scripts**
scripts/analysis/03_delivery_performance.sql
scripts/analysis/04_shipping_mode_efficiency.sql
scripts/analysis/05_profitability_analysis.sql
scripts/analysis/06_regional_sales.sql
scripts/analysis/07_delivery_risk.sql
scripts/analysis/08_customer_trends.sql
scripts/analysis/09_product_category.sql

Each script is self-contained and can be run independently
after the cleaning script has been executed.

---

## Analytical Approach

This project treats SQL as a business decision-making tool,
not a technical exercise. Each analysis module follows a
structured eight-step workflow:

**1. Business Situation**
What is happening in the business that prompted this investigation?

**2. Stakeholder Concern**
Who is worried, what specifically are they asking, and what
decision are they trying to make?

**3. Business Impact**
What does this problem cost the business in revenue, efficiency,
customer trust, or competitive position?

**4. Analytical Questions**
What specific questions does the data need to answer to address
the stakeholder concern?

**5. SQL Investigation**
Structured queries that answer each analytical question with
documented results embedded directly in the script.

**6. Findings**
What did the data reveal? Stated as specific, numbered findings
grounded in actual query outputs.

**7. Business Insights**
What does this mean for the business? Findings interpreted in
commercial context — not just what the numbers say but what
they imply.

**8. Recommendations**
What should the business do? Specific, prioritised, actionable
recommendations tied directly to the findings.

---

## Selected Insights

**Delivery is broken and has been for four years**
57.28% of all orders arrive late. This rate held flat at
57.21%–57.30% from 2015 through 2017. The business has not
moved the needle on delivery performance at all despite the
problem affecting the majority of its customer base.

**The most expensive shipping option fails every single order**
First Class shipping has a 100% late delivery rate across
27,814 orders, 5 markets, and 4 consecutive years with a
perfectly consistent 1-day gap. This is not a carrier
performance failure — it is almost certainly a scheduling
misconfiguration that can be fixed without any logistics
investment.

**The business is one bad quarter away from aggregate loss**
Total gross losses of $3,883,547.35 are 97.89% of total
profit of $3,966,902.97. A uniform ~10.17% discount rate
is applied across all 50 product categories — creating
loss-making orders in every single category in the portfolio.

**The highest-profit category per order is barely being sold**
Computers average $157.59 profit per order — 7.2 times the
company average — on just 442 orders. The Technology
department generates $77.25 average profit per order on
1,465 orders — less than 1% of total order volume. The
business's most efficient category is its most overlooked.

**Three customer segments, one customer profile**
Consumer, Corporate, and Home Office segments show
near-identical order frequency, average order value,
profit per order, product preferences, and market
distribution. The segmentation exists as a label
but has no commercial foundation.

---

## Dataset

**DataCo Smart Supply Chain Dataset**
Source: Kaggle
URL: https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis

The raw CSV is not included in this repository due to file
size. See [`data/README.md`](data/README.md) for full
download and import instructions.

---

## Author

**Ajay Gande**
[GitHub](https://github.com/ajaygande) |
[LinkedIn](https://linkedin.com/in/ajaygande) | 
[Email](ajaygande1@gmail.com)

---

*DataCo Supply Chain SQL Analytics — a business analytics
case study built entirely in SQL.*
