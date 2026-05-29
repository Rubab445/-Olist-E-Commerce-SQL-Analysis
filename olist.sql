CREATE TABLE Customer(
	customer_id TEXT, customer_unique_id TEXT, 
    customer_zip_code_prefix TEXT, customer_city TEXT,
    customer_state TEXT
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_customers_dataset.csv' 
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE geolocation(
	geolocation_zip_code_prefix TEXT, geolocation_lat DOUBLE, 
    geolocation_lng DOUBLE, geolocation_city TEXT,
    geolocation_state TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_geolocation_dataset.csv' 
INTO TABLE geolocation 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE order_items(
	order_id TEXT, order_item_id INT, 
    product_id TEXT, seller_id TEXT,
    shipping_limit_date TEXT, price DOUBLE,
    freight_value DOUBLE
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_order_items_dataset.csv' 
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE order_payments(
	order_id TEXT, payment_sequential INT, 
    payment_type TEXT, payment_installments INT,
    payment_value DOUBLE
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_order_payments_dataset.csv' 
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE order_reviews(
	review_id TEXT, order_id TEXT, 
    review_score INT, review_comment_title TEXT,
    review_comment_message TEXT, review_creation_date TEXT,
    review_answer_timestamp TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_order_reviews_dataset.csv' 
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE orders(
	order_id TEXT, customer_id TEXT, 
    order_status TEXT, order_purchase_timestamp TEXT,
    order_approved_at TEXT, order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT, order_estimated_delivery_date TEXT
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_orders_dataset.csv' 
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE products(
	product_id TEXT, product_category_name TEXT, 
    product_name_lenght INT, product_description_lenght INT,
    product_photos_qty INT, product_weight_g INT,
    product_length_cm INT, product_height_cm INT,
    product_width_cm INT
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_products_dataset.csv' 
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE sellers(
	seller_id TEXT, seller_zip_code_prefix TEXT, 
    seller_city TEXT, seller_state TEXT
    
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/olist_sellers_dataset.csv' 
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

CREATE TABLE product_category_translation(
	product_category_name TEXT, product_category_name_english TEXT
    
);

LOAD DATA LOCAL INFILE 'C:/Users/PMLS/OneDrive/Documents/product_category_name_translation.csv' 
INTO TABLE product_category_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- creating staging tables
CREATE TABLE Customer_staging
LIKE Customer;

INSERT INTO Customer_staging
SELECT *
FROM Customer;

CREATE TABLE geolocation_staging
LIKE geolocation;

INSERT INTO geolocation_staging
SELECT *
FROM geolocation;

CREATE TABLE order_items_staging
LIKE order_items;

INSERT INTO order_items_staging
SELECT *
FROM order_items;

CREATE TABLE order_payments_staging
LIKE order_payments;

INSERT INTO order_payments_staging
SELECT *
FROM order_payments;

CREATE TABLE order_reviews_staging
LIKE order_reviews;

INSERT INTO order_reviews_staging
SELECT *
FROM order_reviews;

CREATE TABLE orders_staging
LIKE orders;

INSERT INTO orders_staging
SELECT *
FROM orders;

CREATE TABLE product_category_translation_staging
LIKE product_category_translation;

INSERT INTO product_category_translation_staging
SELECT *
FROM product_category_translation;

CREATE TABLE products_staging
LIKE products;

INSERT INTO products_staging
SELECT *
FROM products;

CREATE TABLE sellers_staging
LIKE sellers;

INSERT INTO sellers_staging
SELECT *
FROM sellers;

SELECT *
FROM orders;

-- 1. Remove duplicates
WITH order_duplicate_cte AS
(
	SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY order_id, customer_id, order_status, order_purchase_timestamp,
    order_approved_at, order_delivered_carrier_date, order_delivered_customer_date,
    order_estimated_delivery_date)
    AS row_num
    FROM orders_staging
)
SELECT * 
FROM order_duplicate_cte
WHERE row_num > 1;

SELECT * 
FROM order_items_staging;

WITH order_item_duplicate_cte AS
(
	SELECT *, 
    ROW_NUMBER() OVER(
    PARTITION BY order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value)
    AS row_num
    FROM order_items_staging
)
SELECT *
FROM order_item_duplicate_cte
WHERE row_num > 1;

SELECT *
FROM products_staging;

WITH product_duplicate_cte AS
(
	SELECT *, 
    ROW_NUMBER() OVER(
    PARTITION BY product_id, product_category_name, product_name_lenght, product_description_lenght,
    product_photos_qty, product_weight_g, product_length_cm,
    product_height_cm, product_width_cm)
    AS row_num
    FROM products_staging
)
SELECT *
FROM product_duplicate_cte
WHERE row_num > 1;

SELECT *
FROM customer_staging;

WITH customer_duplicate_cte AS
(
	SELECT *, 
    ROW_NUMBER() OVER(
    PARTITION BY customer_id, customer_unique_id, customer_zip_code_prefix, 
    customer_city, customer_state)
    AS row_num
    FROM customer_staging
)
SELECT *
FROM customer_duplicate_cte
WHERE row_num > 1;

SELECT *
FROM orders_staging;

-- REMOVE NULL
SELECT *
FROM orders_staging
WHERE order_approved_at IS NULL OR order_approved_at = '';

UPDATE orders_staging
SET order_approved_at = NULL
WHERE order_approved_at = '';

SELECT *
FROM orders_staging AS t1
JOIN orders_staging AS t2
	ON t1.order_id = t2.order_id
		WHERE t1.order_approved_at IS NULL
        AND t2.order_approved_at IS NOT NULL;
        
SELECT *
FROM orders_staging
WHERE order_delivered_carrier_date IS NULL OR order_delivered_carrier_date = '';

UPDATE orders_staging
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

SELECT *
FROM orders_staging AS t1
JOIN orders_staging AS t2
	ON t1.order_id = t2.order_id
		WHERE t1.order_delivered_customer_date IS NULL
        AND t2.order_delivered_customer_date IS NOT NULL;


SELECT *
FROM orders_staging
WHERE order_delivered_customer_date IS NULL OR order_delivered_customer_date = '';

UPDATE orders_staging
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

SELECT *
FROM customer_staging;

SELECT *
FROM customer_staging
WHERE customer_state IS NULL OR customer_state = '';

SELECT *
FROM products_staging;

SELECT *
FROM products_staging
WHERE product_category_name IS NULL OR product_category_name = '';

UPDATE products_staging
SET product_category_name = NULL
WHERE product_category_name = '';

SELECT *
FROM products_staging AS t1
JOIN products_staging AS t2
	ON 	t1.product_id = t2.product_id
	WHERE t1.product_category_name IS NULL
    AND t2.product_category_name IS NOT NULL;

SELECT *
FROM products_staging
WHERE product_description_lenght IS NULL OR product_description_lenght = '';

UPDATE products_staging
SET product_description_lenght = NULL
WHERE product_description_lenght = '';

SELECT *
FROM products_staging AS t1
JOIN products_staging AS t2
	ON 	t1.product_id = t2.product_id
	WHERE t1.product_description_lenght IS NULL
    AND t2.product_description_lenght IS NOT NULL;

SELECT *
FROM products_staging
WHERE product_name_lenght IS NULL OR product_name_lenght = '';

UPDATE products_staging
SET product_name_lenght = NULL
WHERE product_name_lenght = '';

SELECT *
FROM products_staging
WHERE product_photos_qty IS NULL OR product_photos_qty = '';

UPDATE products_staging
SET product_photos_qty = NULL
WHERE product_photos_qty = '';

SELECT *
FROM products_staging
WHERE product_weight_g IS NULL OR product_weight_g = '';

UPDATE products_staging
SET product_weight_g = NULL
WHERE product_weight_g = '';

UPDATE products_staging
SET product_length_cm = NULL
WHERE product_length_cm = '';

UPDATE products_staging
SET product_height_cm = NULL
WHERE product_height_cm = '';

UPDATE products_staging
SET product_width_cm = NULL
WHERE product_width_cm = '';

-- 2. STANDARDIZATION

SELECT * 
FROM orders_staging;

ALTER TABLE orders_staging
MODIFY COLUMN order_purchase_timestamp DATETIME;

ALTER TABLE orders_staging
MODIFY COLUMN order_approved_at DATETIME;

ALTER TABLE orders_staging
MODIFY COLUMN order_delivered_carrier_date DATETIME;

ALTER TABLE orders_staging
MODIFY COLUMN order_delivered_customer_date DATETIME;

ALTER TABLE orders_staging
MODIFY COLUMN order_estimated_delivery_date DATETIME;

SELECT * 
FROM order_items_staging;

ALTER TABLE order_items_staging
MODIFY COLUMN shipping_limit_date DATETIME;

SELECT *
FROM order_reviews_staging;

ALTER TABLE order_reviews_staging
MODIFY COLUMN review_creation_date DATETIME;

ALTER TABLE order_reviews_staging
MODIFY COLUMN review_answer_timestamp DATETIME;

SELECT *
FROM products_staging AS t1
JOIN product_category_translation_staging AS t2
	ON t1.product_category_name = t2.product_category_name;
    
ALTER TABLE products_staging
ADD COLUMN product_category_name_english TEXT;

UPDATE products_staging AS t1
JOIN product_category_translation_staging AS t2
	ON t1.product_category_name = t2.product_category_name
SET t1.product_category_name_english = t2.product_category_name_english;

SELECT product_category_name, product_category_name_english
FROM products_staging;

SELECT COUNT(*)
FROM products_staging
WHERE product_category_name_english IS NULL 
AND product_category_name IS NOT NULL;

SELECT DISTINCT product_category_name
FROM products_staging
WHERE product_category_name_english IS NULL 
AND product_category_name IS NOT NULL;

SELECT *
FROM customer_staging;

UPDATE customer_staging
SET customer_city = UPPER(customer_city);

SELECT seller_city
FROM sellers_staging;

UPDATE sellers_staging
SET seller_city = UPPER(seller_city);

-- Total number of orders and total revenue

SELECT *
FROM products_staging;

SELECT *
FROM order_items_staging;

-- Top 10 product categories by revenue
SELECT 
    t1.product_category_name_english AS product_category,
    SUM(t2.price + t2.freight_value) AS total_revenue
FROM products_staging AS t1
JOIN order_items_staging AS t2
	ON t1.product_id = t2.product_id
WHERE t1.product_category_name_english IS NOT NULL
GROUP BY  product_category
ORDER BY total_revenue DESC
LIMIT 10;

-- Monthly order volume trend
WITH Order_Count_CTE AS
(SELECT order_id, DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS Months
FROM orders_staging)
SELECT Months, COUNT(order_id) AS total_orders
FROM Order_Count_CTE
GROUP BY Months
ORDER BY Months ASC;

-- Total number of orders and total revenue
    
SELECT 
    COUNT(DISTINCT order_id) AS total_orders, 
    SUM(price + freight_value) AS total_revenue
FROM order_items_staging;

-- Orders by status — how many delivered, cancelled, etc.
SELECT 
    order_status, 
    COUNT(order_id) AS total_orders
FROM orders_staging
GROUP BY order_status;

SELECT *
FROM orders_staging;

-- Average delivery time in days 
SELECT  AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS delivery_time
FROM orders_staging
WHERE order_status = 'delivered';

-- Average delivery delay — actual delivery vs estimated delivery (positive = late, negative = early)
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS avg_delay_days
FROM orders_staging
WHERE order_status = 'delivered' ;
  
-- Top 10 states by number of orders
SELECT t1.customer_state AS state, COUNT(t2.order_id) AS orders
FROM customer_staging AS t1
JOIN orders_staging AS t2
	ON t1.customer_id = t2.customer_id
GROUP BY state
ORDER BY orders DESC
LIMIT 10;

-- Average review score by product category — join reviews, orders, order_items, products together
SELECT 
    t1.product_category_name_english AS category, 
    ROUND(AVG(t3.review_score), 2) AS avg_score
FROM products_staging AS t1
JOIN order_items_staging AS t2
	ON t1.product_id = t2.product_id
JOIN order_reviews_staging AS t3
	ON t2.order_id = t3.order_id
WHERE product_category_name_english IS NOT NULL
GROUP BY category
ORDER BY avg_score DESC;

-- Rank product categories by revenue using RANK() or DENSE_RANK()
WITH Category_CTE AS
(
SELECT 
    t1.product_category_name_english AS product_category,
    ROUND(SUM(t2.price + t2.freight_value), 2) AS total_revenue
FROM products_staging AS t1
JOIN order_items_staging AS t2
	ON t1.product_id = t2.product_id
WHERE t1.product_category_name_english IS NOT NULL
GROUP BY  product_category
),
Ranking_CTE AS
(
SELECT product_category, total_revenue, 
DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS ranking
FROM Category_CTE)
SELECT product_category,total_revenue,  ranking 
FROM Ranking_CTE
;

-- Running total of monthly revenue using SUM() OVER
WITH Monthly_CTE AS
(
SELECT DATE_FORMAT(t1.order_purchase_timestamp, '%Y-%m') AS Months, 
SUM(t2.price + t2.freight_value) AS total_revenue
FROM orders_staging AS t1
JOIN order_items_staging AS t2
	ON t1.order_id = t2.order_id
GROUP BY Months
)
SELECT Months, total_revenue,
SUM(total_revenue) OVER(ORDER BY Months ASC) AS rolling_total
FROM  Monthly_CTE
ORDER BY Months ASC
;

-- Customer segmentation — one time buyers vs repeat buyers based on order count
WITH Order_count_CTE AS
(
SELECT 
    customer_id, 
    COUNT(order_id) AS total_count
FROM orders_staging
GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_count = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Buyers'
    END AS buyer_type,
    COUNT(customer_id) AS total_customers
FROM Order_count_CTE
GROUP BY buyer_type;
    

-- Late delivery rate by state — which states receive the most delayed orders as a percentage
SELECT 
    t1.customer_state,
    
    SUM(CASE 
        WHEN t2.order_delivered_customer_date > t2.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END) AS late_orders,
    
    COUNT(t2.order_id) AS total_delivered_orders,
    
    ROUND(
        (SUM(CASE WHEN t2.order_delivered_customer_date > t2.order_estimated_delivery_date THEN 1 ELSE 0 END) 
        / 
        COUNT(t2.order_id)) * 100
    , 2) AS late_delivery_percentage

FROM customer_staging AS t1
JOIN orders_staging AS t2
    ON t1.customer_id = t2.customer_id
WHERE t2.order_status = 'delivered'
GROUP BY t1.customer_state
ORDER BY late_delivery_percentage DESC;

-- Payment method breakdown — what percentage of orders use credit card vs boleto vs voucher vs debit card, 
-- and average installments for credit card orders

SELECT 
    payment_type, 
    ROUND(AVG(payment_installments), 1) AS avg_installments,
    ROUND(
        (COUNT(payment_type) * 100.0) / (SELECT COUNT(order_id) FROM order_payments_staging)
    , 2) AS payment_percentage
FROM order_payments_staging
GROUP BY payment_type;
