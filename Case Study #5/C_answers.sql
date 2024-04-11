-- C. Before & After Analysis

-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

SELECT 
	*
FROM data_mart.clean_weekly_sales

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

-- PART 1

-- get the week number of the given date
SELECT 
	DISTINCT(week_number) AS week
FROM data_mart.clean_weekly_sales
WHERE week_date = '2020-06-15'

-- filter data to 4 weeks before and after week 25
WITH weeks AS (
	SELECT 
		week_number,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE week_number BETWEEN '21' AND '29'
)
-- get the total sales of each 4 week period
SELECT 
	SUM(CASE WHEN week_number BETWEEN '21' AND '24' THEN sales END) AS before_changes,
	SUM(CASE WHEN week_number BETWEEN '25' AND '29' THEN sales END) AS after_changes
FROM weeks


-- PART 2

-- filter data to 4 weeks before and after week 25
WITH weeks AS (
	SELECT 
		week_number,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE week_number BETWEEN '21' AND '29'
),
-- get the total sales of each 4 week period
total_sales AS (
	SELECT 
		SUM(CASE WHEN week_number BETWEEN '21' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '29' THEN sales END) AS after_changes
	FROM weeks
)
-- get the sales difference and pct difference
SELECT 
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales

-- 2. What about the entire 12 weeks before and after?

WITH weeks AS (
	SELECT 
		week_number,
		sales
	FROM data_mart.clean_weekly_sales 
	WHERE week_number BETWEEN '21' AND '29'
),
-- get the total sales of each 4 week period
total_sales AS (
	SELECT 
		SUM(CASE WHEN week_number BETWEEN '13' AND '24' THEN sales END) AS before_changes,
		SUM(CASE WHEN week_number BETWEEN '25' AND '37' THEN sales END) AS after_changes
	FROM weeks
)
-- get the sales difference and pct difference
SELECT 
	after_changes - before_changes AS sales_diff,
	ROUND(100.0 * (after_changes) / before_changes - 100, 2) as pct_change
FROM total_sales

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?


