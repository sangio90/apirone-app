/*
  2025-07-24
*/

-- AttributeValue: trigger for count components

ALTER TABLE public.attributes_raw_values
  ADD COLUMN component_count INTEGER DEFAULT 0;

CREATE OR REPLACE FUNCTION fn_attribute_raw_value_update_component_count()
RETURNS trigger AS
$$
    BEGIN
        -- Usa NEW se presente, altrimenti OLD (per DELETE)
        UPDATE attributes_raw_values
        SET component_count = (
            SELECT COUNT(*)
            FROM components
            WHERE components.attribute_raw_value_id = COALESCE(NEW.attribute_raw_value_id, OLD.attribute_raw_value_id)
        )
        WHERE attribute_raw_value_id = COALESCE(NEW.attribute_raw_value_id, OLD.attribute_raw_value_id);
    
        RETURN NULL;
    END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tgr_components_aiu_component_count ON components;
DROP TRIGGER IF EXISTS tgr_components_ad_component_count ON components;

CREATE TRIGGER tgr_components_aiu_component_count
    AFTER INSERT OR UPDATE
    ON components
    FOR EACH ROW
    WHEN (NEW.attribute_raw_value_id IS NOT NULL)
    EXECUTE PROCEDURE fn_attribute_raw_value_update_component_count();

CREATE TRIGGER tgr_components_ad_component_count
    AFTER DELETE
    ON components
    FOR EACH ROW
    WHEN (OLD.attribute_raw_value_id IS NOT NULL)
    EXECUTE PROCEDURE fn_attribute_raw_value_update_component_count();

-- aggiorna il conteggio dei componenti esistenti
-- (per evitare di dover aspettare l'evento del trigger)
UPDATE attributes_raw_values ar
SET component_count = (
    SELECT COUNT(*)
    FROM components c
    WHERE c.attribute_raw_value_id = ar.attribute_raw_value_id
);