-- =====================================================
-- E-COMMERCE SALES ANALYSIS
-- PostgreSQL Portfolio Project
-- =====================================================


-- 1. OVERALL BUSINESS KPIs
SELECT
    ROUND(SUM(order_total), 2) AS total_revenue,
    COUNT(*) AS total_orders,
    ROUND(AVG(order_total), 2) AS average_order_value
FROM orders;


-- 2. REVENUE BY PRODUCT CATEGORY
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


-- 3. MONTHLY REVENUE TREND
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(order_total), 2) AS monthly_revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- 4. TOP 5 PRODUCTS BY REVENUE
SELECT
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS product_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY product_revenue DESC
LIMIT 5;


-- 5. PAYMENT METHOD ANALYSIS
SELECT
    payment_method,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY payment_method
ORDER BY number_of_orders DESC;


-- 6. TOP 10 CUSTOMERS BY SPEND
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_total), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 10;


-- 7. GEOGRAPHIC SALES ANALYSIS
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_total), 2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;


-- 8. REPEAT VS ONE-TIME CUSTOMERS
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM customer_orders
GROUP BY customer_type;


-- 9. MONTH-ON-MONTH REVENUE GROWTH
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(order_total) AS revenue
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
growth AS (
    SELECT
        month,
        revenue,
        ((revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month)) * 100
        AS growth_percentage
    FROM monthly_sales
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(growth_percentage, 2) AS growth_percentage
FROM growth
ORDER BY month;


-- 10. CATEGORY PERFORMANCE
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS revenue_per_order
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_per_order DESC;