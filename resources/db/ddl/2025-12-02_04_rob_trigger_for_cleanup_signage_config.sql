-- Funzione del trigger (con CREATE OR REPLACE)
CREATE OR REPLACE FUNCTION cleanup_signage_configs () RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM signage_config_items 
        WHERE signage_config_id = OLD.signage_config_id
    ) THEN
        DELETE FROM signage_configs 
        WHERE signage_config_id = OLD.signage_config_id;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Rimuovi e ricrea il trigger
DROP TRIGGER IF EXISTS trg_cleanup_signage_configs ON signage_config_items;

CREATE TRIGGER trg_cleanup_signage_configs
AFTER DELETE ON signage_config_items FOR EACH ROW
EXECUTE FUNCTION cleanup_signage_configs ();