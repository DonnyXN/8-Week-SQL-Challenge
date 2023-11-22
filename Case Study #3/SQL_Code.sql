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
	p.plan_name, 
	sub.start_date
FROM
	foodie_fi.plans p
JOIN foodie_fi.subscriptions sub ON p.plan_id = sub.plan_id
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
	foodie_fi.plans p
JOIN foodie_fi.subscriptions sub ON p.plan_id = sub.plan_id
WHERE sub.plan_id = '0'
GROUP BY month_date, month
ORDER BY month_date ASC


-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT
	p.plan_id,
	p.plan_name,
	COUNT(sub.customer_id)
FROM
	foodie_fi.plans p
JOIN foodie_fi.subscriptions sub ON p.plan_id = sub.plan_id
WHERE sub.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY p.plan_id ASC

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
	SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS churn_count,
	CAST(SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS FLOAT) 
		/ COUNT(DISTINCT sub.customer_id) * 100 AS churn_pct
FROM
	foodie_fi.plans p
JOIN foodie_fi.subscriptions sub ON p.plan_id = sub.plan_id



-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- 6. What is the number and percentage of customer plans after their initial free trial?
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- 8. How many customers have upgraded to an annual plan in 2020?
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?