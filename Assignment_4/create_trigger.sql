CREATE OR REPLACE FUNCTION subscription_change()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.subscription_type = 'Premium' AND NEW.subscription_type = 'Free' then
        DELETE FROM user_billing_info
               WHERE user_id = old.user_id;
END IF;
RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER subscription_downgrade
AFTER UPDATE
ON users
    FOR EACH ROW
    EXECUTE FUNCTION subscription_change();