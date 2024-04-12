# Case Study #1 - Danny's Diner
https://8weeksqlchallenge.com/case-study-1/

## Introduction 
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!



## Questions And Solutions
**1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT sales.customer_id, 
        SUM(menu.price) AS total_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON sales.product_id=menu.product_id
GROUP BY sales.customer_id
```

| customer_id | total_spent |
| ----------- | ----------- |
| B           | 74          |
| C           | 36          |
| A           | 76          |

---

**2. How many days has each customer visited the restaurant?**
```sql
SELECT sales.customer_id, 
        COUNT(DISTINCT sales.order_date) AS days_visited
FROM dannys_diner.sales
GROUP BY sales.customer_id
```

| customer_id | days_visited |
| ----------- | ------------ |
| A           | 4            |
| B           | 6            |
| C           | 2            |

---

**3. What was the first item from the menu purchased by each customer?**
```sql
    WITH temp_table AS (
    	SELECT *, 
    		   DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS ordered_date
    	FROM dannys_diner.sales
    	JOIN dannys_diner.menu ON sales.product_id=menu.product_id
    )
    SELECT customer_id, product_name
    FROM temp_table
    WHERE ordered_date = 1
    GROUP BY customer_id, product_name
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---


**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
**Schema (PostgreSQL v13)**

```sql
SELECT menu.product_name, 
   COUNT(menu.product_name) AS purchased
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id=menu.product_id
GROUP BY menu.product_name
ORDER BY purchased DESC
LIMIT 1
```
| product_name | purchased |
| ------------ | --------- |
| ramen        | 8         |

---

**5. Which item was the most popular for each customer?**
```sql
WITH temp_table AS (
SELECT sales.customer_id, 
           menu.product_name, 
           COUNT(menu.product_id) AS order_count,
           DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(menu.product_name)) AS product_rank
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id=menu.product_id
GROUP BY sales.customer_id, menu.product_name
)
SELECT customer_id, product_name
FROM temp_table
WHERE product_rank = 1
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | ramen        |
| B           | curry        |
| B           | sushi        |
| C           | ramen        |

---

**6. Which item was purchased first by the customer after they became a member?**
```sql
WITH temp_table AS (
SELECT sales.customer_id, 
           sales.product_id, 
           DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS date_ranked
FROM dannys_diner.members
JOIN dannys_diner.sales ON members.customer_id = sales.customer_id 
WHERE members.join_date < sales.order_date
)
SELECT temp_table.customer_id, 
   menu.product_name
FROM temp_table
Join dannys_diner.menu ON temp_table.product_id=menu.product_id
WHERE date_ranked = 1
ORDER BY temp_table.customer_id ASC
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

---

**7. Which item was purchased just before the customer became a member?**
```sql
WITH temp_table AS (
SELECT sales.customer_id, 
           sales.product_id, 
           DENSE_RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS date_ranked
FROM dannys_diner.members
JOIN dannys_diner.sales ON members.customer_id=sales.customer_id 
WHERE members.join_date > sales.order_date
)
SELECT temp_table.customer_id, 
   menu.product_name
FROM temp_table
Join dannys_diner.menu ON temp_table.product_id=menu.product_id
WHERE date_ranked = 1
ORDER BY temp_table.customer_id ASC
```

| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| A           | curry        |
| B           | sushi        |

---

**8. What is the total items and amount spent for each member before they became a member?**
```sql
SELECT members.customer_id, 
   COUNT(sales.product_id) as total_items, 
   SUM(menu.price) AS total_spent
FROM dannys_diner.members
JOIN dannys_diner.sales ON members.customer_id=sales.customer_id AND members.join_date > sales.order_date
JOIN dannys_diner.menu ON sales.product_id=menu.product_id
GROUP BY members.customer_id
ORDER BY members.customer_id ASC
```
| customer_id | total_items | total_spent |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 40          |

---

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
WITH temp_table AS (
SELECT *,
           CASE
                   WHEN product_id = 1 THEN price * 20
                   ELSE price * 10
           END AS points
FROM dannys_diner.menu 
)
SELECT sales.customer_id, 
   SUM(temp_table.points) AS total_points
FROM temp_table 
JOIN dannys_diner.sales ON sales.product_id=temp_table.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC
```
| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

---

**10.   In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**
```sql
WITH temp_table AS (
SELECT customer_id,
           join_date,
           join_date + 6 AS eo_week,
           DATE_TRUNC('month', '2021-01-01'::date) + interval '1 month' - interval '1 day' AS eo_month
FROM dannys_diner.members
)
SELECT sales.customer_id,
   SUM(CASE
                   WHEN sales.product_id = 1 THEN menu.price * 20
                   WHEN sales.order_date BETWEEN te.join_date AND te.eo_week THEN menu.price * 20
                   ELSE price * 10
           END) AS points
FROM temp_table te
JOIN dannys_diner.sales ON te.customer_id = sales.customer_id
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
WHERE sales.order_date <= te.eo_month AND sales.order_date >= te.join_date
GROUP BY sales.customer_id
ORDER BY sales.customer_id ASC;
```
| customer_id | points |
| ----------- | ------ |
| A           | 1020   |
| B           | 320    |

---

### Bonus Questions

**Join All The Things**
```sql
SELECT sales.customer_id, 
   sales.order_date, 
   menu.product_name, 
   menu.price,
   CASE 
           WHEN sales.order_date >= members.join_date THEN 'Y'
           WHEN sales.order_date < members.join_date THEN 'N'
           ELSE 'N'
   END AS member
FROM dannys_diner.sales
JOIN dannys_diner.menu ON menu.product_id = sales.product_id
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
ORDER BY sales.customer_id, sales.order_date ASC;
```

| customer_id | order_date               | product_name | price | member |
| ----------- | ------------------------ | ------------ | ----- | ------ |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |


---

**Rank All The Things**
```sql
WITH temp_table AS (
SELECT sales.customer_id, 
           sales.product_id, 
           sales.order_date,
           CASE 
                   WHEN sales.order_date >= members.join_date THEN 'Y'
                   WHEN sales.order_date < members.join_date THEN 'N'
                   ELSE 'N'
           END AS member
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members ON sales.customer_id = members.customer_id
)
SELECT temp_table.customer_id, 
   temp_table.order_date, 
   menu.product_name, 
   menu.price,
   temp_table.member,
   CASE
           WHEN temp_table.member = 'N' THEN null
           ELSE DENSE_RANK() OVER (PARTITION BY temp_table.customer_id, temp_table.member ORDER BY temp_table.order_date ASC)
   END AS ranking
FROM temp_table
JOIN dannys_diner.menu ON menu.product_id = temp_table.product_id
ORDER BY temp_table.customer_id, temp_table.order_date ASC;
```

| customer_id | order_date               | product_name | price | member | ranking |
| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |

---

