SELECT 
age_group,
COUNT(customer_number) AS total_customers,
SUM(total_sales) as total_sales
FROM gold.report_customers
GROUP BY age_group