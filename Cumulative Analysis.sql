SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
moving_price,
AVG(moving_price) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS average_price
FROM
(
	SELECT 
	DATETRUNC(MONTH,order_date) as order_date,
	SUM(sales_amount) as Total_sales,
	AVG(price) as moving_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH,order_date)
)t