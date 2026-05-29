# Business Problems & Analytical Questions
## DataCo Supply Chain Analytics — Stakeholder Problem Brief

> *This document defines the business problems, stakeholder concerns, and analytical questions that drive the DataCo Supply Chain Analytics engagement. It serves as the foundation for all SQL investigations, findings, and recommendations produced in this project.*

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [About the Dataset](#about-the-dataset)
3. [Business Problem Modules](#business-problem-modules)
   - [Module 1 — Delivery Performance & Shipping Delays](#module-1--delivery-performance--shipping-delays)
   - [Module 2 — Shipping Mode Efficiency](#module-2--shipping-mode-efficiency)
   - [Module 3 — Profitability & Margin Analysis](#module-3--profitability--margin-analysis)
   - [Module 4 — Regional Sales Imbalance](#module-4--regional-sales-imbalance)
   - [Module 5 — Delivery Risk Identification](#module-5--delivery-risk-identification)
   - [Module 6 — Customer Order Trends](#module-6--customer-order-trends)
   - [Module 7 — Product Category Performance](#module-7--product-category-performance)
4. [Analytical Scope & Assumptions](#analytical-scope--assumptions)
5. [Deliverables Overview](#deliverables-overview)

---

## Executive Summary

DataCo Global is a retail and supply chain company operating across multiple international markets, serving a diverse customer base through various shipping modes and product categories. As order volumes have grown, so too have the operational pressures — late deliveries are eroding customer trust, shipping costs are outpacing revenue in certain segments, and profitability varies dramatically across regions and product lines.

This analytics engagement investigates seven interconnected business problems using structured SQL analysis. Each problem has been framed around a real stakeholder concern, translated into precise analytical questions, and investigated against the DataCo operational dataset. The goal is not to report numbers — it is to identify what is broken, explain why, and recommend what should change.

---

## About the Dataset

| Attribute | Details |
|---|---|
| **Source** | [DataCo Smart Supply Chain Dataset — Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) |
| **Scope** | Orders, customers, products, shipping, and profitability |
| **Markets** | Africa, Europe, LATAM, Pacific Asia, USCA |
| **Key Entities** | Orders, Customers, Products, Departments, Shipping |
| **Primary Key** | `Order_Item_Id` (NOT NULL) |
| **Analysis Period** | 2015 – 2018 |

The dataset captures end-to-end supply chain activity — from customer order placement through product shipment and delivery. It includes scheduled versus actual delivery timelines, order-level profitability, product category details, geographic metadata, and customer segmentation. This makes it well-suited for operational analytics, logistics performance measurement, and commercial decision support.

---

## Business Problem Modules

---

### Module 1 — Delivery Performance & Shipping Delays

#### Business Situation

A significant portion of customer orders are arriving later than the scheduled delivery date. Frontline customer service teams are reporting increased complaint volumes, and repeat order rates in certain regions have begun to decline. Operations management suspects the problem is systemic rather than isolated, but lacks the data visibility to confirm where the breakdowns are occurring.

#### Stakeholder Concern

> *"We know deliveries are running late, but we don't know how widespread the problem is, which regions are worst affected, or whether certain shipping modes are more reliable than others. We need a clear picture before we can act."*
> — Head of Supply Chain Operations

#### Business Impact

Late deliveries directly damage customer satisfaction and retention. In competitive retail markets, a single poor delivery experience can result in customer churn. At scale, chronic delays translate into lost lifetime customer value, increased customer service costs, and reputational risk that is difficult to quantify but easy to lose.

#### Analytical Questions

1. What percentage of all orders are delivered late?
2. How does the late delivery rate vary by shipping mode?
3. Which markets and regions have the highest concentration of late deliveries?
4. What is the average gap (in days) between scheduled and actual delivery across shipping modes?
5. Are late deliveries distributed evenly across order statuses, or concentrated in specific statuses?

#### Success Metric

A clear breakdown of late delivery rates by region, shipping mode, and order status — enabling operations leadership to prioritise where intervention will have the greatest impact.

---

### Module 2 — Shipping Mode Efficiency

#### Business Situation

The company offers multiple shipping modes — Same Day, First Class, Second Class, and Standard Class. Each carries a different cost structure and delivery promise. There is a growing concern that the actual delivery performance of these modes does not consistently match what was promised to customers at the time of order, and that resource allocation across shipping modes may not be optimised.

#### Stakeholder Concern

> *"We're paying for premium shipping options and promising faster delivery, but I'm not confident we're consistently delivering on that. Are our shipping mode commitments actually being met?"*
> — Director of Logistics

#### Business Impact

Misalignment between shipping mode promises and actual delivery performance undermines customer confidence in the company's fulfilment capability. It also creates financial inefficiency — if premium shipping modes are failing at a similar rate to standard modes, the cost premium paid is not generating value.

#### Analytical Questions

1. What is the average scheduled versus actual delivery time for each shipping mode?
2. Which shipping mode has the highest on-time delivery rate?
3. Which shipping mode carries the highest volume of orders?
4. Is there a relationship between shipping mode and late delivery risk?
5. How does shipping mode performance vary across different markets?

#### Success Metric

A performance scorecard for each shipping mode, showing average delivery gap, on-time rate, order volume, and market-level variation — giving logistics leadership a factual basis for renegotiating carrier commitments or reallocating order routing.

---

### Module 3 — Profitability & Margin Analysis

#### Business Situation

Revenue figures look acceptable at the aggregate level, but finance leadership has flagged that profit margins are inconsistent and in some areas deeply negative. There is a suspicion that certain product categories, customer segments, or markets are being served at a loss — cross-subsidised by higher-performing segments without anyone having clearly identified the pattern.

#### Stakeholder Concern

> *"We're generating sales, but I'm not convinced we're generating profit in the right places. I want to know which parts of the business are genuinely profitable and which ones are quietly losing us money."*
> — Chief Financial Officer

#### Business Impact

Serving unprofitable segments at scale is a structural risk. Without visibility into where margins are negative, the business cannot make informed decisions about pricing, discount policy, product portfolio, or market prioritisation. Continued investment in loss-making segments delays profitability recovery and misallocates commercial resources.

#### Analytical Questions

1. What is the total profit, average profit per order, and average profit ratio across the dataset?
2. Which product categories generate the highest and lowest profit margins?
3. Which customer segments are most and least profitable?
4. Are there markets or regions where the business is operating at a net loss?
5. What is the relationship between discount rate and profitability — are heavy discounts eroding margins?
6. Which department contributes the most to total profit?

#### Success Metric

A profitability breakdown by category, segment, market, and discount tier — enabling finance and commercial leadership to identify where to protect margins, reduce discounting, or reconsider product and market strategy.

---

### Module 4 — Regional Sales Imbalance

#### Business Situation

The company operates across five major international markets with multiple regions within each. Sales performance data suggests that revenue and order volume are heavily concentrated in a small number of regions, while others remain persistently underperforming. Leadership wants to understand whether this reflects genuine demand differences, operational constraints, or untapped commercial opportunity.

#### Stakeholder Concern

> *"Our sales are not evenly distributed and I don't think it's purely a demand issue. Some regions might be underserved, or we may be missing an opportunity to rebalance our focus. I'd like to see where the concentration sits."*
> — VP of Commercial Strategy

#### Business Impact

Over-reliance on a small number of high-performing regions creates commercial concentration risk. If those regions experience economic disruption, the company's revenue base is disproportionately exposed. Conversely, underperforming regions may represent addressable opportunity that is currently being left unrealised.

#### Analytical Questions

1. Which markets and regions generate the highest total sales and order volume?
2. What is the revenue contribution of each market as a percentage of total sales?
3. Which regions are consistently underperforming relative to the broader market average?
4. Are there high-order-volume regions that are nevertheless generating low profit — indicating a volume-without-value problem?
5. Which customer cities generate the highest sales concentration?

#### Success Metric

A regional sales map showing revenue, order volume, and profit by market and region — identifying concentration risk and surfacing underperforming regions with actionable commercial potential.

---

### Module 5 — Delivery Risk Identification

#### Business Situation

The dataset includes a `Late_delivery_risk` flag that signals orders identified as high-risk for late delivery at the point of processing. However, the business has not systematically analysed what characteristics are associated with elevated delivery risk, nor whether risk is uniformly distributed or concentrated in specific operational segments.

#### Stakeholder Concern

> *"We have a risk flag in our system but we've never really interrogated what it's telling us. If we could understand what drives high delivery risk, we could intervene earlier and prevent late deliveries before they happen."*
> — Head of Fulfilment Operations

#### Business Impact

Reactive management of delivery failures is more expensive than proactive prevention. If the business can identify which order characteristics — shipping mode, region, order size, product type — are systematically associated with high delivery risk, it can build early intervention protocols that reduce late delivery rates without requiring significant infrastructure investment.

#### Analytical Questions

1. What proportion of orders carry a high delivery risk flag?
2. How does delivery risk vary by shipping mode?
3. Which markets and regions have the highest concentration of high-risk orders?
4. Is there a relationship between order size or sales value and delivery risk?
5. Do high-risk orders convert into actual late deliveries at a higher rate — does the risk flag have predictive validity?

#### Success Metric

A delivery risk profile that connects the risk flag to actual outcomes and identifies the order characteristics most strongly associated with late delivery — providing fulfilment operations with a practical basis for prioritising high-risk orders.

---

### Module 6 — Customer Order Trends

#### Business Situation

Customer behaviour data is embedded within the order dataset but has never been systematically analysed. The business does not have a clear picture of how order frequency, sales value, and product preferences differ across customer segments. Without this visibility, marketing and commercial decisions are made on intuition rather than evidence.

#### Stakeholder Concern

> *"We talk about our customer segments a lot, but I'm not sure we actually know how they behave differently. Who are our most valuable customers? What do they buy? How often do they order? That's the information I want."*
> — Head of Customer Strategy

#### Business Impact

Without customer-level behavioural insight, the business cannot personalise its commercial approach, prioritise retention investment, or design segment-specific promotions. High-value customers may be receiving the same experience as low-value customers, and churn signals may go undetected until it is too late to act.

#### Analytical Questions

1. How does average order value and order frequency differ across customer segments?
2. Which customer segment generates the highest total revenue and profit?
3. What are the most frequently ordered product categories by customer segment?
4. Which markets have the highest concentration of high-value customers?
5. Are there customers with unusually high order volumes or sales values that warrant individual attention?

#### Success Metric

A customer segmentation performance summary showing order frequency, average order value, preferred categories, and profitability by segment — enabling the commercial team to build data-informed segment strategies.

---

### Module 7 — Product Category Performance

#### Business Situation

The company sells products across multiple departments and categories. Some categories consistently drive high revenue and profit, while others generate volume without meaningful margin contribution. The product team lacks a structured view of category-level performance and is making ranging and promotional decisions without clear data on what is and is not working commercially.

#### Stakeholder Concern

> *"We have a wide product range but I suspect we're carrying categories that aren't pulling their weight. I'd like to know which categories are genuinely performing and which ones we should be reviewing."*
> — Head of Merchandising

#### Business Impact

An unrationalised product portfolio inflates supply chain complexity, increases warehouse and logistics costs, and dilutes commercial focus. Products that generate high revenue but low margin can mask structural inefficiency. Identifying underperforming categories creates the opportunity to streamline the portfolio, negotiate better supplier terms, or exit loss-making ranges entirely.

#### Analytical Questions

1. Which product categories generate the highest total sales and total profit?
2. Which categories have the highest and lowest average profit ratio?
3. Are there high-volume categories that are generating negative or near-zero profit?
4. Which departments are the strongest contributors to overall revenue and margin?
5. How does product category performance vary across different markets?

#### Success Metric

A product category performance matrix ranking categories by revenue, profit, margin ratio, and order volume — giving merchandising leadership a clear view of which categories to invest in, optimise, or review for rationalisation.

---

## Analytical Scope & Assumptions

### In Scope

- All order records present in the DataCo Smart Supply Chain dataset
- Analysis period: 2015 – 2018
- All five international markets: Africa, Europe, LATAM, Pacific Asia, USCA
- All shipping modes: Same Day, First Class, Second Class, Standard Class
- All customer segments: Consumer, Corporate, Home Office
- Delivery performance, profitability, sales, and customer behaviour analysis

### Out of Scope

- Real-time or live data feeds
- Predictive modelling or machine learning
- Inventory management or stock level analysis
- Supplier-side cost analysis beyond what is captured in the dataset
- Individual customer PII — customer names and emails are excluded from analytical outputs

### Data Assumptions

| Assumption | Rationale |
|---|---|
| `Order_Item_Id` is the reliable primary key | Confirmed NOT NULL; used as the grain for all order-level analysis |
| Null values in non-PK columns are treated as missing, not zero | Avoids distorting aggregations with false zero values |
| `Days_for_shipping_real` reflects actual delivery days | Used as the observed delivery timeline for performance analysis |
| `Days_for_shipment_scheduled` reflects the promised delivery days | Used as the benchmark for on-time delivery assessment |
| Late delivery is defined as `Days_for_shipping_real > Days_for_shipment_scheduled` | Consistent definition applied across all delivery performance modules |
| Profit figures are taken at the order item level | `Order_Profit_Per_Order` and `Benefit_per_order` used for profitability analysis |

---

## Deliverables Overview

| Deliverable | Description |
|---|---|
| **Schema Creation Script** | SQL script to create the DataCo database schema with appropriate data types and constraints |
| **Data Cleaning Script** | SQL script documenting cleaning steps, null handling, and data quality decisions |
| **Modular Analysis Scripts** | One SQL script per business problem module, following the 8-step analytical workflow |
| **KPI Summary** | Consolidated view of key performance indicators across all seven focus areas |
| **Findings & Recommendations Document** | Business-facing summary of what the data revealed and what actions are recommended |
| **Assumptions & Methodology** | Full documentation of analytical decisions, definitions, and limitations |
| **README** | Project navigation guide for recruiters, hiring managers, and technical reviewers |

---

*Document prepared as part of the DataCo Supply Chain Analytics portfolio project.*
*Analysis conducted using SQL on the DataCo Smart Supply Chain dataset (Kaggle).*
