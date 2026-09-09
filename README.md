# ☕ Coffee Shop Financial & Theoretical COGS Profitability Analysis

An end-to-end data analytics project modeling theoretical COGS, item-level margins, and store profitability using SQL Server and Tableau.

---

## 📊 Executive Dashboard Preview

![Dashboard Preview](Dashboard%20Preview.png)

---

## 📌 Business Overview & Problem Statement
Coffee shop management needed clear visibility into real item-level margins. Standard sales software recorded gross revenue, but obscured product profitability because retail pricing did not account for granular ingredient unit costs across recipes.

### Key Objectives
- Build a relational data model bridging raw ingredient unit costs with daily customer transactions.
- Calculate **Theoretical COGS** (ideal cost based on standard recipe specs, excluding spillage/waste) and gross profit margins.
- Deliver an interactive Tableau dashboard for executive performance tracking.

---

## 🛠️ Tools & Repository Files
- `Coffee Shop Query.sql`: Multi-table JOINs, CTEs, and aggregation logic written in SQL Server (SSMS).
- `CoffeeShop.xlsx`: Relational dataset containing orders, menu items, recipes, and ingredient costs.
- `Dashboard Preview.png`: High-resolution preview of the interactive Tableau Public executive dashboard.

---

## 📐 SQL Methodology & Logic
sql
```
With item_raw_cogs as (
	Select 
	i.item_id,
	i.sku,
	i.item_name,
	i.item_cat,
	i.item_price,
	SUM((ing.ing_price / ing.ing_weight) * r.quantity) as item_raw_cogs
From items as i
join recipes as r on i.sku = r.recipe_id
join ingredients as ing on r.ing_id = ing.ing_id
Group by
	i.item_id,
	i.sku,
	i.item_name,
	i.item_cat,
	i.item_price)

SELECT 
	CAST(o.created_at AS DATE) AS order_date,
    c.item_name,
    c.item_cat,
    c.item_price,
    c.item_raw_cogs,
    
    -- Unit Profitability
    (c.item_price - c.item_raw_cogs) AS unit_gross_profit,
    ((c.item_price - c.item_raw_cogs) / c.item_price) * 100 AS unit_margin_percent,

    -- Total Profitability
    SUM(o.quantity) AS total_orders,
    SUM(o.quantity) * c.item_price AS total_revenue,
    SUM(o.quantity) * c.item_raw_cogs AS total_cogs,
    SUM(o.quantity) * (c.item_price - c.item_raw_cogs) AS total_gross_profit

FROM orders AS o
JOIN item_raw_cogs AS c ON o.item_id = c.item_id
GROUP BY 
	CAST(o.created_at AS DATE),
    c.item_name, 
    c.item_cat, 
    c.item_price, 
    c.item_raw_cogs;
```
---

## 💡 Key Insights & Business Recommendations
- **Overall Gross Margin:** **88%** across 466 transactions (£1,621.58 gross profit on £1,857.45 revenue).
- **High-Margin Drivers:** Cold Beverages and specialty Mochas yield the highest profit margins due to low liquid ingredient unit costs relative to retail pricing.
- **Operational Value:** Serves as the **Theoretical COGS** benchmark to evaluate future physical inventory audits and quantify variance from waste or spillage.
