WITH customer_spending as (SELECT 
c.customer_key,
SUM(s.sales_amount) as total_spend,
MIN(s.order_date) as first_order,
MAX(s.order_date) as last_order,
DATEDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) AS lifespan
FROM gold.fact_sales as s
LEFT JOIN gold.dim_customers as c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key) 

SELECT 
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
	SELECT 
	customer_key,
	CASE 
		WHEN lifespan>12 and total_spend>5000 THEN 'VIP'
		WHEN lifespan>12 and total_spend<=5000 then 'Regular'
		else 'new'
	END customer_segment
	FROM customer_spending) t 
GROUP BY customer_segment
ORDER BY total_customers DESC
