-- 00_validate_load.sql
-- Check that all 8 Olist tables loaded with the expected row counts
SELECT 'customers' AS tbl, COUNT(*) AS n FROM olist.customers
UNION ALL SELECT 'sellers', COUNT(*) FROM olist.sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM olist.category_translation
UNION ALL SELECT 'orders', COUNT(*) FROM olist.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM olist.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM olist.order_payments
UNION ALL SELECT 'products', COUNT(*) FROM olist.products
UNION ALL SELECT 'order_reviews', COUNT(*) FROM olist.order_reviews;