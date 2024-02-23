/*1.  What is the total amount each customer spent at the restaurant?*/
select s.customer_id, sum(m.price)
from sales s
LEFT JOIN menu m
ON s.product_id=m.product_id
group by customer_id;

/*2. How many days has each customer visited the restaurant?*/
select customer_id, count( distinct order_date) as number_of_visits
from sales
group by customer_id;

/*3. What was the first item from the menu purchased by each customer?*/
with cle as(
select distinct s.customer_id,m.product_id,s.order_date,m.product_name, rank() over(partition by s.customer_id order by s.order_date) as rnk
from sales s
left join menu m 
on s.product_id=m.product_id)
select customer_id, group_concat(product_name separator ',') as item
from cle
where rnk= 1
group by customer_id;

/*4. What is the most purchased item on the menu and how many times was it purchased by all customers?
*/
select distinct s.product_id , m.product_name ,count(s.product_id) as total_number
from sales s
join menu m
on s.product_id=m.product_id
group by s.product_id,m.product_name
order by total_number desc;

/*5. Which item was the most popular for each customer? */
with cte as(
select s.customer_id,m.product_name,s.product_id,rank() over(partition by s.customer_id order by count(s.product_id)desc) as rnk
from sales s
join menu m
on s.product_id=m.product_id 
group by s.customer_id,s.product_id,m.product_name)
select customer_id, group_concat(product_name separator ',') as fav_items
from cte
where rnk =1
group by customer_id;

/*6. Which item was purchased first by the customer after they became a member?*/
with cte as(
select s.customer_id,s.product_id,m.product_name,s.order_date , rank() over(partition by s.customer_id order by s.order_date) as rnk
from sales s
join menu m
on s.product_id= m.product_id
join members mem
on s.customer_id=mem.customer_id and s.order_date>= mem.join_date)
SELECT customer_id, product_name as first_order
from cte
WHERE rnk = 1
GROUP BY customer_id;

/*7. Which item was purchased just before the customer became a member?*/
with cte as(
select s.customer_id,s.order_date,m.product_name,rank() over(partition by s.customer_id order by s.order_date desc) as rnk
from sales s
join menu m
on s.product_id=m.product_id
join members mem
on s.customer_id=mem.customer_id and s.order_date<mem.join_date)
select customer_id,order_date,group_concat(product_name separator',') as before_order
from cte
where rnk=1
group by customer_id;

/*8. What is the total items and amount spent for each member before they became a member?*/

SELECT s.customer_id
    ,  COUNT(distinct s.product_id) AS total_items
    ,  SUM(m.price) AS total_amount
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id
JOIN members mem 
    ON mem.customer_id = s.customer_id
    AND s.order_date < mem.join_date
where order_date< join_date
GROUP BY s.customer_id;

/*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/

SELECT s.customer_id
    ,  SUM(case WHEN m.product_name = 'sushi'
		THEN m.price * 20 
		ELSE m.price * 10 
	   END) AS total_points
FROM sales s
JOIN menu m
    ON s.product_id = m.product_id 
GROUP BY s.customer_id;
