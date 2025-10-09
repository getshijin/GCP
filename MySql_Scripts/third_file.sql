-- Clean slate
DROP DATABASE IF EXISTS shopdb;
CREATE DATABASE shopdb;
USE shopdb;

-- Customers
CREATE TABLE customers (
  customer_id INT PRIMARY KEY AUTO_INCREMENT,
  email       VARCHAR(120) NOT NULL,
  full_name   VARCHAR(120) NOT NULL,
  country     VARCHAR(60)  NOT NULL,
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
  product_id   INT PRIMARY KEY AUTO_INCREMENT,
  category     VARCHAR(60) NOT NULL,
  name         VARCHAR(120) NOT NULL,
  price_cents  INT NOT NULL CHECK (price_cents >= 0)
);

-- Orders (header)
CREATE TABLE orders (
  order_id     INT PRIMARY KEY AUTO_INCREMENT,
  customer_id  INT NOT NULL,
  order_date   DATETIME NOT NULL,
  status       ENUM('pending','paid','shipped','cancelled') NOT NULL,
  total_cents  INT NOT NULL CHECK (total_cents >= 0),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order items (lines)
CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id      INT NOT NULL,
  product_id    INT NOT NULL,
  qty           INT NOT NULL CHECK (qty > 0),
  unit_cents    INT NOT NULL CHECK (unit_cents >= 0),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);


###########inserting data


-- Allow deeper recursion for data generation
SET SESSION cte_max_recursion_depth = 50000;

-- Numbers helper (1..50000)
WITH RECURSIVE seq(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 50000
)
SELECT 1; -- noop to materialize CTE once

-- Customers (~10k)
INSERT INTO customers (email, full_name, country, created_at)
WITH RECURSIVE c(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM c WHERE n < 10000
)
SELECT CONCAT('user', n, '@example.com'),
       CONCAT('Customer ', n),
       ELT(1 + (n % 5), 'DE','IN','US','UK','FR'),
       DATE_ADD('2023-01-01', INTERVAL (n % 400) DAY)
FROM c;

-- Products (~1k)
INSERT INTO products (category, name, price_cents)
WITH RECURSIVE p(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM p WHERE n < 1000
)
SELECT ELT(1 + (n % 8),'Books','Games','Electronics','Shoes','Apparel','Toys','Grocery','Beauty'),
       CONCAT('Product ', n),
       100 + (n % 5000)
FROM p;

-- Orders (~50k)
INSERT INTO orders (customer_id, order_date, status, total_cents)
WITH RECURSIVE o(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM o WHERE n < 50000
)
SELECT
  1 + (n % 10000),                                   -- customer_id
  DATE_ADD('2024-01-01', INTERVAL (n % 365) DAY),    -- order_date
  ELT(1 + (n % 4), 'pending','paid','shipped','cancelled'),
  1000 + (n % 50000)
FROM o;

-- This runs within depth 50,000 but produces 150,000 rows
INSERT INTO order_items (order_id, product_id, qty, unit_cents)
WITH RECURSIVE i(n) AS (
  SELECT 1 UNION ALL SELECT n+1 FROM i WHERE n < 50000
),
t3(k) AS (
  SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2
)
SELECT
  1 + (((k * 50000) + n) % 50000) AS order_id,
  1 + (((k * 50000) + n) % 1000)  AS product_id,
  1 + (((k * 50000) + n) % 5)     AS qty,
  100 + (((k * 50000) + n) % 5000) AS unit_cents
FROM i
CROSS JOIN t3;



select * from customers;
select * from products;
select * from orders;
select * from order_items;




-- Q1: Date function in WHERE blocks index use (we’ll index later)
EXPLAIN SELECT *
FROM orders
WHERE YEAR(order_date) = 2024 AND status = 'paid';

-- Q2: Join + filter on non-indexed columns
EXPLAIN SELECT o.order_id, c.email, o.total_cents
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE c.country = 'DE' AND o.status = 'shipped'
ORDER BY o.order_date DESC
LIMIT 50;

-- Q3: Text search with leading wildcard (can’t use normal index)
EXPLAIN SELECT product_id, name
FROM products
WHERE name LIKE '%duct 99%';

-- Q4: OR on two different columns (often causes full scans)
EXPLAIN SELECT *
FROM customers
WHERE country = 'DE' OR email LIKE 'user12%';

-- For Q1: filter by (order_date, status) → composite index
CREATE INDEX ix_orders_date_status ON orders (order_date, status);

-- For Q2: join + filter → indexes on join and filters
CREATE INDEX ix_orders_status_date ON orders (status, order_date);
CREATE INDEX ix_customers_country ON customers (country);

-- For Q3: full-text search instead of leading wildcard LIKE (alternative)
-- (Fulltext works on InnoDB, MySQL 5.6+; but only for natural-language modes)
ALTER TABLE products ADD FULLTEXT ft_products_name (name);

-- For Q4: handle with two targeted indexes
CREATE INDEX ix_customers_email ON customers (email);
CREATE INDEX ix_customers_country2 ON customers (country);
