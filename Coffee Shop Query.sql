-- ==================================================================================================
-- COFEE SHOP COGS & PROFITABILITY ANALYSIS
-- Goal: Calculate unit-level Cost of Goods Sold (COGS) by mapping ingredient recipes to menu items.
-- ==================================================================================================

-- -------------------------------------------------------------------------------------------------- 
-- Data Ingestion & Relational Modeling
-- Objective: Join orders, items, recipes, and ingredients.
-- --------------------------------------------------------------------------------------------------
Select
	o.order_id,
	o.created_at,
	i.item_cat,
	i.item_name,
	i.item_price,
	o.quantity as order_qty,
	ing.ing_name,
	r.quantity as recipe_qty,
	ing.ing_weight,
	ing.ing_meas,
	ing.ing_price
From orders as o
join items as i on o.item_id = i.item_id
join recipes as r on i.sku = r.recipe_id
join ingredients as ing on r.ing_id = ing.ing_id;

-- -------------------------------------------------------------------------------------------------- 
-- Item-Level COGS Calculation
-- Objective: Compute the exact raw ingredient cost per menu item.
-- --------------------------------------------------------------------------------------------------
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
	i.item_price;

-- -------------------------------------------------------------------------------------------------- 
-- Margin & Profitability Analysis
-- Objective: Calculate Unit and Total Gross Profit and Gross Profit Margin %.
-- --------------------------------------------------------------------------------------------------
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