-- Digital Analysis

-- 1. How many users are there?

SELECT
	COUNT(DISTINCT(user_id))
FROM clique_bait.users

-- 2. How many cookies does each user have on average?

SELECT
	ROUND(1.0 * COUNT(cookie_id) / COUNT(DISTINCT(user_id)), 2) AS cookies_per_user
FROM clique_bait.users

-- 3. What is the unique number of visits by all users per month?

SELECT
	TO_CHAR(event_time, 'Month') AS month,
	COUNT(DISTINCT(visit_id)) AS visits
FROM clique_bait.events
GROUP BY TO_CHAR(event_time, 'Month')

-- 4. What is the number of events for each event type?

SELECT 
	event_type,
	COUNT(event_type)
FROM clique_bait.events
GROUP BY event_type

-- 5. What is the percentage of visits which have a purchase event?

SELECT 
	ROUND(100.0 * COUNT(DISTINCT(e.visit_id)) / (SELECT COUNT(DISTINCT(visit_id)) FROM clique_bait.events), 2) AS percent
FROM clique_bait.events e
LEFT JOIN clique_bait.event_identifier i ON e.event_type = i.event_type
WHERE i.event_name = 'Purchase'

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH view_checkout AS (
	SELECT
		SUM(CASE WHEN page_name = 'Checkout' AND event_name = 'Page View' THEN 1 ELSE 0 END) AS checkout,
		SUM(CASE WHEN event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
)
SELECT
	ROUND((100.0 * checkout / purchase), 2) - 100 AS percent
FROM view_checkout

-- 7. What are the top 3 pages by number of views?

SELECT 
	page_name,
	COUNT(DISTINCT(visit_id)) AS views
FROM clique_bait.events e
LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
GROUP BY page_name
ORDER BY views DESC
LIMIT 3

-- 8. What is the number of views and cart adds for each product category?

SELECT 
	ph.product_category,
	SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_view,
	SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds
FROM clique_bait.events e
LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
WHERE ph.product_category is not null
GROUP BY ph.product_category


-- 9. What are the top 3 products by purchases?

SELECT 
	ph.product_id,
	ph.page_name,
	ph.product_category,
	COUNT(ei.event_name) AS purchases
FROM clique_bait.events e
LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
WHERE ph.product_id is not null
GROUP BY ph.product_id, 
	ph.page_name, 
	ph.product_category
ORDER BY purchases DESC
LIMIT 3


-- Product Funnel Analysis
-- 1. Using a single SQL query - create a new output table which has the following details:

-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?

WITH product_page AS (
	SELECT 
		DISTINCT(e.visit_id),
		ph.page_name AS product_name,
		ph.product_id,
		SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS Viewed,
		SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS added_to_cart
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ph.product_id is not null
	GROUP BY DISTINCT(e.visit_id), ph.page_name, ph.product_id
),
purchases AS (
	SELECT
		DISTINCT(e.visit_id)
	FROM clique_bait.events e
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
),
combined_table AS(
	SELECT
		pi.product_name,
		pi.product_id,
		pi.viewed,
		pi.added_to_cart,
		CASE WHEN p.visit_id is not null THEN 1 ELSE 0 END AS purchase
	FROM product_page pi
	LEFT JOIN purchases p ON pi.visit_id = p.visit_id
),
product_info AS (
	SELECT
		product_name,
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
	FROM combined_table
	GROUP BY product_name, product_id
	ORDER BY product_id ASC
)
SELECT
	*
FROM product_info

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

WITH product_page AS (
	SELECT 
		DISTINCT(e.visit_id),
		ph.product_category,
		SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS Viewed,
		SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS added_to_cart
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ph.product_category is not null
	GROUP BY DISTINCT(e.visit_id), ph.product_category
),
purchases AS (
	SELECT
		DISTINCT(e.visit_id)
	FROM clique_bait.events e
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
),
combined_table AS(
	SELECT
		pi.product_category,
		pi.viewed,
		pi.added_to_cart,
		CASE WHEN p.visit_id is not null THEN 1 ELSE 0 END AS purchase
	FROM product_page pi
	LEFT JOIN purchases p ON pi.visit_id = p.visit_id
),
product_info AS (
	SELECT
		product_category,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
	FROM combined_table
	GROUP BY product_category
)
SELECT
	*
FROM product_info


-- Use your 2 new output tables - answer the following questions:

-- 1. Which product had the most views, cart adds and purchases?

	-- Oyster has the most views
	-- Lobster has the most cart adds and purchases
	
-- 2. Which product was most likely to be abandoned?

	-- Russian Caviar is most likely to be abandoned

-- 3. Which product had the highest view to purchase percentage?

WITH product_page AS (
	SELECT 
		DISTINCT(e.visit_id),
		ph.page_name AS product_name,
		ph.product_id,
		SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS Viewed,
		SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS added_to_cart
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ph.product_id is not null
	GROUP BY DISTINCT(e.visit_id), ph.page_name, ph.product_id
),
purchases AS (
	SELECT
		DISTINCT(e.visit_id)
	FROM clique_bait.events e
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
),
combined_table AS(
	SELECT
		pi.product_name,
		pi.product_id,
		pi.viewed,
		pi.added_to_cart,
		CASE WHEN p.visit_id is not null THEN 1 ELSE 0 END AS purchase
	FROM product_page pi
	LEFT JOIN purchases p ON pi.visit_id = p.visit_id
),
product_info AS (
	SELECT
		product_name,
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
	FROM combined_table
	GROUP BY product_name, product_id
	ORDER BY product_id ASC
)
SELECT
	product_name,
	ROUND(100.0 * purchases / viewed, 2) AS view_purchase_ratio_pct
FROM product_info
ORDER BY view_purchase_ratio_pct DESC

	-- Lobster has the highest view to purchase percentage

-- 4. What is the average conversion rate from view to cart add?

WITH product_page AS (
	SELECT 
		DISTINCT(e.visit_id),
		ph.page_name AS product_name,
		ph.product_id,
		SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS Viewed,
		SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS added_to_cart
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ph.product_id is not null
	GROUP BY DISTINCT(e.visit_id), ph.page_name, ph.product_id
),
purchases AS (
	SELECT
		DISTINCT(e.visit_id)
	FROM clique_bait.events e
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
),
combined_table AS(
	SELECT
		pi.product_name,
		pi.product_id,
		pi.viewed,
		pi.added_to_cart,
		CASE WHEN p.visit_id is not null THEN 1 ELSE 0 END AS purchase
	FROM product_page pi
	LEFT JOIN purchases p ON pi.visit_id = p.visit_id
),
product_info AS (
	SELECT
		product_name,
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
	FROM combined_table
	GROUP BY product_name, product_id
	ORDER BY product_id ASC
)
SELECT
	ROUND(AVG(100.0 * added_to_cart / viewed), 2) AS avg_view_cart_pct
FROM product_info

	-- 60.95%

-- 5. What is the average conversion rate from cart add to purchase?

WITH product_page AS (
	SELECT 
		DISTINCT(e.visit_id),
		ph.page_name AS product_name,
		ph.product_id,
		SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS Viewed,
		SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS added_to_cart
	FROM clique_bait.events e
	LEFT JOIN clique_bait.page_hierarchy ph ON e.page_id = ph.page_id
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ph.product_id is not null
	GROUP BY DISTINCT(e.visit_id), ph.page_name, ph.product_id
),
purchases AS (
	SELECT
		DISTINCT(e.visit_id)
	FROM clique_bait.events e
	LEFT JOIN clique_bait.event_identifier ei ON e.event_type = ei.event_type
	WHERE ei.event_name = 'Purchase'
),
combined_table AS(
	SELECT
		pi.product_name,
		pi.product_id,
		pi.viewed,
		pi.added_to_cart,
		CASE WHEN p.visit_id is not null THEN 1 ELSE 0 END AS purchase
	FROM product_page pi
	LEFT JOIN purchases p ON pi.visit_id = p.visit_id
),
product_info AS (
	SELECT
		product_name,
		product_id,
		SUM(viewed) AS viewed,
		SUM(added_to_cart) AS added_to_cart,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
		SUM(CASE WHEN added_to_cart = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
	FROM combined_table
	GROUP BY product_name, product_id
	ORDER BY product_id ASC
)
SELECT
	ROUND(AVG(100.0 * purchases / added_to_cart), 2) AS avg_cart_to_purchase
FROM product_info

	-- 75.93%
	
	
-- C. Campaigns Analysis
-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:

-- user_id
-- visit_id
-- visit_start_time: the earliest event_time for each visit
-- page_views: count of page views for each visit
-- cart_adds: count of product cart add events for each visit
-- purchase: 1/0 flag if a purchase event exists for each visit
-- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
-- impression: count of ad impressions for each visit
-- click: count of ad clicks for each visit
-- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

SELECT 
  u.user_id, 
  e.visit_id, 
  MIN(e.event_time) AS visit_start_time,
  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
  SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchases,
  c.campaign_name,
  SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression, 
  SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click, 
  STRING_AGG(CASE WHEN p.product_id IS NOT NULL AND e.event_type = 2 THEN p.page_name ELSE NULL END, 
    ', ' ORDER BY e.sequence_number) AS cart_products
FROM clique_bait.users u
INNER JOIN clique_bait.events e
  ON u.cookie_id = e.cookie_id
LEFT JOIN clique_bait.campaign_identifier c ON e.event_time BETWEEN c.start_date AND c.end_date
LEFT JOIN clique_bait.page_hierarchy p ON e.page_id = p.page_id
GROUP BY u.user_id,
	e.visit_id,
	c.campaign_name


-- Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

-- Some ideas you might want to investigate further include:

-- Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event

WITH campaign_summary AS (
	SELECT 
	  u.user_id, 
	  e.visit_id, 
	  MIN(e.event_time) AS visit_start_time,
	  SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS page_views,
	  SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS cart_adds,
	  SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) AS purchases,
	  c.campaign_name,
	  SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS impression, 
	  SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS click, 
	  STRING_AGG(CASE WHEN p.product_id IS NOT NULL AND e.event_type = 2 THEN p.page_name ELSE NULL END, 
		', ' ORDER BY e.sequence_number) AS cart_products
	FROM clique_bait.users u
	INNER JOIN clique_bait.events e
	  ON u.cookie_id = e.cookie_id
	LEFT JOIN clique_bait.campaign_identifier c ON e.event_time BETWEEN c.start_date AND c.end_date
	LEFT JOIN clique_bait.page_hierarchy p ON e.page_id = p.page_id
	GROUP BY u.user_id,
		e.visit_id,
		c.campaign_name
)
SELECT 
	COUNT(DISTINCT user_id) AS received_impressions
FROM campaign_summary
WHERE impression > 0
AND campaign_name IS NOT NULL

-- Does clicking on an impression lead to higher purchase rates?
-- What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
-- What metrics can you use to quantify the success or failure of each campaign compared to eachother?
