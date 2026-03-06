-- Average session duration by device
SELECT device,
COUNT(*) AS sessions,
ROUND(AVG(duration_mins), 2) AS avg_duration_mins
FROM user_sessions
GROUP BY device
ORDER BY avg_duration_mins DESC;

-- Revenue by order status
SELECT status,
COUNT(*) AS num_orders,
SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- Analytics
SELECT COUNT(*) AS total_orders,
SUM(total_amount) AS total_revenue,
AVG(total_amount) AS avg_order_value,
MIN(total_amount) AS smallest_order,
MAX(total_amount) AS largest_order
FROM orders
WHERE status = 'delivered';

-- Products in each category
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category;

-- Filter using having and group by
SELECT status,
COUNT(*) AS num_orders,
SUM(total_amount) AS total_revenue
FROM orders
WHERE order_date >= '2025-01-01' -- filter rows first
GROUP BY status
HAVING COUNT(*) > 3 -- then filter groups
ORDER BY total_revenue DESC;

-- Product categories where average price is above 3000:
SELECT category,
COUNT(*) AS products,
ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 3000
ORDER BY avg_price DESC;

-- Sequential number to each group
SELECT customer_id,
order_date,
total_amount,
ROW_NUMBER() OVER (
PARTITION BY customer_id
ORDER BY total_amount DESC
) AS order_rank_by_customer
FROM orders;

-- RANK: like ROW_NUMBER but ties get the same rank
-- (two orders with equal amount both get rank 1, next is rank 3)
SELECT customer_id,
total_amount,
RANK() OVER (ORDER BY total_amount DESC) AS overall_rank
FROM orders;

-- DENSE_RANK: ties get the same rank, but no gaps in numbering
-- (two at rank 1 means next is rank 2, not rank 3)
SELECT customer_id,
total_amount,
DENSE_RANK() OVER (ORDER BY total_amount DESC) AS dense_rank
FROM orders;

--Query 8 — Month-over-month revenue trend with LAG
WITH monthly_revenue AS (
SELECT TO_CHAR(order_date, 'YYYY-MM') AS month,
SUM(total_amount) AS revenue
FROM orders
WHERE status = 'delivered'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT month,
revenue,
LAG(revenue) OVER (ORDER BY month) AS prev_month,
revenue - LAG(revenue) OVER (ORDER BY month)
AS absolute_change,
ROUND(
100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
/ NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
1
) AS pct_change
FROM monthly_revenue
ORDER BY month;

--Query 9 — Customer value segmentation using CTEs
WITH customer_spend AS (
SELECT c.customer_id,
c.name,
c.city,
COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
AND o.status = 'delivered'
GROUP BY c.customer_id, c.name, c.city
),
customer_tiers AS (
SELECT *,
CASE
WHEN total_spent > 30000 THEN 'VIP'
WHEN total_spent > 10000 THEN 'High Value'
WHEN total_spent > 0 THEN 'Active'
ELSE 'Never Purchased'
END AS tier
FROM customer_spend
)
SELECT tier,
COUNT(*) AS num_customers,
ROUND(SUM(total_spent), 2) AS tier_revenue,
ROUND(
100.0 * SUM(total_spent)
/ NULLIF(SUM(SUM(total_spent)) OVER (), 0),
1
) AS revenue_share_pct
FROM customer_tiers
GROUP BY tier
ORDER BY tier_revenue DESC;

--Query 10 — Session-to-purchase funnel analysis
WITH session_summary AS (
SELECT customer_id,
COUNT(*) AS total_sessions,
SUM(pages_viewed) AS total_pages,
ROUND(AVG(duration_mins), 2) AS avg_duration,
SUM(CASE WHEN converted THEN 1 ELSE 0 END) AS converted_sessions
FROM user_sessions
GROUP BY customer_id
),
order_summary AS (
SELECT customer_id,
COUNT(*) AS total_orders,
SUM(total_amount) AS total_spent
FROM orders
WHERE status = 'delivered'
GROUP BY customer_id
),
combined AS (
SELECT c.name,
c.city,
s.total_sessions,
s.total_pages,
s.avg_duration,
s.converted_sessions,
COALESCE(o.total_orders, 0) AS total_orders,
COALESCE(o.total_spent, 0) AS total_spent
FROM session_summary s
JOIN customers c ON s.customer_id = c.customer_id
LEFT JOIN order_summary o ON s.customer_id = o.customer_id
)
SELECT name,
city,
total_sessions,
total_pages,
avg_duration,
total_orders,
total_spent,
ROUND(
CASE WHEN total_sessions > 0
THEN 100.0 * total_orders / total_sessions
ELSE 0
END, 1
) AS orders_per_100_sessions
FROM combined
ORDER BY total_sessions DESC, orders_per_100_sessions ASC;
