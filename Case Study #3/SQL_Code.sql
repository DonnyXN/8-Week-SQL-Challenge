SELECT 
	*
FROM 
	foodie_fi.plans
	
SELECT 
	*
FROM 
	foodie_fi.subscriptions
	
-- A. Customer Journey
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

-- 8 sample customers table

SELECT 
	sub.customer_id,
	plans.plan_name, 
	sub.start_date
FROM
	foodie_fi.plans 
JOIN foodie_fi.subscriptions sub ON plans.plan_id = sub.plan_id
WHERE sub.customer_id IN (19)
--WHERE sub.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)

-- B. Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?

SELECT 
	COUNT(DISTINCT(customer_id)) AS customer_count
FROM 
	foodie_fi.subscriptions


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
	DATE_PART('MONTH', sub.start_date) AS month_date,
	TO_CHAR(sub.start_date, 'Month') AS month,
	COUNT(sub.customer_id)
FROM
	foodie_fi.plans 
JOIN foodie_fi.subscriptions sub ON plans.plan_id = sub.plan_id
WHERE sub.plan_id = '0'
GROUP BY month_date, month
ORDER BY month_date ASC


-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
	plans.plan_id,
	plans.plan_name,
	COUNT(sub.customer_id)
FROM
	foodie_fi.plans
JOIN foodie_fi.subscriptions sub ON plans.plan_id = sub.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY plans.plan_id, plans.plan_name
ORDER BY plans.plan_id ASC

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 END) AS churn_count,
	CAST(SUM(CASE WHEN plans.plan_name = 'churn' THEN 1 END) AS FLOAT) 
		/ COUNT(DISTINCT sub.customer_id) * 100 AS churn_pct
FROM
	foodie_fi.plans 
JOIN foodie_fi.subscriptions sub ON plans.plan_id = sub.plan_id


-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH customer_next_plan AS (
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id) OVER (
			PARTITION BY customer_id 
			ORDER BY start_date
		) AS next_plan
	FROM foodie_fi.subscriptions
)

SELECT
	COUNT(*) AS customers_churned,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM customer_next_plan), 1) AS churn_percentage
FROM
	customer_next_plan 
WHERE next_plan = 4
	AND plan_id = 0

-- 6. What is the number and percentage of customer plans after their initial free trial?

WITH customer_next_plan AS (
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id) OVER (
			PARTITION BY customer_id 
			ORDER BY start_date
		) AS next_plan
	FROM foodie_fi.subscriptions
)

SELECT
	next_plan,
	COUNT(DISTINCT customer_id) customer_plan,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM customer_next_plan), 1) AS churn_percentage
FROM customer_next_plan
WHERE plan_id = 0
GROUP BY next_plan

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH customer_next_plan AS (
	SELECT
		customer_id,
		plan_id,
		start_date,
		LEAD(plan_id) OVER (
			PARTITION BY customer_id 
			ORDER BY start_date
		) AS next_plan
	FROM foodie_fi.subscriptions
	WHERE start_date <= '2020-12-31'
)

SELECT
	plan_id,
	COUNT(DISTINCT customer_id) customers,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM customer_next_plan), 1) AS churn_percentage
FROM customer_next_plan
WHERE next_plan IS NULL
GROUP BY plan_id

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT
	COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions sub
JOIN foodie_fi.plans ON plans.plan_id = sub.plan_id
WHERE start_date <= '2020-12-31'
	AND sub.plan_id = 3

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH trial_plan AS (
	SELECT 
		customer_id,
		start_date as trial_start
	FROM foodie_fi.subscriptions
	WHERE plan_id = 0
),
	annual_plan AS(
	SELECT 
		customer_id,
		start_date as annual_start
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3
)

SELECT 
	ROUND(AVG(a.annual_start - t.trial_start), 1) AS avg_days_to_annual_upgrade
FROM trial_plan t
JOIN annual_plan a ON a.customer_id = t.customer_id

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH trial_plan AS (
	SELECT 
		customer_id,
		start_date as trial_start
	FROM foodie_fi.subscriptions
	WHERE plan_id = 0
),
	annual_plan AS (
	SELECT 
		customer_id,
		start_date as annual_start
	FROM foodie_fi.subscriptions
	WHERE plan_id = 3
),
	bins AS (
	SELECT
		WIDTH_BUCKET(a.annual_start - t.trial_start, 0, 365, 13) AS avg_days_to_annual_upgrade
	FROM trial_plan t
	JOIN annual_plan a ON a.customer_id = t.customer_id
)
	
SELECT 
  ((avg_days_to_annual_upgrade - 1) * 30 || ' - ' || avg_days_to_annual_upgrade * 30 || ' days') AS bucket, 
  COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_annual_upgrade
ORDER BY avg_days_to_annual_upgrade


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH customer_next_plan AS (
	SELECT
		customer_id,
		plan_id,
		LEAD(plan_id) OVER (
			PARTITION BY customer_id 
			ORDER BY start_date
		) AS next_plan
	FROM foodie_fi.subscriptions
	WHERE DATE_PART('year', start_date) = 2020
)

SELECT 
	COUNT(*)
FROM customer_next_plan
WHERE plan_id = 2
	AND next_plan = 1







