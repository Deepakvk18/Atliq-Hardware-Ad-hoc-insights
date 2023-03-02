-- 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
SELECT DISTINCT market
FROM gdb023.dim_customer
WHERE customer='Atliq Exclusive' AND region='APAC';

-- =======================================================================================================================

-- 2. What is the percentage of unique product increase in 2021 vs. 2020?
WITH unique_products AS(
	SELECT 
	(SELECT COUNT(DISTINCT product_code) FROM gdb023.fact_sales_monthly WHERE fiscal_year=2020) AS unique_products_2020,
    (SELECT COUNT(DISTINCT product_code) FROM gdb023.fact_sales_monthly WHERE fiscal_year=2021) AS unique_products_2021
    )
SELECT *,
		ROUND(100.0 * (unique_products_2021 - unique_products_2020)/unique_products_2020, 2) AS percentage_chg
FROM unique_products;

-- =======================================================================================================================

-- 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. 
SELECT 
	segment,
    COUNT(DISTINCT product_code) AS product_count
FROM gdb023.dim_product
GROUP BY segment
ORDER BY product_count DESC;

-- =======================================================================================================================

-- 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020?
WITH unique_products AS(
	SELECT 
		segment,
        COUNT(DISTINCT CASE WHEN fiscal_year=2020 THEN p.product_code ELSE null END) AS product_count_2020,
        COUNT(DISTINCT CASE WHEN fiscal_year=2021 THEN p.product_code ELSE null END) AS product_count_2021
	FROM gdb023.fact_sales_monthly m JOIN gdb023.dim_product p 
		ON m.product_code=p.product_code
	GROUP BY segment)
SELECT 
	segment,
    product_count_2020,
    product_count_2021,
    product_count_2021 - product_count_2020 AS difference
FROM unique_products
ORDER BY difference DESC;

-- =======================================================================================================================

-- 5. Get the products that have the highest and lowest manufacturing costs.
(SELECT 
	product_code,
	manufacturing_cost
FROM gdb023.fact_manufacturing_cost
ORDER BY manufacturing_cost DESC
LIMIT 1)
UNION 
(SELECT 
	product_code,
	manufacturing_cost
FROM gdb023.fact_manufacturing_cost
ORDER BY manufacturing_cost
LIMIT 1);

-- =======================================================================================================================

-- 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
SELECT 
	c.customer_code,
    c.customer,
    ROUND(AVG(pre_invoice_discount_pct)*100.0, 2) AS average_discount_percentage
FROM gdb023.fact_pre_invoice_deductions i JOIN gdb023.dim_customer c 
		ON i.customer_code=c.customer_code
WHERE fiscal_year=2021 AND market='India'
GROUP BY c.customer_code, c.customer
ORDER BY average_discount_percentage DESC
LIMIT 5;

-- =======================================================================================================================

-- 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month.
SELECT
	m.fiscal_year,
	MONTHNAME(date) AS  month,
    ROUND(SUM(sold_quantity * gross_price) / 1000000, 2) AS gross_sales_amt_in_millions
FROM gdb023.fact_sales_monthly m 
	JOIN gdb023.dim_customer c ON m.customer_code=c.customer_code
    JOIN gdb023.fact_gross_price g ON g.fiscal_year=m.fiscal_year AND g.product_code=m.product_code
WHERE customer='Atliq Exclusive'
GROUP BY month, fiscal_year
ORDER BY fiscal_year;

-- =======================================================================================================================

-- 8. In which quarter of 2020, got the maximum total_sold_quantity?
SELECT 
	CONCAT('Q' , QUARTER(date + INTERVAL 3 MONTH)) AS quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM gdb023.fact_sales_monthly
WHERE fiscal_year=2020
GROUP BY quarter
ORDER BY total_sold_quantity DESC;

-- =======================================================================================================================

-- 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
WITH customer_revenue AS(
	SELECT 
		m.customer_code,
		SUM((sold_quantity * gross_price)) AS revenue
	FROM gdb023.fact_sales_monthly m 
		JOIN gdb023.fact_gross_price g ON m.product_code=g.product_code AND m.fiscal_year=g.fiscal_year
	WHERE m.fiscal_year=2021  
	GROUP BY m.customer_code)
SELECT
	channel,
    ROUND(SUM(revenue)/1000000, 2) AS gross_sales_mln,
    ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM customer_revenue), 2) AS percentage
FROM customer_revenue r JOIN gdb023.dim_customer c ON r.customer_code=c.customer_code
GROUP BY channel
ORDER BY percentage DESC;

-- =======================================================================================================================

-- 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?
WITH product_agg AS(
	SELECT 
		product_code,
		SUM(sold_quantity) AS total_sold_quantity
	FROM gdb023.fact_sales_monthly
	WHERE fiscal_year=2021
	GROUP BY product_code),
    ranked AS(
	SELECT
		division,
		a.product_code,
        product,
		total_sold_quantity,
		RANK() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order
	FROM product_agg a JOIN gdb023.dim_product p ON a.product_code=p.product_code)
SELECT *
FROM ranked
WHERE rank_order <= 3;