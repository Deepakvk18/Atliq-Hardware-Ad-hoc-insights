# Problem Statement

**Domain**:  Consumer Goods

Atliq Hardwares (imaginary company) is one of the leading computer hardware producers in India and well expanded in other countries too.

However, the management noticed that they do not get enough insights to make quick and smart data-informed decisions. They want to expand their data analytics team by adding several junior data analysts.

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

- Flipkart, Viveks, EZone, Croma and Amazon are the top 5 highest pre invoice discount getters from Atliq.


### 7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month. This analysis helps to get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: [Month | Year | Gross | sales | Amount]



### 8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields sorted by the total_sold_quantity, Quarter total_sold_quantity


### 9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields, [channel  | gross_sales_mln percentage]


### 10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields, [division | product_code | product | total_sold_quantity | rank_order]
