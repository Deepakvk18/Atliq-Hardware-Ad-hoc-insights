# Problem Statement

**Domain**:  Consumer Goods

Atliq Hardwares (imaginary company) is one of the leading computer hardware producers in India and well expanded in other countries too.

However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. They want to expand their data analytics team by adding several junior data analysts.
<br/>
<br/>

# Task

1.    Check ‘ad-hoc-requests.pdf’ - there are 10 ad hoc requests for which the business needs insights.
2.    Run a SQL query to answer these requests. 
<br/>
<br/>

# Questions To be Answered

### 1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.

#### **Query:**
````sql
SELECT DISTINCT market
FROM gdb023.dim_customer
WHERE customer='Atliq Exclusive' AND region='APAC';
````

#### **Result:** 

The countries with customer ```Atliq Exclusive``` operates in ```OPAC``` region are:

|    market     |
| ------------- |
| India         |
| Indonesia     |
| Japan         |
| Philippines   |
| South Korea   |
| Australia     |
| New Zealand   |
| Bangladesh    |

<br/>
<br/>

### 2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, [unique_products_2020 | unique_products_2021 | percentage_chg]

#### **Query:**
````sql
WITH unique_products AS(
    SELECT 
	(SELECT COUNT(DISTINCT product_code) FROM gdb023.fact_sales_monthly WHERE fiscal_year=2020) AS unique_products_2020,
    (SELECT COUNT(DISTINCT product_code) FROM gdb023.fact_sales_monthly WHERE fiscal_year=2021) AS unique_products_2021
    )
SELECT *,
	ROUND(100.0 * (unique_products_2021 - unique_products_2020)/unique_products_2020, 2) AS percentage_chg
FROM unique_products;
````

#### **Result:** 

The Percentage increase of unique product increase in Fiscal Year 2021 vs. 2020 is:

| unique_products_2020 | unique_products_2021  | percentage_chg |
| -------------------- | ----------------------| -------------------- |
| 245                  | 334                   | 36.33                |

<br/>
<br/>

### 3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields, [segment | product_count]

#### **Query:**
````sql
SELECT 
	segment,
    COUNT(DISTINCT product_code) AS product_count
FROM gdb023.dim_product
GROUP BY segment
ORDER BY product_count DESC;
````

#### **Result:** 

The number of unique products grouped by segment is:

| segment | product_count  |
| -------------------- | -----:| 
| Notebook             | 129  |
| Accessories          | 116  |
| Peripherals          | 84   |
| Desktop              | 32   |
| Storage              | 27   |
| Networking           | 9    |

<br/>
<br/>

### 4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, [segment | product_count_2020 | product_count_2021 | difference]

#### **Query:**
````sql
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
````

#### **Result:** 

The segment with most increase in the unique products in 2021 Vs. 2020 is:

| segment | product_count_2020  | product_count_2021 | difference |
| -------------------- | -----:| ------: | --------: |
| Notebook             | 69  |   103      | 34 |
| Accessories          | 92  |   108      | 16 |
| Peripherals          | 59   |   75      | 16 |   
| Desktop              | 7   |    22   | 15 |
| Storage              | 12   |    17     | 5 |
| Networking           | 6    |   9      | 3 |

- The segment with maximum increase in unique products is the ```Notebook``` segment and the lease increase is ```Networking``` segment.
- The reason why there is a difference in the unique product count from the above question and this question can be speculated to be because not all products in the segment will be sold. Even though Atliq hardware had 116 unique products in the ```accessories``` segment, only 116 unique products have been sold. 

<br/><br/>

### 5. Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields,[ product_code | product manufacturing_cost]

#### **Query:**
````sql
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
````

#### **Result:** 

The products that have the highest and lowest manufacturing costs are:

| product_code | manufacturing_cost  |
| -------------------- | -----:| 
| A6120110206             | 240.5364  |
| A2118150101          | 0.8920  |

<br/><br/>

### 6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields, [customer_code | customer | average_discount_percentage]

#### **Query:**
````sql
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
````

#### **Result:** 

The top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market are:

| customer_code | customer  | average_discount_percentage |
| -------------------- | -----| -----: |
| 90002009      | Flipkart       | 30.83  |
| 90002006      | Viveks    | 30.38  |
| 90002003      | Ezone    | 30.28  |
| 90002002      | Croma    | 30.25  |
| 90002016      | Amazon     | 29.33  |

- ```Flipkart```, ```Viveks```, ```EZone```, ```Croma``` and ````Amazon```` are the top 5 highest pre invoice discount getters from Atliq.


### 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: [Month | Year | Gross sales Amount]

#### **Query:**
````sql
SELECT
	m.fiscal_year,
	MONTHNAME(date) AS  month,
    ROUND(SUM(sold_quantity * gross_price * (1 - pre_invoice_discount_pct)) / 1000000, 2) AS gross_sales_amt_in_millions
FROM gdb023.fact_sales_monthly m 
	JOIN gdb023.dim_customer c ON m.customer_code=c.customer_code
    JOIN gdb023.fact_gross_price g ON g.fiscal_year=m.fiscal_year AND g.product_code=m.product_code
    JOIN gdb023.fact_pre_invoice_deductions i ON i.fiscal_year=m.fiscal_year AND m.customer_code=i.customer_code
WHERE customer='Atliq Exclusive'
GROUP BY fiscal_month, fiscal_year
ORDER BY fiscal_year;
````

#### **Result:** 

Report of the Gross sales amount for the customer “Atliq Exclusive” for each month:

| fiscal_year | month  | gross_sales_amt_in_millions |
| -------------------- | -----| -----: |
| 2020      | September       | 4.01  |
| 2020      | October    | 4.75  |
| 2020      | November    | 6.71  |
| 2020      | December    | 4.21  |
| 2020      | January     | 4.22  |
| 2020      | February       | 3.70  |
| 2020      | March    | 0.34  |
| 2020      | April    | 0.34  |
| 2020      | May    | 0.70  |
| 2020      | June     | 1.57  |
| 2020      | July       | 2.27  |
| 2020      | August    | 2.42  |
| 2021      | September    | 10.87  |
| 2021      | October    | 12.10  |
| 2021      | November     |  17.97 |
| 2021      | December       | 11.09 |
| 2021      | January    | 10.90  | 
| 2021      | February    |  9.27 |
| 2021      | March    |  10.66 |
| 2021      | April     |  6.27  |
| 2021      | May       |  10.69  |
| 2021      | June    | 8.99  |
| 2021      | July    | 10.64  |
| 2021      | August    | 6.16  |

<br/><br/>

### 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity [Quarter | total_sold_quantity]

#### **Query:**
````sql
SELECT 
	CONCAT('Q' , QUARTER(date + INTERVAL 3 MONTH)) AS quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM gdb023.fact_sales_monthly
WHERE fiscal_year=2020
GROUP BY quarter
ORDER BY total_sold_quantity DESC;
````

#### **Result:** 

The Fiscal Quarter in which maximum quantities are sold is:

| quarter | total_sold_quantity  | 
| -------------------- | -----: |
| Q1      | 8425822    | 
| Q4      | 5246770    | 
| Q2      | 3704398    | 
| Q3      | 3395899     |

- It can be seen that in ```Fiscal Quarter 1``` in fiscal year 2020 (Sep'19-Dec'19) has the most quantity sold in the fiscal year 2020.
<br/><br/>

### 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields, [channel  | gross_sales_mln | percentage]

#### **Query:**
````sql
WITH customer_revenue AS(
	SELECT 
		m.customer_code,
		SUM((sold_quantity * gross_price) * (1 - pre_invoice_discount_pct)) AS revenue
	FROM gdb023.fact_sales_monthly m 
		JOIN gdb023.fact_gross_price g ON m.product_code=g.product_code AND m.fiscal_year=g.fiscal_year
		JOIN gdb023.fact_pre_invoice_deductions i ON m.customer_code=i.customer_code AND m.fiscal_year=i.fiscal_year
	WHERE m.fiscal_year=2021  
	GROUP BY m.customer_code)
SELECT
	channel,
    ROUND(SUM(revenue)/1000000, 2) AS gross_sales_mln,
    ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM customer_revenue), 2) AS percentage
FROM customer_revenue r JOIN gdb023.dim_customer c ON r.customer_code=c.customer_code
GROUP BY channel
ORDER BY percentage DESC;
````

#### **Result:** 

Distribution of Gross Sales by Channel in FIscal Year 2021:

| channel | gross_sales_mln  | percentage |
| -------------------- | -----:| -----: |
| Retailer      | 917.39       | 72.11  |
| Direct      | 216.37    | 17.01  |
| Distributor      | 138.38    | 10.88  |

- ```Retailer``` channel drives the most revenue for Atliq at roughly 72% of gross sales followed by Direct and then by Distributor channel.

<br/><br/>

### 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields, [division | product_code | product | total_sold_quantity | rank_order]

#### **Query:**
````sql
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
````

#### **Result:** 

The top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market are:

| division | product_code  | product |  total_sold_quantity | rank_order  |
| -------------------- | -----| ----- | -------: | -------: |
| N & S | A6720160103 | AQ Pen Drive 2 IN 1 | 701373 | 1 |
| N & S | A6818160202 | AQ Pen Drive DRC | 688003 | 2 |
| N & S | A6819160203 | AQ Pen Drive DRC | 676245 | 3 |
| P & A | A2319150302 | AQ Gamers Ms | 428498 | 1 |
| P & A | A2520150501 | AQ Maxima Ms | 419865 | 2 |
| P & A | A2520150504 | AQ Maxima Ms | 419471 | 3 |
| PC | A4218110202 | AQ Digit | 17434 | 1 |
| PC | A4319110306 | AQ Velocity | 17280 | 2 |
| PC | A4218110208 | AQ Digit | 17275 | 3 |

<br/><br/>
===============================================================