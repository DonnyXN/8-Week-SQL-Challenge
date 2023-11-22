# Case Study #2 - Pizza Runner
https://8weeksqlchallenge.com/case-study-2/

## Introduction



## Questions and Solutions


### A. Pizza Metrics Case Questions


**1. How many pizzas were ordered?**
```sql
SELECT 
    COUNT(order_id) AS pizzas_ordered
FROM 
    customer_orders_clean
```

![image](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/2ae6d0f2-30fa-46fd-b812-6438aabf67a5)

---
**2. How many unique customer orders were made?**
```sql
SELECT
    COUNT(DISTINCT(order_id)) AS unique_customer_ordered
FROM 
    customer_orders_clean
```
![image-1](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/d3d27b5c-8760-493f-a136-811288bea6c1)

---
**3. How many successful orders were delivered by each runner?**
```sql
SELECT
    COUNT(cancellation) AS successful_orders
FROM 
    runner_orders_clean
WHERE cancellation = ''
```
![image-2](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/935c9249-e9cf-4657-b9aa-6b38e8f7813a)

---
**4. How many of each type of pizza was delivered?**
```sql
SELECT 
    co.pizza_id,
    COUNT(co.pizza_id) as pizzas_delivered
FROM 
    customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = '' -- avoid pizzas cancelled
GROUP BY pizza_id
```

![image-3](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/21303d55-7c4f-43db-a400-3a68d6978bbb)

---
**5. How many Vegetarian and Meatlovers were ordered by each customer?**
```sql
SELECT
    co.customer_id,
    COUNT(pi.pizza_name) AS pizzas_ordered
FROM 
    customer_orders_clean co
JOIN pizza_runner.pizza_names pi ON co.pizza_id=pi.pizza_id
GROUP BY co.customer_id
```
![image-4](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/134e95f5-3e11-4f3d-88a0-1a81ab4c4600)

---
**6. What was the maximum number of pizzas delivered in a single order?**
```sql
SELECT
    co.order_id,
    COUNT(co.pizza_id) AS pizza_count
FROM
    customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = '' -- avoid pizzas cancelled
GROUP BY co.order_id
```
![image-5](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/d72c6a6c-8b31-4997-ae81-274c7c90bbe2)

---
**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

```sql
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
```
![image-6](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/3c747298-b12b-47d1-b25f-0188db9c6237)

---
**8. How many pizzas were delivered that had both exclusions and extras?**
```sql
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
```
![image-7](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/5d3417e3-2d50-4296-acad-dd1c5202b2cc)

---
**9. What was the total volume of pizzas ordered for each hour of the day?**
```sql
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour,
    COUNT(order_id) AS pizzas
FROM
    customer_orders_clean co
GROUP BY hour
ORDER BY hour ASC
```
![image-8](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/7ea5f691-0e56-4d99-87ef-19ec544d3237)

---
**10. What was the volume of orders for each day of the week?**
```sql
SELECT 
    TO_CHAR(order_time, 'Dy') AS day,
    COUNT(order_id) AS pizzas
FROM
    customer_orders_clean co
GROUP BY day
ORDER BY day ASC
```
![image-9](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/29e626c8-b5b8-443a-b533-1f5929b5796b)

---
### B. Runner and Customer Experience


**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
```sql
SELECT
    EXTRACT(WEEK FROM registration_date) AS registration_week,
    COUNT(runner_id) AS runner_registration
FROM 
    pizza_runner.runners
GROUP BY registration_week
-- query is returning week 53
```
![image-10](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/262e864e-31ef-4709-b422-bc809af88d0e)

---
**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**
```sql
SELECT 
    ro.runner_id,
    ROUND(AVG(EXTRACT(MINUTE FROM (TO_TIMESTAMP(pickup_time, 'YYYY-MM-DD HH24:MI:SS')) - co.order_time)), 0) AS avg_minutes
FROM 
    runner_orders_clean ro
JOIN customer_orders_clean co ON ro.order_id=co.order_id
WHERE cancellation = ''
GROUP BY ro.runner_id
```
![image-11](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/2ad6c77f-3250-4125-9475-41ad7bcd376c)

---
**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**
```sql
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
```
![image-12](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/7a2a506d-f594-4cd1-a22f-9568c329ae3e)

---
**4. What was the average distance travelled for each customer?**
```sql
SELECT 
    co.customer_id,
    ROUND(AVG(CAST(distance AS NUMERIC)), 1)
FROM 
    customer_orders_clean co
JOIN runner_orders_clean ro ON co.order_id=ro.order_id
WHERE cancellation = ''
GROUP BY co.customer_id
```
![image-13](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/2288a060-168b-400b-b2a9-1ae626d84a86)

---
**5. What was the difference between the longest and shortest delivery times for all orders?**
```sql
SELECT
    (MAX(CAST(duration AS NUMERIC)) - MIN(CAST(duration AS NUMERIC))) AS range
FROM
    runner_orders_clean
WHERE cancellation = ''
```
![image-14](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/080f7010-846f-4b16-ad64-09fb0d8ea016)

---
**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**
```sql
SELECT 
    runner_id,
    order_id,
    ROUND(CAST(distance AS NUMERIC) / CAST(duration AS NUMERIC), 2) * 60 AS speed_km_per_hr
FROM
    runner_orders_clean
WHERE cancellation = ''
ORDER BY runner_id, speed_km_per_hr ASC
```
![image-15](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/fa97d77b-aa25-4814-9077-98ac0f805f72)

---
**7. What is the successful delivery percentage for each runner?**
```sql
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
```
![image-16](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/d77fc841-1f90-4ea5-9409-9757f0b9829e)

---
### C. Ingredient Optimization


**1. What are the standard ingredients for each pizza?**
```sql
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
```
![image-17](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/92cbd4df-6a31-4f6b-91ce-86efb968b99f)


---
**2. What was the most commonly added extra?**
```sql
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
LIMIT 1
```
![image-18](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/97904bbc-5c6b-4e80-8155-a49d264fb16b)

---
**3. What was the most common exclusion?**
```sql
WITH extra_cte AS (
    SELECT
        CAST(UNNEST(STRING_TO_ARRAY(exclusions, ', ')) AS NUMERIC) AS excluded -- separate by comma into own rows
    FROM
        customer_orders_clean
    WHERE exclusions <> ''
)
SELECT 
    COUNT(pt.topping_name) AS exclusion_count,
    pt.topping_name
FROM
    extra_cte t
JOIN pizza_runner.pizza_toppings pt ON t.excluded=pt.topping_id
GROUP BY pt.topping_name
ORDER BY exclusion_count DESC
LIMIT 1
```
![image-19](https://github.com/DonnyXN/8-Week-SQL-Challenge/assets/92007337/a9fe5cdc-cc7d-4f57-a209-08c16bbd34dd)

---
**4. Generate an order item for each record in the customers_orders table in the format of one of the following:**
--		Meat Lovers
--		Meat Lovers - Exclude Beef
--		Meat Lovers - Extra Bacon
--		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers**

**5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients**
    **For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"**

**6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

**2. What if there was an additional $1 charge for any pizza extras?**
    **Add cheese is $1 extra**

**3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**

**4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
    **customer_id**
    **order_id**
    **runner_id**
    **rating**
    **order_time**
    **pickup_time**
    **Time between order and pickup**
    **Delivery duration**
    **Average speed**
    **Total number of pizzas**

**5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**