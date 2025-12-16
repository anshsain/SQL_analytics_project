WITH yearly_sales AS (SELECT 
YEAR(s.order_date) AS order_year,
p.product_name,
SUM(s.sales_amount) AS current_sales
FROM gold.fact_sales as s
LEFT JOIN 
gold.dim_products as p
ON s.product_key = p.product_id
WHERE s.order_date is not null and p.product_name is not NULL
GROUP BY YEAR(s.order_date),
p.product_name

)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) as average_sales, 
current_sales-AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
	CASE WHEN
		current_sales-AVG(current_sales) OVER (PARTITION BY product_name)>0 THEN 'Above Average'
		WHEN current_sales-AVG(current_sales) OVER (PARTITION BY product_name)<0 THEN 'Below Average'
		else 'Average'
	END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as prev_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as dif_prev_sales
FROM yearly_sales
ORDER BY product_name,order_year 