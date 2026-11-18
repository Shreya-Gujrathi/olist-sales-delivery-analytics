-- 01_cleaning.sql
-- Creates orders_clean: only delivered orders with a valid delivery date,
-- plus derived columns (delivery_days, estimated_days, is_late, order_month).
-- Raw tables are never modified.

CREATE TABLE olist.orders_clean AS
SELECT
  order_id,
  customer_id,
  order_status,
  order_purchase_timestamp,
  order_delivered_customer_date,
  order_estimated_delivery_date,
  DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days,
  DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp) AS estimated_days,
  CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
       THEN 1 ELSE 0 END AS is_late,
  DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month
FROM olist.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;