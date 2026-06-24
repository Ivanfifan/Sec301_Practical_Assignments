CREATE OR REPLACE PROCEDURE upgrade_user_to_premium(p_user_id INT, p_card_number VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE users
    SET subscription_type = 'Premium'
    WHERE user_id = p_user_id;

    INSERT INTO streaming.user_billing_info (user_id, card_number)
    VALUES (p_user_id, p_card_number);
END;
$$