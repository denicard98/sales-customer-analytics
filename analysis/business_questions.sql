/* ============================================================
   Sales & Customer Analytics — Business Questions
   SQL Server / T-SQL
   Run against the SQL_Practice database (see database/schema_setup.sql)
   ============================================================ */

USE SQL_Practice;
GO


/* ------------------------------------------------------------
   Q1. Which customers are generating actual commercial activity?
   List all completed orders with order ID, date, customer name,
   country and payment method. Most recent orders first.
   ------------------------------------------------------------ */
SELECT
    o.order_id,
    o.order_date,
    c.first_name,
    c.country,
    o.payment_method
FROM Orders AS o
INNER JOIN Customers AS c
    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
ORDER BY o.order_date DESC;


/* ------------------------------------------------------------
   Q2. Which customers placed the most completed orders?
   Customer name, country and number of completed orders.
   Only customers with at least 2 completed orders,
   ordered from most to fewest.
   ------------------------------------------------------------ */
SELECT
    c.first_name,
    c.country,
    COUNT(o.order_id) AS total_orders
FROM Orders AS o
INNER JOIN Customers AS c
    ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY
    c.customer_id,
    c.first_name,
    c.country
HAVING COUNT(o.order_id) >= 2
ORDER BY total_orders DESC;


/* ------------------------------------------------------------
   Q3. Which Premium customers have never placed an order?
   Used to identify candidates for a reactivation campaign.
   Output: customer_id, first_name, country, signup_date.
   ------------------------------------------------------------ */
SELECT
    c.customer_id,
    c.first_name,
    c.country,
    c.signup_date
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.customer_id = o.customer_id
WHERE c.customer_segment = 'Premium'
    AND o.order_id IS NULL;

-- Validation: cross-check the same result using EXCEPT
SELECT c.customer_id
FROM Customers AS c
WHERE c.customer_segment = 'Premium'
EXCEPT
SELECT o.customer_id
FROM Orders AS o;


/* ------------------------------------------------------------
   Q4. Which markets are generating the most revenue?
   Total revenue from completed orders, by country,
   ordered from highest to lowest.
   Output: country, total_revenue.
   ------------------------------------------------------------ */
SELECT
    c.country,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS total_revenue
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Validation: how many distinct completed orders contributed to each country's revenue?
SELECT
    c.country,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.country
ORDER BY total_revenue DESC;


/* ------------------------------------------------------------
   Q5. Which product categories perform best in completed orders?
   Total revenue and total units sold per category,
   ordered from highest to lowest revenue.
   Output: category, total_revenue, units_sold.
   ------------------------------------------------------------ */
SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS total_revenue,
    SUM(oi.quantity) AS units_sold
FROM Products AS p
INNER JOIN OrderItems AS oi
    ON p.product_id = oi.product_id
INNER JOIN Orders AS o
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY p.category
ORDER BY total_revenue DESC;


/* ------------------------------------------------------------
   Q6. How many registered customers, by country, have never
   placed an order? Identifies markets with the highest share
   of inactive customers.
   Output: country, total_clients.
   ------------------------------------------------------------ */
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_clients
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
GROUP BY c.country
ORDER BY total_clients DESC;


/* ------------------------------------------------------------
   Q7. Which customers purchased products from both the
   Electronics and Accessories categories, considering only
   completed orders?
   ------------------------------------------------------------ */
SELECT
    c.customer_id,
    c.first_name,
    c.country
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
INNER JOIN Products AS p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
    AND p.category = 'Electronics'

INTERSECT

SELECT
    c.customer_id,
    c.first_name,
    c.country
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
INNER JOIN Products AS p
    ON oi.product_id = p.product_id
WHERE o.status = 'Completed'
    AND p.category = 'Accessories';


/* ------------------------------------------------------------
   Q8. Which Sales employees generated the most and least
   revenue through completed orders?
   Output: employee_id, employee_name, total_orders, total_revenue.
   ------------------------------------------------------------ */
SELECT
    e.employee_id,
    e.first_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100)) AS total_revenue
FROM Employees AS e
INNER JOIN Orders AS o
    ON o.employee_id = e.employee_id
INNER JOIN OrderItems AS oi
    ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
    AND e.department = 'Sales'
GROUP BY
    e.employee_id,
    e.first_name
ORDER BY total_revenue DESC;

