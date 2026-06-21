# Bonus Task 3 — Query Analysis

## Execution Plan

```
Hash Join  (cost=27.09..41.32 rows=7 width=274) (actual time=0.029..0.031 rows=2.00 loops=1)
  Hash Cond: (p.product_id = oi.product_id)
  Buffers: shared hit=2
  ->  Seq Scan on products p  (cost=0.00..13.00 rows=300 width=222) (actual time=0.010..0.011 rows=6.00 loops=1)
        Buffers: shared hit=1
  ->  Hash  (cost=27.00..27.00 rows=7 width=28) (actual time=0.011..0.011 rows=2.00 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        Buffers: shared hit=1
        ->  Seq Scan on order_items oi  (cost=0.00..27.00 rows=7 width=28) (actual time=0.007..0.008 rows=2.00 loops=1)
              Filter: (order_id = 1)
              Rows Removed by Filter: 4
              Buffers: shared hit=1
Planning:
  Buffers: shared hit=170
Planning Time: 1.752 ms
Execution Time: 0.052 ms
```

## Explanation

PostgreSQL виконує plan знизу вверх, тому реальний порядок такий:

**Крок 1 — Seq Scan на `order_items`.**
PostgreSQL пройшовся по всій таблиці `order_items` рядок за рядком.
Знайшов 6 рядків, застосував фільтр `order_id = 1` і викинув 4 — залишилось 2 рядки які стосуються нашого замовлення.

**Крок 2 — Побудова хеш-таблиці.**
З цих 2 рядків PostgreSQL побудував хеш-таблицю. Ключ хешу — `product_id`.
Тобто тепер є структура де за `product_id` можна миттєво знайти потрібний рядок з `order_items`.

**Крок 3 — Seq Scan на `products`.**
Паралельно PostgreSQL пройшовся по всій таблиці `products` — знайшов усі 6 продуктів.

**Крок 4 — Hash Join.**
Для кожного рядка з `products` PostgreSQL бере його `product_id` і перевіряє чи є такий ключ в хеш-таблиці з кроку 2.
Якщо є — з'єднує рядки і віддає в результат. Так знайшлось 2 фінальних рядки.

