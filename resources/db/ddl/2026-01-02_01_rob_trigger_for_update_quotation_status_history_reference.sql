-- =====================================================================================
-- Trigger per aggiornare il riferimento all'ultimo status history in quotations
-- =====================================================================================
-- Quando viene inserito/aggiornato un record in quotation_status_history,
-- aggiorna quotation_status_history_id nella tabella quotations.
-- Quando viene cancellato un record, imposta il riferimento all'ultimo record valido.
-- =====================================================================================
-- =====================================================================================
-- Funzione per INSERT/UPDATE su quotation_status_history
-- =====================================================================================
CREATE OR REPLACE FUNCTION fn_quotation_status_history_aiu_update_quotation_reference () RETURNS TRIGGER AS $$
BEGIN
    -- Aggiorna il riferimento in quotations con il nuovo record
    UPDATE quotations
    SET quotation_status_history_id = NEW.quotation_status_history_id
    WHERE quotation_id = NEW.quotation_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- Trigger AFTER INSERT OR UPDATE su quotation_status_history
-- =====================================================================================
DROP TRIGGER IF EXISTS tgr_quotation_status_history_aiu_quotations_update_reference ON quotation_status_history;

CREATE TRIGGER tgr_quotation_status_history_aiu_quotations_update_reference
AFTER INSERT
OR
UPDATE ON quotation_status_history FOR EACH ROW
EXECUTE FUNCTION fn_quotation_status_history_aiu_update_quotation_reference ();

-- =====================================================================================
-- Funzione per DELETE su quotation_status_history
-- =====================================================================================
CREATE OR REPLACE FUNCTION fn_quotation_status_history_ad_update_quotation_reference () RETURNS TRIGGER AS $$
DECLARE
    v_last_history_id INTEGER;
BEGIN
    -- Cerca l'ultimo record valido per questa quotation
    -- (ordinato per created_at e poi per ID in caso di timestamp uguali)
    SELECT quotation_status_history_id INTO v_last_history_id
    FROM quotation_status_history
    WHERE quotation_id = OLD.quotation_id
      AND quotation_status_history_id <> OLD.quotation_status_history_id
    ORDER BY created_at DESC, quotation_status_history_id DESC
    LIMIT 1;
    
    -- Aggiorna il riferimento in quotations
    -- Se non ci sono altri record, imposta NULL
    UPDATE quotations
    SET quotation_status_history_id = v_last_history_id
    WHERE quotation_id = OLD.quotation_id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- Trigger AFTER DELETE su quotation_status_history
-- =====================================================================================
DROP TRIGGER IF EXISTS tgr_quotation_status_history_ad_quotations_update_reference ON quotation_status_history;

CREATE TRIGGER tgr_quotation_status_history_ad_quotations_update_reference
AFTER DELETE ON quotation_status_history FOR EACH ROW
EXECUTE FUNCTION fn_quotation_status_history_ad_update_quotation_reference ();
