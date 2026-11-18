-- 02_analysis.sql
-- Business analysis queries on orders_clean + order_items

-- Q1. Overall KPIs
SELECT COUNT(DISTINCT oc.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue,
       ROUND(SUM(oi.price) / COUNT(DISTINCT oc.order_id), 2) AS aov,
       ROUND(SUM(oi.freight_value), 2) AS freight
FROM olist.orders_clean oc
JOIN olist.order_items oi ON oi.order_id = oc.order_id;

-- Q2. Monthly revenue and month-over-month growth
WITH monthly AS (
  SELECT oc.order_month,
         SUM(oi.price) AS revenue,
         COUNT(DISTINCT oc.order_id) AS orders
  FROM olist.orders_clean oc
  JOIN olist.order_items oi ON oi.order_id = oc.order_id
  GROUP BY oc.order_month
)
SELECT order_month,
       ROUND(revenue, 2) AS revenue,
       orders,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY order_month))
             / LAG(revenue) OVER (ORDER BY order_month) * 100, 1) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- Q3. Top 10 categories by revenue, with revenue share
SELECT COALESCE(t.product_category_name_english, 'unknown') AS category,
       COUNT(DISTINCT oi.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue,
       ROUND(SUM(oi.price) * 100 / SUM(SUM(oi.price)) OVER (), 1) AS revenue_pct
FROM olist.order_items oi
JOIN olist.orders_clean oc ON oc.order_id = oi.order_id
LEFT JOIN olist.products p ON p.product_id = oi.product_id
LEFT JOIN olist.category_translation t ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q4. State-wise performance: revenue, delivery time, late %, freight
SELECT c.customer_state,
       COUNT(DISTINCT oc.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue,
       ROUND(AVG(oc.delivery_days), 1) AS avg_delivery_days,
       ROUND(AVG(oc.is_late) * 100, 1) AS late_pct,
       ROUND(AVG(oi.freight_value), 2) AS avg_freight
FROM olist.orders_clean oc
JOIN olist.customers c ON c.customer_id = oc.customer_id
JOIN olist.order_items oi ON oi.order_id = oc.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Q5. Late vs on-time: average review score
SELECT oc.is_late,
       COUNT(*) AS reviews,
       ROUND(AVG(r.review_score), 2) AS avg_score
FROM olist.orders_clean oc
JOIN olist.order_reviews r ON r.order_id = oc.order_id
GROUP BY oc.is_late;

-- Q6. Review score by delivery time bucket
SELECT CASE WHEN oc.delivery_days <= 7 THEN '1) 0-7 days'
            WHEN oc.delivery_days <= 14 THEN '2) 8-14 days'
            WHEN oc.delivery_days <= 21 THEN '3) 15-21 days'
            ELSE '4) 22+ days' END AS delivery_bucket,
       COUNT(*) AS reviews,
       ROUND(AVG(r.review_score), 2) AS avg_score
FROM olist.orders_clean oc
JOIN olist.order_reviews r ON r.order_id = oc.order_id
GROUP BY delivery_bucket
ORDER BY delivery_bucket;

-- Q7. Share of bad reviews (1-2 stars) that come from late orders
SELECT COUNT(*) AS bad_reviews,
       SUM(oc.is_late) AS from_late_orders,
       ROUND(SUM(oc.is_late) * 100 / COUNT(*), 1) AS late_share_of_bad_reviews
FROM olist.orders_clean oc
JOIN olist.order_reviews r ON r.order_id = oc.order_id
WHERE r.review_score <= 2;

-- Q8. Repeat customers (use customer_unique_id, not customer_id)
SELECT COUNT(*) AS customers,
       SUM(order_cnt > 1) AS repeat_customers,
       ROUND(SUM(order_cnt > 1) * 100 / COUNT(*), 2) AS repeat_pct
FROM (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT oc.order_id) AS order_cnt
  FROM olist.orders_clean oc
  JOIN olist.customers c ON c.customer_id = oc.customer_id
  GROUP BY c.customer_unique_id
) x;

-- Q9. Sellers with the highest late delivery % (min 50 orders)
SELECT oi.seller_id,
       COUNT(DISTINCT oc.order_id) AS orders,
       ROUND(SUM(oi.price), 2) AS revenue,
       ROUND(AVG(oc.is_late) * 100, 1) AS late_pct,
       ROUND(AVG(r.review_score), 2) AS avg_score
FROM olist.order_items oi
JOIN olist.orders_clean oc ON oc.order_id = oi.order_id
LEFT JOIN olist.order_reviews r ON r.order_id = oc.order_id
GROUP BY oi.seller_id
HAVING orders >= 50
ORDER BY late_pct DESC
LIMIT 10;