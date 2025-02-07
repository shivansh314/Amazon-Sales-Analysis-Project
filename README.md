---

# **Amazon Sales Analysis Project**

### **Difficulty Level: Advanced**

---

## **Project Overview**

I analyzed a dataset of 20,000+ sales records from an Amazon-like e-commerce platform, using PostgreSQL to explore customer behavior, product performance, and sales trends. This project involved solving SQL challenges like revenue analysis, customer segmentation, and inventory management.

Additionally, it focused on data cleaning, handling null values, and addressing real-world business problems through structured queries. 

An ERD diagram is included to illustrate the database schema and table relationships.

---

![Image](https://github.com/user-attachments/assets/3741d9ee-15cd-4a38-a779-5c9f2d8822f6)

## **Database Setup & Design**

### **Schema Structure**

```sql
-- Amazon sql project 
-- parent table - that doesnt depend on other table 
DROP TABLE IF EXISTS shippings;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category;



-- Category table 
create table category (
	category_id int primary key , 
	category_name varchar(20)
);



-- customer table 
create table customers (
	customer_id int primary key , 
	first_name varchar(20),
	last_name varchar(20),
	state varchar(20)
	--address varchar(5) default ('*****')
);

-- sellers table 

create table sellers (
	seller_id int primary key , 
	seller_name varchar(25), 
	origin varchar(25)
);

alter table sellers alter column origin type varchar(25);

-- product table 
create table products (
	product_id int primary key,
	product_name varchar(50),
	price float , 
	cogs float , 
	category_id int , -- fk 
	constraint product_fk_category foreign key(category_id) references category(category_id)
);

-- order table 

create table orders (
	order_id int primary key  , 
	order_date date , 
	customer_id int , -- fk
	seller_id int, -- fk 
	order_status varchar(15) ,
	constraint orders_fk_customers foreign key (customer_id) references customers(customer_id),
	constraint orders_fk_sellers foreign key (seller_id) references sellers(seller_id)
);

-- order_items table ( additional information about the order )

create table order_items (
	order_item_id int primary key , 
	order_id int, -- fk 
	product_id int ,--fk 
	quantity int , 
	price_per_unit float ,
	constraint order_items_fk_orders foreign key (order_id) references orders(order_id),
	constraint order_items_fk_products foreign key ( product_id) references products(product_id)
);

-- payment 
create table payments ( 
	payment_id int primary key , 
	order_id int ,
	payment_date DATE,
	payment_status varchar(20),
	constraint payments_fk_orders foreign key (order_id) references orders(order_id)
);

-- shippings table 
create table shippings (
	shipping_id int primary key ,
	order_id int,  -- fk
	shipping_date date, 
	return_date date,
	shipping_providers varchar(15) , 
	delivery_status varchar(15) , 
	constraint shipping_fk_orders foreign key (order_id) references orders(order_id)
);

-- inventory table 

create table inventory ( 
	inventory_id int primary key ,
	product_id int , -- fk  
	stock int , 
	warehouse_id int , 
	last_stock_date date, 
	constraint inventory_fk_products foreign key(product_id) references products(product_id)
);

create table transactions (
	purchase_id int primary key ,
	customer_id int ,
	product_id int,
	purchase_date date,
	total_spent float
)

```

---

## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---

## **Objective**

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations, including:
- Customer behavior
- Sales trends
- Inventory management
- Payment and shipping analysis
- Forecasting and product performance
  

## **Identifying Business Problems**

Key business problems identified:
1. Low product availability due to inconsistent restocking.
2. High return rates for specific product categories.
3. Significant delays in shipments and inconsistencies in delivery times.
4. High customer acquisition costs with a low customer retention rate.

---

## **Solving Business Problems**

### Solutions Implemented:
1. Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.

```sql
alter table order_items 
add column total_sales float;

update  order_items
set total_sales = quantity * price_per_unit;

with cte as (
	select p.product_name  , o.order_id , oi.order_item_id , oi.quantity , oi.total_sales 
	from orders as  o
	join order_items as oi 
	on o.order_id = oi.order_id
	join products as p 
	on oi.product_id = p.product_id 
) select  product_name  , count(quantity) as quantity ,   sum(total_sales) as total_sales  from cte 
group by product_name   order by sum(total_sales)
desc limit 10 ; 

```

2. Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.

```sql
with cte as (
	select p.product_name , p.category_id ,  o.order_id , oi.product_id , oi.total_sales  from orders as o 
	join order_items as oi on o.order_id = oi.order_id
	join products as p on oi.product_id = p.product_id 
), 
 cte_1 as (
	select category_id , ROUND(SUM(total_sales)) AS total_sales  from cte 
	group by 1   
)SELECT c1.category_id, 
		ct.category_name , 
       c1.total_sales, 
       CONCAT(ROUND(cast((total_sales * 100.0) / (SELECT SUM(total_sales) FROM cte_1) as decimal(10 , 2)) ,2 ) , ' %') AS percentage  
FROM cte_1 AS c1
LEFT JOIN category as ct on c1.category_id = ct.category_id ;

```

3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.

```sql

SELECT 
	c.customer_id,
	CONCAT(c.first_name, ' ',  c.last_name) as full_name,
	SUM(total_sales)/COUNT(o.order_id) as AOV,
	COUNT(o.order_id) as total_orders --- filter
FROM orders as o
JOIN 
customers as c
ON c.customer_id = o.customer_id
JOIN 
order_items as oi
ON oi.order_id = o.order_id
GROUP BY 1, 2
HAVING  COUNT(o.order_id) > 5
order by COUNT(o.order_id) desc ;

```

4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!

```sql
select 
year , month , total_sale as current_month_sale ,
lag(total_sale , 1 ) over() as last_month_sale
from (
	select 
	extract(month from order_date) as month ,
	extract ( year from order_date) as year , 
	round(sum(oi.total_sales :: numeric ) , 2 ) as total_sale  
	from orders as o
	join 
	order_items as oi 
	on oi.order_id = o.order_id 
	where o.order_date >=  current_date - interval '2 year' 
	group by 1,2 
	order by 2,1 
)
```


5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.

```sql
select 
concat( c.first_name , ' ' , c.last_name ) ,
c.customer_id ,
c.state 
from 
customers as c left outer join
orders as o
on c.customer_id = o.customer_id 
where o.customer_id is null 

```

6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.

```sql

with ranking_categories as ( 
select   
 c.state , p.category_id  ,  sum(oi.total_sales)
 , rank() over(partition by c.state order by sum ( oi.total_sales) asc  ) as ranking
from order_items as oi 
join products as p 
on oi.product_id = p.product_id 
join orders as o 
on oi.order_id = o.order_id 
join 
customers as c  on c.customer_id = o.customer_id
group by c.state , p.category_id
order by 1 , 2
)
select * from ranking_categories 
where ranking = 1 

```


7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.

```sql

with rank_table as (
	select  c.customer_id , c.first_name , count(o.order_id) , sum(oi.total_sales) as total_spent from orders as o 
	join order_items as oi on o.order_id = oi.order_id
	join customers as c on o.customer_id = c.customer_id 
	group by 1 , 2 
	order by 4 desc 	
) select * , rank() over(order by total_spent desc ) as rank from rank_table ;

```


8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.

```sql
SELECT 
	i.inventory_id,
	p.product_name,
	i.stock as current_stock_left,
	i.last_stock_date,
	i.warehouse_id
FROM inventory as i
join 
products as p
ON p.product_id = i.product_id
WHERE stock < 10
```

9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.

```sql

select o.order_id , o.order_date , s.shipping_date ,s.shipping_providers ,  (s.shipping_date - o.order_date) as number_of_days 
from 
orders as o 
join 
shippings as s on o.order_id = s.order_id 
where (s.shipping_date - o.order_date) > 3 ;


```

10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).

```sql
SELECT 
	p.payment_status,
	COUNT(*) as total_cnt,
	COUNT(*)::numeric/(SELECT COUNT(*) FROM payments)::numeric * 100 as percentage 
FROM orders as o
JOIN
payments as p
ON o.order_id = p.order_id
GROUP BY 1
```

11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.

```sql
WITH top_sellers
AS
(SELECT 
	s.seller_id,
	s.seller_name,
	SUM(oi.total_sales) as total_sale
FROM orders as o
JOIN
sellers as s
ON o.seller_id = s.seller_id
JOIN 
order_items as oi
ON oi.order_id = o.order_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5
),
sellers_table 
AS
(SELECT 
	o.seller_id,
	ts.seller_name,
	o.order_status,
	COUNT(*) as total_orders
FROM orders as o
JOIN 
top_sellers as ts
ON ts.seller_id = o.seller_id
WHERE 
	o.order_status NOT IN ('Inprogress', 'Returned')
GROUP BY 1, 2, 3
)
SELECT 
	seller_id,
	seller_name,
	SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END) as Completed_orders,
	SUM(CASE WHEN order_status = 'Cancelled' THEN total_orders ELSE 0 END) as Cancelled_orders,
	SUM(total_orders) as total_orders,
	SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END)::numeric/
	SUM(total_orders)::numeric * 100 as successful_orders_percentage
FROM sellers_table
GROUP BY 1, 2
```


12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/


```sql

select * , dense_rank() over(order by profit_margin desc ) as profit_ranking  from (
select p.product_id ,  p.product_name ,
--( oi.total_sales - (p.cogs * oi.quantity))   as profit
SUM(oi.total_sales - (p.cogs * oi.quantity))/sum(oi.total_sales) * 100 as profit_margin
from products as p  
join order_items as oi 
on p.product_id = oi.product_id 
group by 1 , 2
) as profit_margin_table 
```

13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.

```sql

SELECT 
	p.product_id,
	p.product_name,
	COUNT(*) as total_unit_sold,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returned,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric/COUNT(*)::numeric * 100 as return_percentage
FROM order_items as oi
JOIN 
products as p
ON oi.product_id = p.product_id
JOIN orders as o
ON o.order_id = oi.order_id
GROUP BY 1, 2
ORDER BY 5 DESC

```

14.  Orders Pending Shipment
Find orders that have been paid but are still pending shipment.
Challenge: Include order details, payment date, and customer information.

```sql
select * from shippings where delivery_status = 'Shipped'; 

select o.order_id , o.customer_id, p.payment_date   from shippings as s
join orders as o on o.order_id = s.order_id 
join payments as p on s.order_id = p.order_id 
where s.delivery_status = 'Shipped' and p.payment_status = 'Payment Successed' ; 


```

15. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.

```sql
select MAX(order_date) from orders  ;
select distinct seller_id from orders 

WITH cte1 AS (
    SELECT seller_id 
    FROM sellers   -- seller 53 , 54  have not sold anything 
    WHERE seller_id NOT IN (
        SELECT seller_id 
        FROM orders 
        WHERE order_date >= CURRENT_DATE - INTERVAL '1 year'
    )
)
SELECT 
    o.seller_id,
    MAX(o.order_date) AS last_sale_date,  -- Latest sale date
    SUM(oi.total_sales) AS last_sale_amount  -- Sum of sales for the latest order
FROM orders o
JOIN cte1 ON cte1.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.seller_id;

```


16. IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns

```sql
WITH cte1 AS (
    SELECT 
        customer_id, 
        COUNT(*) AS number_of_orders,
        CASE 
            WHEN COUNT(*) > 5 THEN 'returning' 
            ELSE 'new' 
        END AS customer_status , 
		sum ( case when order_status = 'Returned' then 1 else 0 end ) as number_of_returned 
    FROM orders
    GROUP BY customer_id
)
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    c1.*
FROM cte1 AS c1
JOIN customers AS c ON c1.customer_id = c.customer_id
ORDER BY c1.number_of_orders ASC;


```

17. Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.
```sql
SELECT * FROM 
(SELECT 
	c.state,
	CONCAT(c.first_name, ' ', c.last_name) as customers,
	COUNT(o.order_id) as total_orders,
	SUM(total_sales) as total_sale,
	DENSE_RANK() OVER(PARTITION BY c.state ORDER BY COUNT(o.order_id) DESC) as rank
FROM orders as o
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN 
customers as c
ON 
c.customer_id = o.customer_id
GROUP BY 1, 2
) as t1
WHERE rank <=5
```

18. Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.

```sql
SELECT 
	s.shipping_providers,
	COUNT(o.order_id) as order_handled,
	SUM(oi.total_sales) as total_sale,
	COALESCE(AVG(s.return_date - s.shipping_date), 0) as average_days
FROM orders as o
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN 
shippings as s
ON 
s.order_id = o.order_id
GROUP BY 1
```

19. Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result
Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year)

```sql
WITH last_year_sale
as
(
SELECT 
	p.product_id,
	p.product_name,
	SUM(oi.total_sales) as revenue
FROM orders as o
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN 
products as p
ON 
p.product_id = oi.product_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2022
GROUP BY 1, 2
),

current_year_sale
AS
(
SELECT 
	p.product_id,
	p.product_name,
	SUM(oi.total_sale) as revenue
FROM orders as o
JOIN 
order_items as oi
ON oi.order_id = o.order_id
JOIN 
products as p
ON 
p.product_id = oi.product_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023
GROUP BY 1, 2
)

SELECT
	cs.product_id,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	ls.revenue - cs.revenue as rev_diff,
	ROUND((cs.revenue - ls.revenue)::numeric/ls.revenue::numeric * 100, 2) as reveneue_dec_ratio
FROM last_year_sale as ls
JOIN
current_year_sale as cs
ON ls.product_id = cs.product_id
WHERE 
	ls.revenue > cs.revenue
ORDER BY 5 DESC
LIMIT 10
```


20. Final Task: Stored Procedure
Create a stored procedure that, when a product is sold, performs the following actions:
Inserts a new sales record into the orders and order_items tables.
Updates the inventory table to reduce the stock based on the product and quantity purchased.
The procedure should ensure that the stock is adjusted immediately after recording the sale.

```SQL

CREATE OR REPLACE PROCEDURE add_sales (
    p_order_id INT,
    p_customer_id INT,
    p_seller_id INT,
    p_order_item_id INT,
    p_product_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_count INT;
    v_price FLOAT;
    v_product VARCHAR(50);
BEGIN
    -- Fetch product price and name based on product ID
    SELECT price, product_name
    INTO v_price, v_product
    FROM products
    WHERE product_id = p_product_id;
    
    -- Check stock availability in inventory
    SELECT COUNT(*)
    INTO v_count
    FROM inventory
    WHERE product_id = p_product_id AND stock >= p_quantity;
    
    IF v_count > 0 THEN
        -- Insert into orders table
        INSERT INTO orders (order_id, order_date, customer_id, seller_id)
        VALUES (p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);

        -- Insert into order_items table
        INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price_per_unit, total_sales)
        VALUES (p_order_item_id, p_order_id, p_product_id, p_quantity, v_price, v_price * p_quantity);

        -- Update inventory stock
        UPDATE inventory
        SET stock = stock - p_quantity
        WHERE product_id = p_product_id;
        
        -- Success message
        RAISE NOTICE 'Thank you! Product: % sale has been added, and inventory stock updated.', v_product; 
    ELSE
        -- Insufficient stock message
        RAISE NOTICE 'Product: % is not available in sufficient quantity.', v_product;
    END IF;
END;
$$;

CALL add_sales(
    25005,  -- order_id
    2,      -- customer_id
    5,      -- seller_id
    25004,  -- order_item_id
    1,      -- product_id (AirPods 3rd Gen)
    14      -- quantity
);


SELECT COUNT(*) 
FROM inventory
WHERE product_id = 1 AND stock <= 56;

select * from inventory ; 




```



**Testing Store Procedure**
call add_sales
(
25005, 2, 5, 25004, 1, 14
);

---

---

## **Learning Outcomes**

This project enabled me to:
- Design and implement a normalized database schema.
- Clean and preprocess real-world datasets for analysis.
- Use advanced SQL techniques, including window functions, subqueries, and joins.
- Conduct in-depth business analysis using SQL.
- Optimize query performance and handle large datasets efficiently.

---

## **Conclusion**

This advanced SQL project successfully demonstrates my ability to solve real-world e-commerce problems using structured queries. From improving customer retention to optimizing inventory and logistics, the project provides valuable insights into operational challenges and solutions.

By completing this project, I have gained a deeper understanding of how SQL can be used to tackle complex data problems and drive business decision-making.


