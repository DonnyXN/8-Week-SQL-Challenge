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
-- 7. What are the top 3 pages by number of views?
-- 8. What is the number of views and cart adds for each product category?
-- 9. What are the top 3 products by purchases?