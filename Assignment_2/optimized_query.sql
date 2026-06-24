CREATE INDEX idx_products_category_cover ON opt_products(product_category)
INCLUDE (product_id);

EXPLAIN ANALYZE
WITH subquery AS (
    SELECT
        c.id,
        c.name,
        c.surname,
        c.email,
        COUNT(o.order_id) AS total_orders
    FROM opt_clients c
    JOIN opt_orders o ON c.id = o.client_id
    JOIN opt_products p ON o.product_id = p.product_id
    WHERE c.status = 'active'
      AND p.product_category IN ('Category1', 'Category3')
    GROUP BY c.id, c.name, c.surname, c.email
), avg_cte AS (
    SELECT AVG(total_orders) AS avg_orders FROM subquery
)
SELECT
    name,
    surname,
    email,
    total_orders,
    CASE
        WHEN total_orders > avg_cte.avg_orders THEN 'Above Average'
        WHEN total_orders < avg_cte.avg_orders THEN 'Below Average'
        ELSE 'Average'
    END AS activity_level
FROM subquery, avg_cte;