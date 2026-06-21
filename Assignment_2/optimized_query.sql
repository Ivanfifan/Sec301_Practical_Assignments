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
)
SELECT
    name,
    surname,
    email,
    total_orders AS total_orders,
    CASE
        WHEN total_orders > ( SELECT AVG(total_orders) FROM subquery AS sub_avg ) THEN 'Above Average'
        WHEN total_orders < ( SELECT AVG(total_orders) FROM subquery AS sub_avg ) THEN 'Below Average'
        ELSE 'Average'
    END AS activity_level
FROM subquery;

CREATE INDEX idx_products_category_cover ON opt_products(product_category)
INCLUDE (product_id);