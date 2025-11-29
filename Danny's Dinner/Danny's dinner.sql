create database if not exists dinner;
use dinner;

#1. What is the total amount each customer spent at the restaurant

select customer_id,sum(price) as total_spent from sales as s
inner join menu m using(product_id) group by customer_id;

#2. How many days has each customer visited the restaurant?
select customer_id, count(distinct(order_date)) as no_of_visits from sales s group by customer_id; 

# how many times each  customer visited the restaurant?
select customer_id,count(customer_id) as no_of_visits from sales s group by customer_id;

#3. What was the first item from the menu purchased by each customer?
select  customer_id,product_name from(
select *, row_number() over(partition by customer_id) as rn from sales s inner join menu m using(product_id)) as t where rn=1;


#4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    product_name, COUNT(product_name) AS no_of_times_purchased
FROM
    sales s
        INNER JOIN
    menu m USING (product_id)
GROUP BY product_name
ORDER BY COUNT(product_name) DESC
LIMIT 1;


#5. Which item was the most popular for each customer?
select * from(
SELECT 
    customer_id, product_name, COUNT(*) AS popular_item,dense_rank() over(partition by customer_id order by count(*) desc) 
    as drnk
FROM
    sales s
        INNER JOIN menu m USING (product_id)
GROUP BY customer_id , product_name) as t where drnk=1;


#6. Which item was purchased first by the customer after they became a member?

# joins>condition where order date is greater than joing date> condition-first order
select * from(
select s.customer_id,order_date,join_date,product_name,row_number() over(partition by s.customer_id order by order_date asc) as rn
 from sales s inner join menu m using(product_id)
 inner join members as mb on s.customer_id=mb.customer_id and order_date>join_date ) as t where rn = 1;
 
 
 #7. Which item was purchased just before the customer became a member?
 select * from(
select s.customer_id,order_date,join_date,product_name,rank() over(partition by s.customer_id order by order_date desc) as rn
 from sales s inner join menu m using(product_id)
 inner join members as mb on s.customer_id=mb.customer_id and order_date<join_date ) as t where rn = 1;
 
 #8. What is the total items and amount spent for each member before they became a member?
 

select s.customer_id,count(s.customer_id) as no_of_items,sum(price) as total_amount_spent 
from sales s inner join menu m using(product_id)
 inner join members as mb on s.customer_id=mb.customer_id and order_date<join_date group by s.customer_id order by customer_id;
 
 
 #9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


select customer_id,sum(case when product_name="sushi" then price*20
else price *10 end) as total_points
from sales s inner join menu m using(product_id)
group by customer_id;


select customer_id,count(*) as no_of_orders,sum(case when join_date>=order_date  then price*20 else price*10 end) as bonus_points 
from members mb left join sales s using(customer_id)   left join menu m using(product_id) group by customer_id;


select customer_id,count(*) as no_of_orders,sum(price)as total_amount_spent,sum(case when order_date>=join_date then price*20 else price*10 end) as bonus_points,
group_concat(distinct product_name) as product_name
 from sales s 
inner join menu m 
using(product_id) left join members mb 
using(customer_id) group by customer_id;


