/*
  2025-08-19 21:02:17
*/

-- AttributeValue: trigger for count product_items

ALTER TABLE public.product_items
  ADD COLUMN component_count INTEGER DEFAULT 0;

CREATE OR REPLACE FUNCTION fn_product_items_u_component_count()
RETURNS trigger AS
$$
    BEGIN
        -- Usa NEW se presente, altrimenti OLD (per DELETE)
        UPDATE product_items
        SET component_count = (
            SELECT COUNT(*)
            FROM components
            WHERE components.product_item_id = COALESCE(NEW.product_item_id, OLD.product_item_id)
        )
        WHERE product_item_id = COALESCE(NEW.product_item_id, OLD.product_item_id);
    
        RETURN NULL;
    END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tgr_components_aiu_product_items_component_count ON components;
DROP TRIGGER IF EXISTS tgr_components_ad_product_items_component_count ON components;

CREATE TRIGGER tgr_components_aiu_product_items_component_count
    AFTER INSERT OR UPDATE
    ON components
    FOR EACH ROW
    WHEN (NEW.product_item_id IS NOT NULL)
    EXECUTE PROCEDURE fn_product_items_u_component_count();

CREATE TRIGGER tgr_components_ad_product_items_component_count
    AFTER DELETE
    ON components
    FOR EACH ROW
    WHEN (OLD.product_item_id IS NOT NULL)
    EXECUTE PROCEDURE fn_product_items_u_component_count();

-- aggiorna il conteggio dei componenti esistenti
UPDATE product_items ar
SET component_count = (
    SELECT COUNT(*)
    FROM components c
    WHERE c.product_item_id = ar.product_item_id
);