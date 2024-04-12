## Bonus Questions

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

