SELECT 
	*
FROM data_bank.customer_nodes

SELECT 
	*
FROM data_bank.customer_transactions

SELECT 
	*
FROM data_bank.regions

-- A. Customer Nodes Exploration

-- 1. How many unique nodes are there on the Data Bank system?

SELECT
	COUNT(DISTINCT(node_id))
FROM data_bank.customer_nodes


-- 2. What is the number of nodes per region?

SELECT 
	r.region_name AS region,
	COUNT(DISTINCT(n.node_id)) AS nodes
FROM data_bank.regions r
JOIN data_bank.customer_nodes n ON r.region_id = n.region_id
GROUP BY r.region_name

-- 3. How many customers are allocated to each region?

SELECT 
	r.region_name AS region,
	COUNT(*) AS customers
FROM data_bank.regions r
JOIN data_bank.customer_nodes n ON r.region_id = n.region_id
GROUP BY r.region_name

-- 4. How many days on average are customers reallocated to a different node?

WITH days_per_node AS (
	SELECT
		customer_id,
		start_date,
		end_date,
		end_date - start_date AS days
	FROM data_bank.customer_nodes
	WHERE DATE_PART('year', end_date) <> 9999
)

SELECT 
	ROUND(AVG(days), 1) AS avg_days
FROM days_per_node

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?










