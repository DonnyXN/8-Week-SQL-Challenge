SELECT 
	*
FROM data_mart.clean_weekly_sales

-- B. Data Exploration

-- What day of the week is used for each week_date value?

SELECT
	DISTINCT(TO_CHAR(week_date, 'Day')) AS week_day
FROM data_mart.clean_weekly_sales

-- What range of week numbers are missing from the dataset?

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

-- How many total transactions were there for each year in the dataset?

SELECT
	year_number,
	SUM(transactions)
FROM data_mart.clean_weekly_sales
GROUP BY year_number

-- What is the total sales for each region for each month?
-- What is the total count of transactions for each platform
-- What is the percentage of sales for Retail vs Shopify for each month?
-- What is the percentage of sales by demographic for each year in the dataset?
-- Which age_band and demographic values contribute the most to Retail sales?
-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?










