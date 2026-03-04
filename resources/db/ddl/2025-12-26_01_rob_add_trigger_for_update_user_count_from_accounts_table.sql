-- ============================================
-- Trigger per gestire user_count in PostgreSQL
-- Naming convention seguendo copilot-instructions.md:
-- - Functions: fn_<table>_<action>_<field>
-- - Triggers: tgr_<table>_<action>_<target_table>_<description>
-- ============================================

-- 1. Funzione e trigger per INSERT
-- fn_users_ai_user_count: users table, after insert, update user_count field
CREATE OR REPLACE FUNCTION fn_users_ai_user_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE membership.accounts
    SET user_count = user_count + 1
    WHERE account_id = NEW.account_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- tgr_users_ai_accounts_user_count: users table, after insert, target accounts table, update user_count
CREATE TRIGGER tgr_users_ai_accounts_user_count
AFTER INSERT ON membership.users
FOR EACH ROW
EXECUTE FUNCTION fn_users_ai_user_count();

-- 2. Funzione e trigger per DELETE
-- fn_users_ad_user_count: users table, after delete, update user_count field
CREATE OR REPLACE FUNCTION fn_users_ad_user_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE membership.accounts
    SET user_count = user_count - 1
    WHERE account_id = OLD.account_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- tgr_users_ad_accounts_user_count: users table, after delete, target accounts table, update user_count
CREATE TRIGGER tgr_users_ad_accounts_user_count
AFTER DELETE ON membership.users
FOR EACH ROW
EXECUTE FUNCTION fn_users_ad_user_count();

-- 3. Funzione e trigger per UPDATE
-- fn_users_au_user_count: users table, after update, update user_count field
CREATE OR REPLACE FUNCTION fn_users_au_user_count()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.account_id IS DISTINCT FROM NEW.account_id THEN
        UPDATE membership.accounts
        SET user_count = user_count - 1
        WHERE account_id = OLD.account_id;

        UPDATE membership.accounts
        SET user_count = user_count + 1
        WHERE account_id = NEW.account_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- tgr_users_au_accounts_user_count: users table, after update, target accounts table, update user_count
CREATE TRIGGER tgr_users_au_accounts_user_count
AFTER UPDATE ON membership.users
FOR EACH ROW
EXECUTE FUNCTION fn_users_au_user_count();

-- 4. Inizializzazione dei valori
UPDATE membership.accounts
SET user_count = COALESCE(subquery.cnt, 0)
FROM (
    SELECT account_id, COUNT(*) as cnt
    FROM membership.users
    GROUP BY account_id
) AS subquery
WHERE membership.accounts.account_id = subquery.account_id;

UPDATE membership.accounts
SET user_count = 0
WHERE account_id NOT IN (
    SELECT DISTINCT account_id
    FROM membership.users
    WHERE account_id IS NOT NULL
);