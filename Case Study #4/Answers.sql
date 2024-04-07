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
	COUNT(n.node_id) AS nodes
FROM data_bank.regions r
JOIN data_bank.customer_nodes n ON r.region_id = n.region_id
GROUP BY r.region_name

-- 3. How many customers are allocated to each region?

SELECT 
	r.region_name AS region,
	COUNT(DISTINCT(customer_id)) AS customers
FROM data_bank.regions r
JOIN data_bank.customer_nodes n ON r.region_id = n.region_id
GROUP BY r.region_name

-- 4. How many days on average are customers reallocated to a different node?

WITH days_per_node AS (
	SELECT
		customer_id,
		node_id,
		SUM(end_date - start_date) AS days
	FROM data_bank.customer_nodes
	WHERE DATE_PART('year', end_date) <> 9999
	GROUP BY customer_id, 
		node_id
)

SELECT 
	ROUND(AVG(days), 1) AS avg_days
FROM days_per_node

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH days_per_node AS (
	SELECT
		r.region_name AS region,
		customer_id,
		node_id,
		SUM(end_date - start_date) AS days
	FROM data_bank.customer_nodes n
	JOIN data_bank.regions r ON r.region_id = n.region_id
	WHERE DATE_PART('year', end_date) <> 9999
	GROUP BY region,
		customer_id, 
		node_id
)

SELECT 
	region,
	ROUND(AVG(days), 1) AS avg_days,
	ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days ASC)::NUMERIC, 1) AS median,
	ROUND(PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY days ASC)::NUMERIC, 1) AS percentile_80,
	ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY days ASC)::NUMERIC, 1) AS percentile_95
FROM days_per_node
GROUP BY region


-- B. Customer Transactions

-- 1. What is the unique count and total amount for each transaction type?

SELECT
	DISTINCT(txn_type),
	COUNT(txn_type),
	SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY DISTINCT(txn_type)

-- 2. What is the average total historical deposit counts and amounts for all customers?

SELECT
	COUNT(txn_type) as deposits,
	ROUND(AVG(txn_amount), 2) AS avg_deposit_amount
FROM data_bank.customer_transactions
WHERE txn_type = 'deposit'

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

WITH transactions AS (
	SELECT
		customer_id,
		TO_CHAR(txn_date, 'Month') AS month,
		SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposits,
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchases,
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawals
	FROM data_bank.customer_transactions
	GROUP BY customer_id, month
	ORDER BY customer_id
)

SELECT 
	month,
	COUNT(customer_id) AS customers
FROM transactions
WHERE deposits > 1
	AND (purchases >= 1 OR withdrawals >= 1)
GROUP BY month
	

-- 4. What is the closing balance for each customer at the end of the month?

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?




















