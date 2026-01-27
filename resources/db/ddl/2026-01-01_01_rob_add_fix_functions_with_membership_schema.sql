CREATE OR REPLACE FUNCTION public.fn_users_ai_user_count () RETURNS trigger LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER PARALLEL UNSAFE COST 100 AS $body$
BEGIN
    UPDATE membership.accounts 
    SET user_count = user_count + 1 
    WHERE account_id = NEW.account_id;
    RETURN NEW;
END;
$body$;

CREATE OR REPLACE FUNCTION public.fn_users_ad_user_count () RETURNS trigger LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER PARALLEL UNSAFE COST 100 AS $body$
BEGIN
    UPDATE membership.accounts 
    SET user_count = user_count - 1 
    WHERE account_id = OLD.account_id;
    RETURN OLD;
END;
$body$;

CREATE OR REPLACE FUNCTION public.fn_users_au_user_count () RETURNS trigger LANGUAGE 'plpgsql' VOLATILE CALLED ON NULL INPUT SECURITY INVOKER PARALLEL UNSAFE COST 100 AS $body$
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
$body$;