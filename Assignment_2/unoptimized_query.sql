EXPLAIN ANALYZE
SELECT
    c.name,
    c.surname,
    c.email,
    COUNT(o.order_id) AS total_orders,
    'Above Average' AS activity_level
FROM opt_clients c
JOIN opt_orders o ON c.id = o.client_id
JOIN opt_products p ON o.product_id = p.product_id
WHERE c.status = 'active'
  AND o.order_date BETWEEN '2022-01-01' AND '2024-01-31'
  AND p.product_category IN ('Category1', 'Category3')
GROUP BY c.id, c.name, c.surname, c.email
HAVING COUNT(o.order_id) > (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(o2.order_id) AS order_count
        FROM opt_clients c2
        JOIN opt_orders o2 ON c2.id = o2.client_id
        JOIN opt_products p2 ON o2.product_id = p2.product_id
        WHERE c2.status = 'active'
          AND o2.order_date BETWEEN '2022-01-01' AND '2024-01-31' 
          AND p2.product_category IN ('Category1', 'Category3')
        GROUP BY c2.id
    ) AS sub_avg
)

UNION ALL

SELECT
    c.name,
    c.surname,
    c.email,
    COUNT(o.order_id) AS total_orders,
    'Below Average' AS activity_level
FROM opt_clients c
JOIN opt_orders o ON c.id = o.client_id
JOIN opt_products p ON o.product_id = p.product_id
WHERE c.status = 'active'
  AND o.order_date BETWEEN '2022-01-01' AND '2024-01-31'
  AND p.product_category IN ('Category1', 'Category3')
GROUP BY c.id, c.name, c.surname, c.email
HAVING COUNT(o.order_id) < (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(o2.order_id) AS order_count
        FROM opt_clients c2
        JOIN opt_orders o2 ON c2.id = o2.client_id
        JOIN opt_products p2 ON o2.product_id = p2.product_id
        WHERE c2.status = 'active'
          AND o2.order_date BETWEEN '2022-01-01' AND '2024-01-31'
          AND p2.product_category IN ('Category1', 'Category3')
        GROUP BY c2.id
    ) AS sub_avg
)

UNION ALL

SELECT
    c.name,
    c.surname,
    c.email,
    COUNT(o.order_id) AS total_orders,
    'Average' AS activity_level
FROM opt_clients c
JOIN opt_orders o ON c.id = o.client_id
JOIN opt_products p ON o.product_id = p.product_id
WHERE c.status = 'active'
  AND o.order_date BETWEEN '2022-01-01' AND '2024-01-31'
  AND p.product_category IN ('Category1', 'Category3')
GROUP BY c.id, c.name, c.surname, c.email
HAVING COUNT(o.order_id) = (
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(o2.order_id) AS order_count
        FROM opt_clients c2
        JOIN opt_orders o2 ON c2.id = o2.client_id
        JOIN opt_products p2 ON o2.product_id = p2.product_id
        WHERE c2.status = 'active'
          AND o2.order_date BETWEEN '2022-01-01' AND '2024-01-31'
          AND p2.product_category IN ('Category1', 'Category3')
        GROUP BY c2.id
    ) AS sub_avg
);