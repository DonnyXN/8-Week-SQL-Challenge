/* 
A. Pizza Metrics Case Questions
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
ORDER BY hour ASC

-- 10. What was the volume of orders for each day of the week?

SELECT 
	TO_CHAR(order_time, 'Dy') AS day,
	COUNT(order_id) AS pizzas
FROM
	customer_orders_clean co
GROUP BY day
ORDER BY day ASC


/* 
B. Runner and Customer Experience
*/

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
	EXTRACT(WEEK FROM registration_date) AS registration_week,
	COUNT(runner_id) AS runner_registration
FROM 
	pizza_runner.runners
GROUP BY registration_week
-- query is returning week 53

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT 
	ro.runner_id,
	ROUND(AVG(EXTRACT(MINUTE FROM (TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS')) - co.order_time)), 0) AS avg_minutes
FROM 
	runner_orders_clean ro
JOIN customer_orders_clean co ON ro.order_id=co.order_id
WHERE cancellation = ''
GROUP BY ro.runner_id

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- create cte to get count of pizzas per order
WITH pizza_count_table AS (
	SELECT
		order_id,
		COUNT(order_id) AS number_of_pizzas,
		order_time
	FROM 
		customer_orders_clean
	GROUP BY order_id, order_time
)
SELECT
	pc.number_of_pizzas,
	ROUND(AVG(EXTRACT(MINUTE FROM (TO_TIMESTAMP(ro.pickup_time, 'YYYY-MM-DD HH24:MI:SS')) - pc.order_time)), 1) AS avg_minutes
FROM
	pizza_count_table pc
JOIN runner_orders_clean ro ON pc.order_id=ro.order_id
WHERE cancellation = ''
GROUP BY pc.number_of_pizzas

-- 4. What was the average distance travelled for each customer?

SELECT 
	co.customer_id,
	ROUND(AVG(CAST(distance AS NUMERIC)), 1)
FROM 
	customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = ''
GROUP BY co.customer_id

-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT
	(MAX(CAST(duration AS NUMERIC)) - MIN(CAST(duration AS NUMERIC))) AS range
FROM
	runner_orders_clean
WHERE cancellation = ''
	
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
	runner_id,
	order_id,
	ROUND(CAST(distance AS NUMERIC) / CAST(duration AS NUMERIC), 2) * 60 AS speed_km_per_hr
FROM
	runner_orders_clean
WHERE cancellation = ''
ORDER BY runner_id, speed_km_per_hr ASC

-- 7. What is the successful delivery percentage for each runner?

SELECT 
	runner_id,
	ROUND(SUM(CASE
		WHEN cancellation <> '' THEN 0 
		ELSE 1
	END) / CAST(COUNT(order_id) AS NUMERIC) * 100, 0) AS delivery_success
FROM
	runner_orders_clean
GROUP BY runner_id
ORDER BY delivery_success DESC


/* 
C. Ingredient Optimization
*/

-- 1. What are the standard ingredients for each pizza?
	
WITH topping_table AS (
	SELECT
		pizza_id,
		CAST(topping AS NUMERIC)
	FROM
		pizza_runner.pizza_recipes,
		UNNEST(STRING_TO_ARRAY(toppings, ', ')) topping -- separated string of toppings
)
SELECT
	pn.pizza_name,
	STRING_AGG(pt.topping_name, ', ') AS toppings
FROM
	topping_table tt
JOIN pizza_runner.pizza_toppings pt ON tt.topping=pt.topping_id
JOIN pizza_runner.pizza_names pn ON tt.pizza_id=pn.pizza_id
GROUP BY pn.pizza_name

-- 2. What was the most commonly added extra?
WITH extra_cte AS (
	SELECT
		CAST(UNNEST(STRING_TO_ARRAY(extras, ', ')) AS NUMERIC) AS extra -- separate by comma into own rows
	FROM
		customer_orders_clean
	WHERE extras <> ''
)
SELECT 
	COUNT(pt.topping_name) AS topping_count,
	pt.topping_name
FROM
	extra_cte t
JOIN pizza_runner.pizza_toppings pt ON t.extra=pt.topping_id
GROUP BY pt.topping_name
ORDER BY topping_count DESC
	
-- 3. What was the most common exclusion?
-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--		Meat Lovers
--		Meat Lovers - Exclude Beef
--		Meat Lovers - Extra Bacon
--		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--		For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

