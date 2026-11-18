-- 03_fact_tables.sql
-- Builds the two tables used by the Power BI dashboard:
--   fact_orders: one row per order (date, state, delivery time, late flag, review score)
--   fact_items:  one row per item (seller, category, price, freight)
-- Scope: Jan 2017 - Aug 2018 (other months have incomplete data)

CREATE TABLE olist.fact_orders AS
SELECT oc.order_id,
       DATE(oc.order_purchase_timestamp) AS order_date,
       oc.order_month,
       c.customer_unique_id,
       c.customer_state,
       oc.delivery_days,
       oc.estimated_days,
       oc.is_late,
       r.review_score
FROM olist.orders_clean oc
JOIN olist.customers c ON c.customer_id = oc.customer_id
LEFT JOIN (
  SELECT order_id, ROUND(AVG(review_score), 2) AS review_score
  FROM olist.order_reviews
  GROUP BY order_id
) r ON r.order_id = oc.order_id
WHERE oc.order_month BETWEEN '2017-01' AND '2018-08';

CREATE TABLE olist.fact_items AS
SELECT oi.order_id,
       oi.order_item_id,
       oi.seller_id,
       s.seller_state,
       COALESCE(t.product_category_name_english, 'unknown') AS category,
       oi.price,
       oi.freight_value
FROM olist.order_items oi
JOIN olist.orders_clean oc ON oc.order_id = oi.order_id
LEFT JOIN olist.sellers s ON s.seller_id = oi.seller_id
LEFT JOIN olist.products p ON p.product_id = oi.product_id
LEFT JOIN olist.category_translation t ON t.product_category_name = p.product_category_name
WHERE oc.order_month BETWEEN '2017-01' AND '2018-08';