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




select * from transactions limit 50 ; 




























 