
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
FROM pizza_runner.customer_orders;
	
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