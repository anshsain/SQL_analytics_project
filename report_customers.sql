CREATE VIEW gold.report_customers AS 

WITH base_query AS (SELECT 
s.order_number,
s.product_key,
s.order_date,
s.sales_amount,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name,' ',c.last_name) AS Customer_Name,
DATEDIFF(year,c.birthdate,GETDATE()) AS age
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
ON s.customer_key = c.customer_key
WHERE order_date is not NULL)

, customer_aggregation AS (
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(quantity) as total_quantity,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT product_key) as total_products,
MAX(order_date) AS last_order_date,
DATEDIFF(month,MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY  
	customer_key,
	customer_number,
	customer_name,
	age )

SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE 
	WHEN age<20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and ABOVE'
END age_group,
	CASE 
		WHEN lifespan>12 and total_sales>5000 THEN 'VIP'
		WHEN lifespan>12 and total_sales<=5000 then 'Regular'
		else 'new'
	END customer_segment,
total_orders,
total_quantity,
total_sales,
total_products,
last_order_date,
DATEDIFF(month,last_order_date,GETDATE()) AS recency,
lifespan,
-- Average_order_Value
CASE WHEN total_sales = 0 THEN 0
	ELSE total_sales / total_orders 
END AS avg_order_value,

-- Average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation