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