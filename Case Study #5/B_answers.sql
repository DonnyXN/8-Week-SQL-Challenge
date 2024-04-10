SELECT 
	*
FROM data_mart.clean_weekly_sales

-- B. Data Exploration

-- 1. What day of the week is used for each week_date value?

SELECT
	DISTINCT(TO_CHAR(week_date, 'Day')) AS week_day
FROM data_mart.clean_weekly_sales

-- 2. What range of week numbers are missing from the dataset?

WITH week_numbers AS (
SELECT
	GENERATE_SERIES(1, 52) AS numbers
)

SELECT
	DISTINCT(numbers),
	s.week_number
FROM week_numbers n
LEFT JOIN data_mart.clean_weekly_sales s ON s.week_number = n.numbers
WHERE s.week_number IS null
ORDER BY numbers

-- 3. How many total transactions were there for each year in the dataset?

SELECT
	year_number,
	SUM(transactions) AS transactions
FROM data_mart.clean_weekly_sales
GROUP BY year_number

-- 4. What is the total sales for each region for each month?

SELECT 
	region, 
	SUM(sales) AS sakes
FROM data_mart.clean_weekly_sales
GROUP BY region

-- 5. What is the total count of transactions for each platform

SELECT
	platform,
	SUM(transactions) AS transactions
FROM data_mart.clean_weekly_sales
GROUP BY platform

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
-- gets total sales per year, month, platform in cte
-- then join with clean data to get percent

	
WITH monthly_sales AS (
	SELECT
		year_number,
		month_number,
		platform,
		SUM(sales) AS month_sales
	FROM data_mart.clean_weekly_sales
	GROUP BY year_number, 
		month_number,
		platform
	ORDER BY month_number
)
	
SELECT 
	year_number,
	month_number,
	ROUND(100.0 * MAX(CASE WHEN platform = 'Shopify' THEN month_sales END) / SUM(month_sales), 2) AS Shopfy_sales_pct,
	ROUND(100.0 * MAX(CASE WHEN platform = 'Retail' THEN month_sales END) / SUM(month_sales), 2) AS Retail_sales_pct
FROM monthly_sales m
GROUP BY year_number,
	month_number

-- 7. What is the percentage of sales by demographic for each year in the dataset?

WITH demographic_sales AS (
	SELECT 
		year_number,
		demographic,
		SUM(sales) AS yearly_sales
	FROM data_mart.clean_weekly_sales
	GROUP BY year_number, demographic
	ORDER BY year_number
)

SELECT 
	year_number, 
	ROUND(100.0 * MAX(CASE WHEN demographic = 'Families' THEN yearly_sales END) / SUM(yearly_sales), 2) AS Families_sales_pct,
	ROUND(100.0 * MAX(CASE WHEN demographic = 'Couples' THEN yearly_sales END) / SUM(yearly_sales), 2) AS Couples_sales_pct,
	ROUND(100.0 * MAX(CASE WHEN demographic = 'Unknown' THEN yearly_sales END) / SUM(yearly_sales), 2) AS Unknown_sales_pct
FROM demographic_sales
GROUP BY year_number


-- 8. Which age_band and demographic values contribute the most to Retail sales?
-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?










