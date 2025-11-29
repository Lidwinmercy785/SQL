<img width="730" height="747" alt="danny dinner " src="https://github.com/user-attachments/assets/d4a1d336-33af-4bbf-be9e-41745be8eb48" />

**📚 Table of Contents**
- Business Task
- Entity Relationship Diagram
- Question and Solution     
Please note that all the information regarding the case study has been sourced from the following link: https://8weeksqlchallenge.com/case-study-1/ 

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. 

***


**Entity Relationship Diagram**
<img width="873" height="381" alt="image" src="https://github.com/user-attachments/assets/b3238879-3cc6-417c-8a44-66044d8b6560" />

## Question and Solution

**1. What is the total amount each customer spent at the restaurant?**

````sql
SELECT 
    customer_id, SUM(price) AS total_amount
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
GROUP BY customer_id;
````

#### Steps:
- Use **JOIN** to merge `dannys_diner.sales` and `dannys_diner.menu` tables as `sales.customer_id` and `menu.price` are from both tables.
- Use **SUM** to calculate the total sales contributed by each customer.
- Group the aggregated results by `sales.customer_id`. 

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT 
    customer_id, COUNT(DISTINCT order_date) AS No_of_Visited
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
GROUP BY customer_id;
````

#### Steps:
- To determine the unique number of visits for each customer, utilize **COUNT(DISTINCT `order_date`)**.
- It's important to apply the **DISTINCT** keyword while calculating the visit count to avoid duplicate counting of days. For instance, if Customer A visited the restaurant twice on '2021–01–07', counting without **DISTINCT** would result in 2 days instead of the accurate count of 1 day.

#### Answer:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4          |
| B           | 6          |
| C           | 2          |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

**3. What was the first item from the menu purchased by each customer?**

````sql
select customer_id,product_name from (
select *,rank() over(partition by customer_id order by order_date asc) as rn
from sales s inner join menu m using(product_id)) as t
where rn = 1 group by customer_id,product_name;
````

#### Steps:
- Create a Common Table Expression (CTE) named `ordered_sales_cte`. Within the CTE, create a new column `rank` and calculate the row number using **DENSE_RANK()** window function. The **PARTITION BY** clause divides the data by `customer_id`, and the **ORDER BY** clause orders the rows within each partition by `order_date`.
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, which represents the first row within each `customer_id` partition.
- Use the GROUP BY clause to group the result by `customer_id` and `product_name`.

#### Answer:
| customer_id | product_name | 
| ----------- | ----------- |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.

I have received feedback suggesting the use of `ROW_NUMBER()` instead of `DENSE_RANK()` for determining the "first order" in this question. 

However, since the `order_date` does not have a timestamp, it is impossible to determine the exact sequence of items ordered by the customer. 

Therefore, it would be inaccurate to conclude that curry is the customer's first order purely based on the alphabetical order of the product names. For this reason, I maintain my solution of using `DENSE_RANK()` and consider both curry and sushi as Customer A's first order.

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT 
    product_name, COUNT(*) AS Most_Purchased_Item
FROM
    menu AS m
        INNER JOIN
    sales s USING (product_id)
GROUP BY product_name
ORDER BY COUNT(*) DESC
LIMIT 1;
````

#### Steps:
- Perform a **COUNT** aggregation on the `product_id` column and **ORDER BY** the result in descending order using `most_purchased` field.
- Apply the **LIMIT** 1 clause to filter and retrieve the highest number of purchased items.

#### Answer:
| most_purchased | product_name | 
| ----------- | ----------- |
| 8       | ramen |


- Most purchased item on the menu is ramen which is 8 times. Yummy!

***

**5. Which item was the most popular for each customer?**

````sql
select customer_id,product_name,No_of_Purchased from (
select customer_id,product_name,count(*) as No_of_Purchased,
dense_rank() over(partition by customer_id order by count(*) desc) as drnk
 from sales s inner join menu m 
using(product_id) group by customer_id,product_name) as t where drnk = 1;
````

*Each user may have more than 1 favourite item.*

#### Steps:
- Create a CTE named `fav_item_cte` and within the CTE, join the `menu` table and `sales` table using the `product_id` column.
- Group results by `sales.customer_id` and `menu.product_name` and calculate the count of `menu.product_id` occurrences for each group. 
- Utilize the **DENSE_RANK()** window function to calculate the ranking of each `sales.customer_id` partition based on the count of orders **COUNT(`sales.customer_id`)** in descending order.
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, representing the rows with the highest order count for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ---------- |------------  |
| A           | ramen        |  3   |
| B           | sushi        |  2   |
| B           | curry        |  2   |
| B           | ramen        |  2   |
| C           | ramen        |  3   |

- Customer A and C's favourite item is ramen.
- Customer B enjoys all items on the menu. He/she is a true foodie, sounds like me.

***

**6. Which item was purchased first by the customer after they became a member?**

```sql
select customer_id,product_name from (
select *,dense_rank() over(partition by customer_id order by order_date asc) as drnk
from sales as s inner join menu as m using(product_id)
inner join members mb using(customer_id) where s.order_date>mb.join_date)
as t where drnk = 1;
```

#### Steps:
- Create a CTE named `joined_as_member` and within the CTE, select the appropriate columns and calculate the row number using the **ROW_NUMBER()** window function. The **PARTITION BY** clause divides the data by `members.customer_id` and the **ORDER BY** clause orders the rows within each `members.customer_id` partition by `sales.order_date`.
- Join tables `dannys_diner.members` and `dannys_diner.sales` on `customer_id` column. Additionally, apply a condition to only include sales that occurred *after* the member's `join_date` (`sales.order_date > members.join_date`).
- In the outer query, join the `joined_as_member` CTE with the `dannys_diner.menu` on the `product_id` column.
- In the **WHERE** clause, filter to retrieve only the rows where the row_num column equals 1, representing the first row within each `customer_id` partition.
- Order result by `customer_id` in ascending order.

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | ramen        |
| B           | sushi        |

- Customer A's first order as a member is ramen.
- Customer B's first order as a member is sushi.

***

**7. Which item was purchased just before the customer became a member?**

````sql
select customer_id,product_name from (
select *,row_number() over(partition by customer_id order by order_date desc) as rn
 from sales s inner join menu m using(product_id)
inner join members mb using(customer_id) where s.order_date<mb.join_date) as t
where rn = 1;
````

#### Steps:
- Create a CTE called `purchased_prior_member`. 
- In the CTE, select the appropriate columns and calculate the rank using the **ROW_NUMBER()** window function. The rank is determined based on the order dates of the sales in descending order within each customer's group.
- Join `dannys_diner.members` table with `dannys_diner.sales` table based on the `customer_id` column, only including sales that occurred *before* the customer joined as a member (`sales.order_date < members.join_date`).
- Join `purchased_prior_member` CTE with `dannys_diner.menu` table based on `product_id` column.
- Filter the result set to include only the rows where the rank is 1, representing the earliest purchase made by each customer before they became a member.
- Sort the result by `customer_id` in ascending order.

#### Answer:
| customer_id | product_name |
| ----------- | ---------- |
| A           | Curry        |
| B           | sushi        |

- Both customers' last order before becoming members are sushi.

***

**8. What is the total items and amount spent for each member before they became a member?**

```sql
SELECT 
    customer_id,
    COUNT(*) AS Total_Items,
    SUM(price) AS Total_Amount_Spent
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
        INNER JOIN
    members mb USING (customer_id)
WHERE
    order_date < join_date
GROUP BY customer_id;
```

#### Steps:
- Select the columns `sales.customer_id` and calculate the count of `sales.product_id` as total_items for each customer and the sum of `menu.price` as total_sales.
- From `dannys_diner.sales` table, join `dannys_diner.members` table on `customer_id` column, ensuring that `sales.order_date` is earlier than `members.join_date` (`sales.order_date < members.join_date`).
- Then, join `dannys_diner.menu` table to `dannys_diner.sales` table on `product_id` column.
- Group the results by `sales.customer_id`.
- Order the result by `sales.customer_id` in ascending order.

#### Answer:
| customer_id | total_items | total_sales |
| ----------- | ---------- |----------  |
| A           | 2 |  25       |
| B           | 3 |  40       |

Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?**

```sql
SELECT 
    customer_id,
    SUM(CASE
        WHEN product_name = 'Sushi' THEN price * 20
        ELSE Price * 10
    END) AS Total_Points
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
GROUP BY customer_id;
```

#### Steps:
Let's break down the question to understand the point calculation for each customer's purchases.
- Each $1 spent = 10 points. However, `product_id` 1 sushi gets 2x points, so each $1 spent = 20 points.
- Here's how the calculation is performed using a conditional CASE statement:
	- If product_id = 1, multiply every $1 by 20 points.
	- Otherwise, multiply $1 by 10 points.
- Then, calculate the total points for each customer.

#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 860 |
| B           | 940 |
| C           | 360 |

- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

```sql
SELECT 
    customer_id,
    SUM(CASE
        WHEN join_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 7 DAY) THEN price * 20
        WHEN product_name = 'sushi' THEN price * 20
        ELSE price * 10
    END) AS total_points
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
        INNER JOIN
    members mb USING (customer_id)
WHERE
    MONTH(order_date) = '01'
GROUP BY customer_id;
```


#### Answer:
| customer_id | total_points | 
| ----------- | ---------- |
| A           | 1520       |
| B           | 1240       |

- Total points for Customer A is 1,520.
- Total points for Customer B is 1,240.

***

## BONUS QUESTIONS

**Join All The Things**

**Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)**

```sql
SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN order_date >= join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
        LEFT JOIN
    members mb USING (customer_id);
```
 
#### Answer: 
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | -------------| ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

***

**Rank All The Things**

**Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.**

```sql
with CTE as (
SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
        LEFT JOIN
    members mb USING (customer_id))

select *,
    CASE 
		WHEN member = "N" then null 
        ELSE dense_rank() over(partition by customer_id, member order by order_date asc) end as Ranking 
	from CTE;
```

#### Answer: 
| customer_id | order_date | product_name | price | member | ranking | 
| ----------- | ---------- | -------------| ----- | ------ |-------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL
| A           | 2021-01-01 | curry        | 15    | N      | NULL
| A           | 2021-01-07 | curry        | 15    | Y      | 1
| A           | 2021-01-10 | ramen        | 12    | Y      | 2
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| A           | 2021-01-11 | ramen        | 12    | Y      | 3
| B           | 2021-01-01 | curry        | 15    | N      | NULL
| B           | 2021-01-02 | curry        | 15    | N      | NULL
| B           | 2021-01-04 | sushi        | 10    | N      | NULL
| B           | 2021-01-11 | sushi        | 10    | Y      | 1
| B           | 2021-01-16 | ramen        | 12    | Y      | 2
| B           | 2021-02-01 | ramen        | 12    | Y      | 3
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-01 | ramen        | 12    | N      | NULL
| C           | 2021-01-07 | ramen        | 12    | N      | NULL

***




