-- Task 1

CREATE OR REPLACE FUNCTION calculate_order_total(p_order_id int)
RETURNS numeric
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(quantity * price), 0)
        FROM order_items
        WHERE order_id = p_order_id
    );
END;
$$;

-- Task 2

CREATE OR REPLACE PROCEDURE create_order(p_customer_id int)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT * FROM customers WHERE customer_id = p_customer_id)
        THEN
            RAISE EXCEPTION 'Id error';
        END IF;
    INSERT INTO orders(customer_id,order_date,total_amount)
    VALUES (p_customer_id,now(),0);
END;
$$;

-- Task 3

CREATE OR REPLACE PROCEDURE add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_quantity > (SELECT stock_quantity FROM products WHERE product_id = p_product_id)
        THEN
            RAISE EXCEPTION 'Недостатньо товару на складі';
        END IF;
    IF p_quantity <= 0
        THEN
            RAISE EXCEPTION 'Кількість має бути більшою за нуль';
        END IF;
    INSERT INTO order_items(order_id,product_id,price,quantity)
    VALUES (p_order_id,p_product_id, (SELECT price FROM products WHERE product_id = p_product_id), p_quantity);
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;
END;
$$;

-- Task 4
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id int;
BEGIN
    IF TG_OP = 'DELETE'
        THEN
            v_order_id := OLD.order_id;
        ELSE
            v_order_id := NEW.order_id;
        END IF;
    UPDATE orders
    SET total_amount = calculate_order_total(v_order_id)
    WHERE order_id = v_order_id;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER update_total_amount
AFTER INSERT OR UPDATE OR DELETE
ON order_items
FOR EACH ROW
    EXECUTE FUNCTION update_order_total();

-- Task 5
CREATE OR REPLACE FUNCTION log_new_order_func()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO order_log(order_id,customer_id,action,log_date)
    VALUES (new.order_id,new.customer_id,'Order created',now());

    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER update_order_log
AFTER INSERT
ON orders
FOR EACH ROW
    EXECUTE FUNCTION log_new_order_func();

-- Task 6

-- Show customers can be created, products can be created

INSERT INTO customers (full_name, email, balance)
VALUES ('Test User', 'test.user@example.com', 500.00);

INSERT INTO products (product_name, price, stock_quantity)
VALUES ('Test item', 100.00, 10);

-- Show orders can be created using the procedure

CALL create_order(6);

-- Show products can be added to orders using the procedure

CALL add_product_to_order(5,7,4)

