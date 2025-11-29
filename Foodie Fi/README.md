# 📺 Case Study #3: Foodie-Fi

![ERD – Foodie-Fi](https://8weeksqlchallenge.com/images/case-study-designs/3.png)

Danny launched a new streaming service called Foodie-Fi, where customers can sign up for different subscription plans.  
Let’s answer key business questions using SQL.  

📚 **Table of Contents**
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

---

## Business Task  
This case study is part of the [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-2/).  

---

## Entity Relationship Diagram 
![ERD – Foodie-Fi](https://8weeksqlchallenge.com/images/case-study-3-erd.png)
---

## Question and Solution  

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;
```
**Answer:**

| total_customers |
|-----------------|
| 1000            |

### 2.What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT DATE_FORMAT(start_date, '%Y-%m-01') AS month_start,
       COUNT(*) AS trial_starts
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATE_FORMAT(start_date, '%Y-%m-01')
ORDER BY month_start;
```

**Answer:**

| month_start | trial_starts |
|-------------|--------------|
| 2020-01-01  | 88           |
| 2020-02-01  | 68           |
| 2020-03-01  | 94           |
| 2020-04-01  | 81           |
| 2020-05-01  | 88           |
| 2020-06-01  | 79           |
| 2020-07-01  | 89           |
| 2020-08-01  | 88           |
| 2020-09-01  | 87           |
| 2020-10-01  | 79           |
| 2020-11-01  | 75           |
| 2020-12-01  | 84           |

**Explanation:**

March 2020 had the highest trial sign-ups (94).
February 2020 had the lowest trial sign-ups (68).
Trial sign-ups stayed fairly stable across the year.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

```sql
SELECT p.plan_name,
       COUNT(*) AS plan_count
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY p.plan_name
ORDER BY plan_count DESC;
```
**Answer:**

| plan_name     | plan_count |
|---------------|----------------|
| churn         | 71             |
| pro annual    | 63             |
| pro monthly   | 60             |
| basic monthly | 8              |

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
WITH churned AS (
  SELECT DISTINCT customer_id
  FROM subscriptions
  WHERE plan_id = 4
),
total AS (
  SELECT COUNT(DISTINCT customer_id) AS total_customers
  FROM subscriptions
)
SELECT COUNT(*) AS churned_customers,
       ROUND(COUNT(*) * 100.0 / (SELECT total_customers FROM total), 1) AS churned_percentage
FROM churned;
```

**Answer:**

| churned_customers | churned_percentage |
|-------------------|--------------------|
| 307               | 30.7               |

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
WITH first_plan AS (
  SELECT customer_id,
         plan_id,
         LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
  FROM subscriptions
)
SELECT COUNT(*) AS churn_after_trial,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 0) AS pct_churn_after_trial
FROM first_plan
WHERE plan_id = 0 AND next_plan = 4;
```
**Answer:**

| churn_after_trial | pct_churn_after_trial |
|-------------------|-----------------------|
| 92                | 9                     |


### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
SELECT p.plan_name, COUNT(*) AS cnt,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS pct
FROM subscriptions s1
JOIN subscriptions s2 
  ON s1.customer_id = s2.customer_id
 AND s2.start_date > s1.start_date
JOIN plans p ON s2.plan_id = p.plan_id
WHERE s1.plan_id = 0
  AND s2.start_date = (
        SELECT MIN(start_date) 
        FROM subscriptions s3
        WHERE s3.customer_id = s1.customer_id
          AND s3.start_date > s1.start_date
     )
GROUP BY p.plan_name;
```
**Answer:**

| plan_name     | cnt | pct   |
|---------------|-----|-------|
| basic monthly | 546 | 54.6  |
| pro annual    | 37  | 3.7   |
| pro monthly   | 325 | 32.5  |
| churn         | 92  | 9.2   |


### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
SELECT p.plan_name,
       COUNT(*) AS customer_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS pct
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.start_date = (
    SELECT MAX(start_date)
    FROM subscriptions s2
    WHERE s2.customer_id = s.customer_id
      AND s2.start_date <= '2020-12-31'
)
GROUP BY p.plan_name;
```
**Answer:**

| plan_name     | customer_count | pct   |
|---------------|----------------|-------|
| basic monthly | 224            | 22.4  |
| pro annual    | 195            | 19.5  |
| churn         | 236            | 23.6  |
| pro monthly   | 326            | 32.6  |
| trial         | 19             | 1.9   |



### 8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT COUNT(DISTINCT customer_id) AS cnt
FROM subscriptions
WHERE plan_id = 3
  AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```
**Answer:**

| cnt |
|-----|
| 195 |

### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
SELECT ROUND(AVG(DATEDIFF(a.annual_date, j.join_date)),1) AS avg_days
FROM (
   SELECT customer_id, MIN(start_date) AS join_date
   FROM subscriptions
   GROUP BY customer_id
) j
JOIN (
   SELECT customer_id, MIN(start_date) AS annual_date
   FROM subscriptions
   WHERE plan_id = 3
   GROUP BY customer_id
) a ON j.customer_id = a.customer_id;
```
**Answer:**

| avg_days |
|----------|
| 104.6    |

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
SELECT CASE 
         WHEN DATEDIFF(a.annual_date, j.join_date) BETWEEN 0 AND 30 THEN '0-30'
         WHEN DATEDIFF(a.annual_date, j.join_date) BETWEEN 31 AND 60 THEN '31-60'
         WHEN DATEDIFF(a.annual_date, j.join_date) BETWEEN 61 AND 90 THEN '61-90'
         ELSE '90+'
       END AS day_bucket,
       COUNT(*) AS customers
FROM (
   SELECT customer_id, MIN(start_date) AS join_date
   FROM subscriptions
   GROUP BY customer_id
) j
JOIN (
   SELECT customer_id, MIN(start_date) AS annual_date
   FROM subscriptions
   WHERE plan_id = 3
   GROUP BY customer_id
) a ON j.customer_id = a.customer_id
GROUP BY day_bucket
ORDER BY MIN(DATEDIFF(a.annual_date, j.join_date));
```
**Answer:**

| day_bucket | customers |
|------------|-----------|
| 0-30       | 49        |
| 31-60      | 24        |
| 61-90      | 34        |
| 90+        | 151       |


### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
WITH plan_sequence AS (
  SELECT customer_id,
         plan_id,
         LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan,
         start_date
  FROM subscriptions
)
SELECT COUNT(*) AS downgraded_pro_to_basic_2020
FROM plan_sequence
WHERE plan_id = 2
  AND next_plan = 1
  AND YEAR(start_date) = 2020;
```

**Answer:**

| downgraded_pro_to_basic_2020 |
|------------------------------|
| 0                            |





