-- D. Bonus Question

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- get the week number of the given date
SELECT 
	DISTINCT(week_number) AS week
FROM data_mart.clean_weekly_sales
WHERE week_date = '2020-06-15'

-- region

WITH weeks AS (
	SELECT 
		week_number,
		region,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE (week_number BETWEEN '13' AND '37')
	AND (year_number = '2020')
),
total_sales AS (
	SELECT 
		region,
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
	GROUP BY region
)
SELECT 
	region,
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales
ORDER BY pct_change


-- platform

WITH weeks AS (
	SELECT 
		week_number,
		platform,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE (week_number BETWEEN '13' AND '37')
	AND (year_number = '2020')
),
total_sales AS (
	SELECT 
		platform,
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
	GROUP BY platform
)
SELECT 
	platform,
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales
ORDER BY pct_change

-- age_band

WITH weeks AS (
	SELECT 
		week_number,
		age_band,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE (week_number BETWEEN '13' AND '37')
	AND (year_number = '2020')
),
total_sales AS (
	SELECT 
		age_band,
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
	GROUP BY age_band
)
SELECT 
	age_band,
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales
ORDER BY pct_change

-- demographic

WITH weeks AS (
	SELECT 
		week_number,
		demographic,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE (week_number BETWEEN '13' AND '37')
	AND (year_number = '2020')
),
total_sales AS (
	SELECT 
		demographic,
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
	GROUP BY demographic
)
SELECT 
	demographic,
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales
ORDER BY pct_change

-- customer_type

WITH weeks AS (
	SELECT 
		week_number,
		customer_type,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE (week_number BETWEEN '13' AND '37')
	AND (year_number = '2020')
),
total_sales AS (
	SELECT 
		customer_type,
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
	GROUP BY customer_type
)
SELECT 
	customer_type,
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales
ORDER BY pct_change

