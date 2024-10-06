USE DB_Assignment_3;








SELECT 
* FROM merchants LIMIT 10;
CREATE TABLE merchants (
    mid INT PRIMARY KEY,
    name VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
    
);





SELECT 
* FROM products LIMIT 10;
CREATE TABLE products (
    pid INT PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    description TEXT
);




SELECT 
* FROM sell LIMIT 10;
CREATE TABLE sell (
    mid INT,
    pid INT,
    price DECIMAL(10, 2),
    quantity_available INT,
    FOREIGN KEY (mid) REFERENCES merchants(mid),
    FOREIGN KEY (pid) REFERENCES products(pid)
    
    
);


SELECT *
 FROM orders LIMIT 10;
CREATE TABLE orders (
    oid INT PRIMARY KEY,
    shipping_method VARCHAR(50),
    shipping_cost DECIMAL(10, 2)
);




SELECT 
* FROM contain LIMIT 10;

CREATE TABLE contain (
    oid INT,
    pid INT,
    FOREIGN KEY (oid) REFERENCES orders(oid),
    FOREIGN KEY (pid) REFERENCES products(pid)
);



SELECT 
* FROM customers LIMIT 10;
CREATE TABLE customers (
    cid INT PRIMARY KEY,
    fullname VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
);



SELECT 
* FROM place LIMIT 10;
CREATE TABLE place (
    cid INT,
    oid INT,
    order_date DATE,
    FOREIGN KEY (cid) REFERENCES customers(cid),
    FOREIGN KEY (oid) REFERENCES orders(oid)
);





SELECT merchant_name, fullname, total_spent
FROM CustomerSpend
WHERE (merchant_name, total_spent) IN (
    SELECT merchant_name, MAX(total_spent) FROM CustomerSpend GROUP BY merchant_name
    UNION ALL
    SELECT merchant_name, MIN(total_spent) FROM CustomerSpend GROUP BY merchant_name
);




-- Ensure tables are only created if they don't exist
CREATE TABLE IF NOT EXISTS merchants (
    mid INT PRIMARY KEY,
    name VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    pid INT PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(100),
    description TEXT
);

CREATE TABLE IF NOT EXISTS sell (
    mid INT,
    pid INT,
    price DECIMAL(10, 2),
    quantity_available INT,
    FOREIGN KEY (mid) REFERENCES merchants(mid),
    FOREIGN KEY (pid) REFERENCES products(pid)
);

CREATE TABLE IF NOT EXISTS orders (
    oid INT PRIMARY KEY,
    shipping_method VARCHAR(50),
    shipping_cost DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS contain (
    oid INT,
    pid INT,
    FOREIGN KEY (oid) REFERENCES orders(oid),
    FOREIGN KEY (pid) REFERENCES products(pid)
);

CREATE TABLE IF NOT EXISTS customers (
    cid INT PRIMARY KEY,
    fullname VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS place (
    cid INT,
    oid INT,
    order_date DATE,
    FOREIGN KEY (cid) REFERENCES customers(cid),
    FOREIGN KEY (oid) REFERENCES orders(oid)
);

-- Example query to check data
SELECT * FROM merchants LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM sell LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM contain LIMIT 10;
SELECT * FROM customers LIMIT 10;
SELECT * FROM place LIMIT 10;





/*
Assignment requirements
*/


-- 1. List names and sellers of products that are no longer available (quantity = 0)
SELECT p.name AS product_name, m.name AS merchant_name
FROM products p
JOIN sell s ON p.pid = s.pid
JOIN merchants m ON s.mid = m.mid
WHERE s.quantity_available = 0;

-- 2. List names and descriptions of products that are not sold
SELECT p.name, p.description
FROM products p
LEFT JOIN sell s ON p.pid = s.pid
WHERE s.pid IS NULL;

-- 3. How many customers bought SATA drives but not any routers?
SELECT COUNT(DISTINCT c.cid) AS customer_count
FROM customers c
JOIN place pl ON c.cid = pl.cid
JOIN contain ct ON pl.oid = ct.oid
JOIN products p ON ct.pid = p.pid
WHERE p.name LIKE '%SATA%'
AND c.cid NOT IN (
    SELECT c2.cid
    FROM customers c2
    JOIN place pl2 ON c2.cid = pl2.cid
    JOIN contain ct2 ON pl2.oid = ct2.oid
    JOIN products p2 ON ct2.pid = p2.pid
    WHERE p2.name LIKE '%Router%'
);

-- 4. Apply a 20% sale on HP's Networking products
UPDATE sell s
JOIN products p ON s.pid = p.pid
JOIN merchants m ON s.mid = m.mid
SET s.price = s.price * 0.80
WHERE m.name = 'HP' AND p.category = 'Networking';

-- 5. Retrieve what Uriel Whitney ordered from Acer (product names and prices)
SELECT p.name AS product_name, s.price
FROM customers c
JOIN place pl ON c.cid = pl.cid
JOIN contain ct ON pl.oid = ct.oid
JOIN products p ON ct.pid = p.pid
JOIN sell s ON p.pid = s.pid
JOIN merchants m ON s.mid = m.mid
WHERE c.fullname = 'Uriel Whitney' AND m.name = 'Acer';

-- 6. List the annual total sales for each company
SELECT m.name AS merchant_name, YEAR(pl.order_date) AS year, SUM(s.price * ct.quantity) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN contain ct ON s.pid = ct.pid
JOIN place pl ON ct.oid = pl.oid
GROUP BY m.name, YEAR(pl.order_date)
ORDER BY m.name, year;

-- 7. Which company had the highest annual revenue and in what year?
SELECT merchant_name, year, total_sales
FROM (
    SELECT m.name AS merchant_name, YEAR(pl.order_date) AS year, SUM(s.price * ct.quantity) AS total_sales
    FROM merchants m
    JOIN sell s ON m.mid = s.mid
    JOIN contain ct ON s.pid = ct.pid
    JOIN place pl ON ct.oid = pl.oid
    GROUP BY m.name, YEAR(pl.order_date)
) AS annual_sales
ORDER BY total_sales DESC
LIMIT 1;

-- 8. On average, what was the cheapest shipping method used ever?
SELECT shipping_method, AVG(shipping_cost) AS avg_cost
FROM orders
GROUP BY shipping_method
ORDER BY avg_cost ASC
LIMIT 1;

-- 9. What is the best sold ($) category for each company?
SELECT m.name AS merchant_name, p.category, SUM(s.price * ct.quantity) AS total_sales
FROM merchants m
JOIN sell s ON m.mid = s.mid
JOIN products p ON s.pid = p.pid
JOIN contain ct ON s.pid = ct.pid
JOIN place pl ON ct.oid = pl.oid
GROUP BY m.name, p.category
ORDER BY merchant_name, total_sales DESC;

-- 10. For each company, find out which customers have spent the most and the least amounts
WITH CustomerSpend AS (
    SELECT m.name AS merchant_name, c.fullname, SUM(s.price * ct.quantity) AS total_spent
    FROM merchants m
    JOIN sell s ON m.mid = s.mid
    JOIN contain ct ON s.pid = ct.pid
    JOIN place pl ON ct.oid = pl.oid
    JOIN customers c ON pl.cid = c.cid
    GROUP BY m.name, c.fullname
)
SELECT merchant_name, fullname, total_spent
FROM CustomerSpend
WHERE (merchant_name, total_spent) IN (
    SELECT merchant_name, MAX(total_spent) FROM CustomerSpend GROUP BY merchant_name
    UNION ALL
    SELECT merchant_name, MIN(total_spent) FROM CustomerSpend GROUP BY merchant_name
);
