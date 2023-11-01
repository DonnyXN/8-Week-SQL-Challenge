/* 
Pizza Metrics Case Questions
*/

-- customer_orders cleaned
DROP TABLE IF EXISTS customer_orders_clean;
CREATE TEMP TABLE customer_orders_clean AS
SELECT 
	order_id, 
	customer_id, 
	pizza_id, 
	CASE
		WHEN exclusions = 'null' THEN ''
		ELSE exclusions
	END AS exclusions,
	CASE
		WHEN extras IS NULL or extras LIKE 'null' THEN ''
		ELSE extras
	END AS extras,
	order_time
FROM 
	pizza_runner.customer_orders;

-- runner_orders cleaned
DROP TABLE IF EXISTS runner_orders_clean;
CREATE TEMP TABLE runner_orders_clean AS
SELECT
	order_id,
	runner_id,
	CASE 
		WHEN pickup_time = 'null' THEN ''
		ELSE pickup_time
	END,
	CASE 
		WHEN distance = 'null' THEN ''
		ELSE TRIM('%km' FROM distance)
	END AS distance,
	CASE
		WHEN duration = 'null' THEN ''
		ELSE SUBSTRING(duration, 1, 2)
	END AS duration,
	CASE
		WHEN cancellation = 'null' or cancellation is NULL THEN ''
		ELSE cancellation
	END AS cancellation
FROM 
	pizza_runner.runner_orders


-- 1. How many pizzas were ordered?

SELECT 
	COUNT(order_id) AS pizzas_ordered
FROM 
	customer_orders_clean

-- 2. How many unique customer orders were made?

SELECT
	COUNT(DISTINCT(order_id)) AS unique_customer_ordered
FROM 
	customer_orders_clean

-- 3. How many successful orders were delivered by each runner?

SELECT
	COUNT(cancellation) AS successful_orders
FROM 
	runner_orders_clean
WHERE cancellation = ''

-- 4. How many of each type of pizza was delivered?

SELECT 
	co.pizza_id,
	COUNT(co.pizza_id) as pizzas_delivered
FROM 
	customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = '' -- avoid pizzas cancelled
GROUP BY pizza_id

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT
	co.customer_id,
	COUNT(pi.pizza_name) AS pizzas_ordered
FROM 
	customer_orders_clean co
JOIN pizza_runner.pizza_names pi ON co.pizza_id=pi.pizza_id
GROUP BY co.customer_id

-- 6. What was the maximum number of pizzas delivered in a single order?

-- join tables
-- dont include those that got cancelled clause
-- get the count of pizzas and group by order id

SELECT
	co.order_id,
	COUNT(co.pizza_id) AS pizza_count
FROM
	customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = '' -- avoid pizzas cancelled
GROUP BY co.order_id

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- will have to group by customer
-- count of pizzas that had 1 change and count of pizzas that had no changes
-- dont include those that got cancelled clause

SELECT	
	co.customer_id,
	SUM(CASE
		WHEN co.exclusions != '' AND co.extras != '' THEN 1
		WHEN co.exclusions = '' AND co.extras != '' THEN 1
		WHEN co.exclusions != '' AND co.extras = '' THEN 1
		ELSE 0
	END 
	) AS pizzas_changed,
	SUM(CASE
		WHEN co.exclusions = '' AND co.extras = '' THEN 1
		ELSE 0
	END 
	) AS pizzas_unchanged
FROM
	customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id 
WHERE cancellation = '' -- avoid pizzas cancelled
GROUP BY co.customer_id

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT
	SUM(CASE
		WHEN co.exclusions != '' AND co.extras != '' THEN 1
		ELSE 0
	END 
	) AS pizza_with_exclusions_and_extras
FROM
	customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id 
WHERE cancellation = '' -- avoid pizzas cancelled

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT 
	EXTRACT(HOUR FROM order_time) AS hour,
	COUNT(order_id) AS pizzas
FROM
	customer_orders_clean co
GROUP BY hour
ORDER BY hour ASC;

-- 10. What was the volume of orders for each day of the week?

SELECT 
	TO_CHAR(order_time, 'Dy') AS day,
	COUNT(order_id) AS pizzas
FROM
	customer_orders_clean co
GROUP BY day
ORDER BY day ASC;
