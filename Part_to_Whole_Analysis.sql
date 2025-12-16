WITH category_sales AS (SELECT 
category,
SUM(sales_amount) as total_sales
FROM gold.fact_sales as s
LEFT JOIN gold.dim_products as p ON
s.product_key = p.product_key
GROUP BY category)

SELECT 
category,
total_sales,
SUM(total_sales) OVER(),
ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER())*100,2) as percent_share
FROM category_sales
ORDER BY total_sales DESC