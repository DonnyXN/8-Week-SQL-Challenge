SELECT 
	*
FROM data_mart.clean_weekly_sales

SELECT 
	*
FROM data_mart.weekly_sales


-- Case Study Questions
-- The following case study questions require some data cleaning steps before we start to unpack Danny’s key business questions in more depth.

-- A. Data Cleansing Steps
-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

-- Convert the week_date to a DATE format
-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

-- segment	age_band
-- 1	Young Adults
-- 2	Middle Aged
-- 3 or 4	Retirees

-- Add a new demographic column using the following mapping for the first letter in the segment values:

-- segment	demographic
-- C	Couples
-- F	Families

-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

DROP TABLE IF EXISTS data_mart.clean_weekly_sales

CREATE TABLE data_mart.clean_weekly_sales AS (
SELECT 
	TO_DATE(week_date, 'DD/MM/YY') AS week_date,
	DATE_PART('Week', TO_DATE(week_date, 'DD/MM/YY')) AS week_number,
	DATE_PART('Month', TO_DATE(week_date, 'DD/MM/YY')) AS month_number,
	DATE_PART('Year', TO_DATE(week_date, 'DD/MM/YY')) AS year_number,
	region, 
	platform, 
	segment, 
	CASE
		WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
		WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
		WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
	ELSE 'unknown' END AS age_band,
	transactions,
	sales,
	CASE
		WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
		WHEN LEFT(segment, 1) = 'F' THEN 'Families'
	ELSE 'Unknown' END AS demographic,
	ROUND((sales::numeric / transactions::numeric), 2) AS avg_transaction
FROM data_mart.weekly_sales
)


















