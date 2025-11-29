# 🍕 Case Study #2: Pizza Runner

![ERD – Foodie-Fi](https://8weeksqlchallenge.com/images/case-study-designs/2.png)

📚 **Table of Contents**

* [Business Task](#business-task)
* [Entity Relationship Diagram](#entity-relationship-diagram)
* [Questions and Solutions](#questions-and-solutions)

---

## Business Task

Danny started Pizza Runner — a pizza delivery company. The goal is to analyze customer orders, runner performance, ingredient optimization, and overall business metrics.

---

## Entity Relationship Diagram
<img width="1092" height="617" alt="pizza_runner_ED" src="https://github.com/user-attachments/assets/2ff97e38-f392-401c-a996-1bb07af422e3" />


---

## Questions and Solutions

### A. Pizza Metrics

#### 1. How many pizzas were ordered?
```sql
SELECT COUNT(*) AS cust_orders
FROM customer_orders;


```
**Answer:**

| cust_orders |
|-------------|
| 14          |

**Explanation:** There were 14 pizza items ordered in total (including duplicates in the same order).


#### 2. How many unique customer orders were made?

```sql
SELECT COUNT(DISTINCT order_id) AS unique_cust_id
FROM customer_orders;
```
**Answer:**

| unique_cust_id |
|----------------|
| 10             |

**Explanation:** There were 10 unique customer orders placed, showing that multiple pizzas were ordered in some orders.

#### 3. How many successful orders were delivered by each runner?

```sql
SELECT runner_id,
       COUNT(DISTINCT order_id) AS successful_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
```
**Answer:**

| runner_id | successful_orders |
|-----------|------------------|
| 1         | 4                |
| 2         | 3                |
| 3         | 1                |

**Explanation:** Only orders without cancellations are counted. Runner 1 had the most successful deliveries, followed by Runner 2 and Runner 3.

#### 4. How many of each type of pizza was delivered?

```sql
SELECT pn.pizza_name,
       COUNT(*) AS delivered_count
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
JOIN pizza_names pn USING(pizza_id)
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;
```
**Answer:**

| pizza_name   | delivered_count |
|-------------|----------------|
| Meatlovers  | 9              |
| Vegetarian  | 3              |

**Explanation:** Out of 12 delivered pizzas, 9 were Meatlovers and 3 were Vegetarian.

#### 5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT co.customer_id,
       SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meatlovers_count,
       SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS veg_count
FROM customer_orders co
JOIN pizza_names pn USING(pizza_id)
GROUP BY co.customer_id
ORDER BY co.customer_id;
```

**Answer:**

| customer_id | meatlovers_count | veg_count |
|------------|-----------------|-----------|
| 101        | 2               | 1         |
| 102        | 2               | 1         |
| 103        | 3               | 1         |
| 104        | 3               | 0         |
| 105        | 1               | 1         |

**Explanation:** Customer 103 ordered the most Meatlovers pizzas (3). Customer 101 and 102 each ordered 1 Vegetarian pizza.

#### 6. Maximum number of pizzas delivered in a single order

```sql
SELECT co.order_id,
       COUNT(*) AS pizza_count
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY pizza_count DESC
LIMIT 1;
```


**Answer:**

| order_id | pizza_count |
|----------|-------------|
| 4        | 3           |

**Explanation:** Order 4 contained 3 pizzas, the highest in a single delivery.

#### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT co.customer_id,
       SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS with_changes,
       SUM(CASE WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 1 ELSE 0 END) AS no_changes
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;
```
**Answer:**

| customer_id | with_changes | no_changes |
|-------------|--------------|------------|
| 101         | 0            | 2          |
| 102         | 0            | 2          |
| 103         | 3            | 0          |
| 104         | 2            | 1          |
| 105         | 1            | 0          |

**Explanation:** Customer 103 always requested changes. Customer 101 and 102 never requested changes.

#### 8. How many pizzas were delivered with both exclusions and extras?

```sql
SELECT COUNT(*) AS pizzas_with_changes
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL
  AND co.exclusions IS NOT NULL
  AND co.extras IS NOT NULL;
```
**Answer:**

| pizzas_with_changes |
|--------------------|
| 1                  |

**Explanation:** Only 1 delivered pizza had both exclusions and extras.

#### 9. Total volume of pizzas ordered for each hour of the day?

```sql
SELECT HOUR(order_time) AS order_hour,
       COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY order_hour
ORDER BY order_hour;
```

**Answer:**

| order_hour | total_pizzas |
|------------|--------------|
| 11         | 1            |
| 13         | 3            |
| 18         | 3            |
| 19         | 1            |
| 21         | 3            |
| 23         | 3            |

**Explanation:** The busiest hours were 13, 21, and 23, with 3 pizzas each.

#### 10. Total number of pizzas ordered for each day of the week?

```sql
SELECT DAYNAME(order_time) AS order_day,
       COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY order_day
ORDER BY total_pizzas DESC;
```

**Answer:**

| order_day  | total_pizzas |
|------------|--------------|
| Wednesday  | 5            |
| Saturday   | 5            |
| Friday     | 1            |
| Thursday   | 1            |
| Sunday     | 1            |
| Tuesday    | 1            |

**Explanation:** Wednesday and Saturday were the most popular days with 5 pizzas each.

---

### B. Runner and Customer Experience

#### 1. How many runners signed up for each 1 week period (starting 2021-01-01)?

```sql
SELECT FLOOR(DATEDIFF(registration_date, '2021-01-01')/7) + 1 AS week_number,
       COUNT(runner_id) AS runners_signed_up
FROM runners
GROUP BY week_number
ORDER BY week_number;
```

**Answer:**

| week_number | runners_signed_up |
| ----------- | ----------------- |
| 1           | 2                 |
| 2           | 1                 |
| 3           | 1                 |

**Explanation:** Two runners signed up in the first week, followed by one in week 2 and week 3.

---

#### 2. Average time in minutes it took runners to arrive at Pizza Runner HQ for pickup

```sql
SELECT runner_id,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)),2) AS avg_arrival_time
FROM runner_orders ro
JOIN customer_orders co USING(order_id)
WHERE ro.pickup_time IS NOT NULL
GROUP BY runner_id;
```

**Answer:**

| runner_id | avg_arrival_time |
| --------- | ---------------- |
| 1         | 14.75            |
| 2         | 20.67            |
| 3         | 10.00            |

**Explanation:** Runner 3 was the fastest on average.

---

#### 3. Relationship between number of pizzas per order and preparation time

```sql
SELECT co.order_id,
       COUNT(co.pizza_id) AS pizza_count,
       TIMESTAMPDIFF(MINUTE, MIN(co.order_time), ro.pickup_time) AS prep_time
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
WHERE ro.pickup_time IS NOT NULL
GROUP BY co.order_id, ro.pickup_time;
```

**Answer:**

| order_id | pizza_count | prep_time |
| -------- | ----------- | --------- |
| 1        | 1           | 10        |
| 2        | 1           | 10        |
| 3        | 2           | 21        |
| 4        | 3           | 30        |
| 5        | 1           | 10        |
| 7        | 1           | 10        |
| 8        | 1           | 21        |
| 10       | 2           | 16        |

**Explanation:** More pizzas generally increased preparation time.

---

#### 4. Average distance travelled for each customer

```sql
SELECT co.customer_id,
       ROUND(AVG(ro.distance),2) AS avg_distance
FROM runner_orders ro
JOIN customer_orders co USING(order_id)
WHERE ro.distance IS NOT NULL
GROUP BY co.customer_id;
```

**Answer:**

| customer_id | avg_distance |
| ----------- | ------------ |
| 101         | 20.00        |
| 102         | 18.40        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |

---

#### 5. Difference between longest and shortest delivery times

```sql
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM runner_orders
WHERE duration IS NOT NULL;
```

**Answer:**

| delivery_time_diff |
| ------------------ |
| 30                 |

**Explanation:** The difference between the fastest and slowest deliveries is 30 minutes.

---

#### 6. Average speed for each runner

```sql
SELECT order_id,
       ROUND((distance/(duration/60)),2) AS avg_speed
FROM runner_orders
WHERE distance IS NOT NULL AND duration IS NOT NULL;
```

**Answer:**

| order_id | avg_speed |
| -------- | --------- |
| 1        | 37.50     |
| 2        | 44.44     |
| 3        | 40.20     |
| 4        | 35.10     |
| 5        | 40.00     |
| 7        | 60.00     |
| 8        | 93.60     |
| 10       | 60.00     |

**Explanation:** Runner 2 achieved very high speeds for orders 7 and 8.

---

#### 7. Successful delivery percentage for each runner

```sql
SELECT runner_id,
       ROUND(100*SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS success_rate
FROM runner_orders
GROUP BY runner_id;
```

**Answer:**

| runner_id | success_rate |
| --------- | ------------ |
| 1         | 100.00       |
| 2         | 75.00        |
| 3         | 50.00        |

**Explanation:** Runner 1 has a perfect delivery record, while Runner 3 had the lowest success rate.

---

### C. Ingredient Optimisation

#### 1. How many times was each topping used?

```sql
SELECT pt.topping_name,
       COUNT(*) AS usage_count
FROM pizza_recipes pr
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
JOIN customer_orders co ON co.pizza_id = pr.pizza_id
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL
GROUP BY pt.topping_name
ORDER BY usage_count DESC;
```

**Answer:**

| topping_name | usage_count |
| ------------ | ----------- |
| Cheese       | 9           |
| Mushrooms    | 7           |
| Bacon        | 6           |
| Beef         | 6           |
| Chicken      | 6           |
| Salami       | 6           |
| BBQ Sauce    | 5           |
| Pepperoni    | 5           |
| Tomatoes     | 3           |
| Tomato Sauce | 3           |
| Onions       | 2           |
| Peppers      | 2           |

**Explanation:** Cheese was the most used ingredient.

---

#### 2. Most commonly excluded ingredient

```sql
SELECT pt.topping_name,
       COUNT(*) AS exclusion_count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.exclusions)
GROUP BY pt.topping_name
ORDER BY exclusion_count DESC
LIMIT 1;
```

**Answer:**

| topping_name | exclusion_count |
| ------------ | --------------- |
| Cheese       | 4               |

---

#### 3. Most commonly added extra

```sql
SELECT pt.topping_name,
       COUNT(*) AS extra_count
FROM customer_orders co
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
GROUP BY pt.topping_name
ORDER BY extra_count DESC
LIMIT 1;
```

**Answer:**

| topping_name | extra_count |
| ------------ | ----------- |
| Bacon        | 3           |

---

### D. Pricing and Ratings

#### 1. Revenue if Meat Lovers = $12, Vegetarian = $10

```sql
SELECT SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn USING(pizza_id)
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL;
```

**Answer:**

| total_revenue |
| ------------- |
| 138           |

---

#### 2. Revenue with $1 charge per extra

```sql
SELECT SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END + 
           COALESCE(LENGTH(co.extras)-LENGTH(REPLACE(co.extras,',',''))+1,0)) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn USING(pizza_id)
JOIN runner_orders ro USING(order_id)
WHERE ro.cancellation IS NULL;
```

**Answer:**

| total_revenue |
| ------------- |
| 142           |

---

#### 3. Profit after paying runners $0.30/km

```sql
WITH pizza_revenue AS (
  SELECT co.order_id,
         SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END + 
             COALESCE(LENGTH(co.extras)-LENGTH(REPLACE(co.extras,',',''))+1,0)) AS order_revenue
  FROM customer_orders co
  JOIN pizza_names pn USING(pizza_id)
  JOIN runner_orders ro USING(order_id)
  WHERE ro.cancellation IS NULL
  GROUP BY co.order_id
),
runner_pay AS (
  SELECT order_id,
         distance*0.3 AS pay
  FROM runner_orders
  WHERE cancellation IS NULL
)
SELECT SUM(p.order_revenue) - SUM(r.pay) AS profit
FROM pizza_revenue p
JOIN runner_pay r USING(order_id);
```

**Answer:**

| profit |
| ------ |
| 118.44 |

---

### E. Ratings System (New Table)

#### 1. New table schema

```sql
CREATE TABLE runner_ratings (
  rating_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT,
  runner_id INT,
  rating INT CHECK (rating BETWEEN 1 AND 5),
  rating_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  comments VARCHAR(200)
);
```

#### 2. Example data

```sql
INSERT INTO runner_ratings (order_id, runner_id, rating, comments) VALUES
(1, 1, 5, 'Very fast and friendly'),
(2, 1, 4, 'Good delivery but a little late'),
(3, 2, 5, 'Perfect timing!'),
(4, 3, 3, 'Average experience'),
(5, 2, 4, 'Quick but forgot to call'),
(7, 1, 5, 'Excellent service!'),
(8, 2, 4, 'Good speed, polite runner'),
(10, 1, 5, 'Super quick and professional');
```

#### 3. Joined report with all details

```sql
SELECT co.customer_id,
       co.order_id,
       ro.runner_id,
       rr.rating,
       co.order_time,
       ro.pickup_time,
       TIMEDIFF(ro.pickup_time, co.order_time) AS time_to_pickup,
       ro.duration,
       ROUND(ro.distance/(ro.duration/60),2) AS avg_speed,
       COUNT(co.pizza_id) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro USING(order_id)
JOIN runner_ratings rr USING(order_id)
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating,
         co.order_time, ro.pickup_time, ro.duration, ro.distance;
```

**Answer:**

| customer_id | order_id | runner_id | rating | order_time          | pickup_time         | time_to_pickup | duration | avg_speed | total_pizzas |
| ----------- | -------- | --------- | ------ | ------------------- | ------------------- | -------------- | -------- | --------- | ------------ |
| 101         | 1        | 1         | 5      | 2020-01-01 18:05:02 | 2020-01-01 18:15:34 | 00:10:32       | 32       | 37.50     | 1            |
| 101         | 2        | 1         | 4      | 2020-01-01 19:00:52 | 2020-01-01 19:10:54 | 00:10:02       | 27       | 44.44     | 1            |
| 102         | 3        | 1         | 5      | 2020-01-02 23:51:23 | 2020-01-03 00:12:37 | 00:21:14       | 20       | 40.20     | 2            |
| 103         | 4        | 2         | 3      | 2020-01-04 13:23:46 | 2020-01-04 13:53:03 | 00:29:17       | 40       | 35.10     | 3            |
| 104         | 5        | 3         | 4      | 2020-01-08 21:00:29 | 2020-01-08 21:10:57 | 00:10:28       | 15       | 40.00     | 1            |
| 105         | 7        | 2         | 5      | 2020-01-08 21:20:29 | 2020-01-08 21:30:45 | 00:10:16       | 25       | 60.00     | 1            |
| 102         | 8        | 2         | 4      | 2020-01-09 23:54:33 | 2020-01-10 00:15:02 | 00:20:29       | 15       | 93.60     | 1            |
| 104         | 10       | 1         | 5      | 2020-01-11 18:34:49 | 2020-01-11 18:50:20 | 00:15:31       | 10       | 60.00     | 2            |

**Explanation:** This consolidated report combines customer, runner, ratings, and delivery performance data.

---



