-- Reading CSV files inta SQL database

-- Reading datasets
Select *
FROM pos_sales_data;

Select *
From product_master;

Select *
From promo_trade_data;

-- Checking sales table for missing or null data
SELECT 
    SUM(CASE WHEN week IS NULL THEN 1 ELSE 0 END)          AS null_week,
    SUM(CASE WHEN retailer IS NULL THEN 1 ELSE 0 END)      AS null_retailer,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END)        AS null_region,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)    AS null_product_id,
    SUM(CASE WHEN pack_size_oz IS NULL THEN 1 ELSE 0 END)  AS null_pack_size_oz,
    SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END)    AS null_units_sold,
    SUM(CASE WHEN dollar_sales IS NULL THEN 1 ELSE 0 END)  AS null_dollar_sales,
    SUM(CASE WHEN base_price IS NULL THEN 1 ELSE 0 END)    AS null_base_price,
    SUM(CASE WHEN promo_flag IS NULL THEN 1 ELSE 0 END)    AS null_promo_flag
FROM pos_sales_data;

-- Checking promo trade table for missing or null data
SELECT 
	SUM(CASE WHEN week IS NULL THEN 1 ELSE 0 END)			AS null_week,
	SUM(CASE WHEN retailer IS NULL THEN 1 ELSE 0 END)		AS null_retailer,		
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END)		AS null_product,
	SUM(CASE WHEN promo_type IS NULL THEN 1 ELSE 0 END)		AS null_promo,
	SUM(CASE WHEN trade_spend IS NULL THEN 1 ELSE 0 END)	AS null_trade,
	SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END)	AS null_discount
FROM promo_trade_data;

-- Revenue by retailer / region
SELECT 
	retailer,
    region,
    ROUND(SUM(dollar_sales) - SUM(units_sold * cost_per_unit),2) as revenue
FROM pos_sales_data psd JOIN product_master pm ON psd.product_id = pm.product_id
GROUP BY retailer, region
ORDER BY retailer, revenue DESC, region;

-- Base vs Promo volume
WITH base_vs_promo_volume AS(
	WITH base_volume AS(
		SELECT
			retailer,
			product_id,
			region,
			ROUND(AVG(units_sold),2) AS avg_base_units
		FROM 
			pos_sales_data
		WHERE 
			promo_flag = 'N'
		GROUP BY 
			retailer,
			product_id,
			region
	)
	SELECT
		p.week,
		p.retailer,
		p.region,
		p.product_id,
		p.units_sold AS total_promo_units,
		b.avg_base_units,
		CASE
			WHEN p.units_sold > b.avg_base_units
			THEN p.units_sold - b.avg_base_units
			ELSE 0
		END AS promo_units_diff,
		(p.units_sold - b.avg_base_units) AS incremental_units,
		ROUND((p.units_sold - b.avg_base_units) * p.base_price,2) AS incremental_revenue
	FROM pos_sales_data p
	JOIN base_volume b
	  ON p.retailer = b.retailer
	 AND p.product_id = b.product_id
	 AND p.region = b.region
	WHERE p.promo_flag = 'Y'
)

-- Top 5 and Bottom 5 Based in Incremental Revenue
(SELECT * FROM base_vs_promo_volume ORDER BY incremental_revenue DESC LIMIT 5)
UNION ALL
(SELECT * FROM base_vs_promo_volume ORDER BY incremental_revenue ASC LIMIT 5);

-- Promo ROI
WITH base_volume AS (
    SELECT
        retailer,
        region,
        product_id,
        AVG(units_sold) AS avg_base_units
    FROM pos_sales_data
    WHERE promo_flag = 'N'
    GROUP BY retailer, region, product_id
),
promo_lift AS (
    SELECT
        p.week,
        p.retailer,
        p.region,
        p.product_id,
        p.units_sold AS total_units,
        b.avg_base_units AS base_units,
        CASE
            WHEN p.units_sold > b.avg_base_units
            THEN p.units_sold - b.avg_base_units
            ELSE 0
        END AS incremental_units,
        p.base_price
    FROM pos_sales_data p
    JOIN base_volume b
      ON p.retailer = b.retailer
     AND p.region = b.region
     AND p.product_id = b.product_id
    WHERE p.promo_flag = 'Y'
),
promo_with_spend AS (
    SELECT
        l.week,
        l.retailer,
        l.region,
        l.product_id,
        l.incremental_units,
        l.base_price,
        t.trade_spend,
        t.promo_type,
        t.discount_pct
    FROM promo_lift l
    LEFT JOIN promo_trade_data t
      ON l.week = t.week
     AND l.retailer = t.retailer
     AND l.product_id = t.product_id
)
SELECT
    week,
    retailer,
    region,
    product_id,
    promo_type,
    ROUND(incremental_units, 2) AS incremental_units,
    trade_spend,
    CONCAT(ROUND(discount_pct*100),'%') as discount_percent,
    ROUND(
        incremental_units * base_price * (1 - discount_pct),
        2
    ) AS incremental_revenue,
    CASE
        WHEN trade_spend > 0
        THEN ROUND(
            (incremental_units * base_price * (1 - discount_pct))
            / trade_spend,
            2
        )
        ELSE NULL
    END AS promo_roi
FROM promo_with_spend
WHERE promo_type IS NOT NULL
ORDER BY promo_roi DESC;

-- CSV analysis file to be used in Python analysis
WITH base_volume AS (
    SELECT
        retailer,
        region,
        product_id,
        AVG(units_sold) AS avg_base_units
    FROM pos_sales_data
    WHERE promo_flag = 'N'
    GROUP BY retailer, region, product_id
),

promo_lift AS (
    SELECT
        p.week,
        p.retailer,
        p.region,
        p.product_id,
        b.avg_base_units,
        CASE
            WHEN p.units_sold > b.avg_base_units
            THEN p.units_sold - b.avg_base_units
            ELSE 0
        END AS incremental_units,
        p.base_price
    FROM pos_sales_data p
    JOIN base_volume b
      ON p.retailer = b.retailer
     AND p.region = b.region
     AND p.product_id = b.product_id
    WHERE p.promo_flag = 'Y'
),

promo_with_spend AS (
    SELECT
        l.week,
        l.retailer,
        l.region,
        l.product_id,
        l.avg_base_units,
        l.incremental_units,
        l.base_price,
        t.promo_type,
        t.discount_pct,
        t.trade_spend
    FROM promo_lift l
    LEFT JOIN promo_trade_data t
      ON l.week = t.week
     AND l.retailer = t.retailer
     AND l.product_id = t.product_id
)

SELECT
    week,
    retailer,
    region,
    product_id,
    promo_type,
    ROUND(avg_base_units,2) as avg_base_units,
    ROUND(incremental_units,2) AS incremental_units,
    base_price,
    discount_pct,

    -- Promo price (used heavily in Python analysis)
    ROUND(base_price * (1 - discount_pct),2) AS promo_price,

    -- Incremental revenue at net promo price
    ROUND(incremental_units * base_price * (1 - discount_pct),2) AS incremental_revenue,

    trade_spend,

    -- ROI kept numeric for aggregation & modeling
    ROUND(CASE
        WHEN trade_spend > 0
        THEN (incremental_units * base_price * (1 - discount_pct)) / trade_spend
        ELSE NULL
    END,2) AS promo_roi

FROM promo_with_spend
WHERE promo_type IS NOT NULL;
