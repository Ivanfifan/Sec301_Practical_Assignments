# Sec301 — Practical assignments 

## Practical assignment 1 — Apple Music

Спрощена модель музичного стрімінгового сервісу на PostgreSQL.

**Таблиці:** `artist`, `album`, `track`, `users`, `stream_history`

**Запит:** аналізує історію прослуховувань Premium-користувачів з України та Польщі за вказаний період — рахує кількість стрімів та загальний час прослуховування по альбомах.

**Детальний опис:** в файлі Assignment_1.md

### Як запустити

Виконати SQL-скрипти в порядку:

1. `Create_tables.sql` — створення таблиць
2. `Insert_data.sql` — заповнення даними
3. `Main_query.sql` — аналітичний запит

---

## Practical assignment 2 — E-commerce query optimization

Спрощена модель e-commerce сервісу з фокусом на оптимізацію запитів.

**Таблиці:** `opt_clients`, `opt_orders`, `opt_products`

**Запит:** аналізує активність клієнтів — фільтрує active-користувачів, враховує замовлення з певних категорій і порівнює кожного клієнта із середнім значенням, присвоюючи мітку `Above Average`, `Below Average` або `Average`.

**Оптимізація:** неоптимізований варіант через `UNION ALL` виконується ~1100ms, оптимізований через CTE + covering index — ~400ms.

**Детальний опис:** в файлі Assignment_2.md

### Як запустити

1. `non_optimized.sql` — неоптимізований варіант з `UNION ALL`
2. `optimized.sql` — оптимізований варіант з CTE та індексом

---

## Practical assignment 3 — Order management system

Система управління замовленнями інтернет-магазину з функціями, процедурами та тригерами.

**Таблиці:** `customers`, `products`, `orders`, `order_items`, `order_log`

**Функціонал:**
- функція `calculate_order_total` — рахує суму замовлення
- процедура `create_order` — створює замовлення з перевіркою клієнта
- процедура `add_product_to_order` — додає продукт з перевіркою складу
- тригер `update_total_amount` — автоматично оновлює суму замовлення при змінах в `order_items`
- тригер `update_order_log` — логує кожне нове замовлення в `order_log`

**Детальний опис:** в файлі Assignment_3.md

### Як запустити

1. `main_query.sql` — всі функції, процедури, тригери та тестовий скрипт
