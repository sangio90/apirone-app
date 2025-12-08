ALTER TABLE public.quotations
RENAME COLUMN shipping_address_id TO shipping_address_id;

ALTER TABLE public.quotations
DROP COLUMN shipping_address_id;

ALTER TABLE public.quotations
ADD COLUMN updated_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL;

-- object recreation
ALTER TABLE public.quotation_items
DROP CONSTRAINT fk_quotation_items_quotation RESTRICT;

ALTER TABLE public.quotation_items
ADD CONSTRAINT quotation_items_quotation_id_fk FOREIGN KEY (quotation_id) REFERENCES public.quotations (quotation_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.quotation_items
DROP CONSTRAINT fk_quotation_items_quotation_zone RESTRICT;

ALTER TABLE public.quotation_items
ADD CONSTRAINT quotation_items_quotation_zone_id_fk FOREIGN KEY (quotation_zone_id) REFERENCES public.quotation_zones (quotation_zone_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.quotation_items
DROP CONSTRAINT fk_quotation_items_product_id RESTRICT;

ALTER TABLE public.quotation_items
ADD CONSTRAINT quotation_items_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.quotation_items
DROP CONSTRAINT fk_quotation_items_product_origin_id RESTRICT;

ALTER TABLE public.quotation_items
ADD CONSTRAINT quotation_items_product_origin_id_fk FOREIGN KEY (product_origin_id) REFERENCES public.products (product_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.quotation_zones
DROP CONSTRAINT fk_quotation_zone_quotation RESTRICT;

ALTER TABLE public.quotation_zones
ADD CONSTRAINT quotation_zone_quotation_id_fk FOREIGN KEY (quotation_id) REFERENCES public.quotations (quotation_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

CREATE OR REPLACE FUNCTION update_quotation_status_sync () RETURNS TRIGGER AS $$
DECLARE
    -- Dichiara la variabile per contenere l'ID del nuovo stato come VARCHAR
    NEW_STATUS VARCHAR; 
BEGIN
    -- Se è un INSERT, aggiorna con il nuovo status_id
    IF (TG_OP = 'INSERT') THEN
        UPDATE quotations
        SET status_id = NEW.status_id
        WHERE quotation_id = NEW.quotation_id;
        RETURN NEW;
    
    -- Se è un DELETE, dobbiamo trovare lo status precedente.
    ELSIF (TG_OP = 'DELETE') THEN
        
        -- Trova il nuovo "ultimo" status_id per la quotazione
        SELECT status_id INTO NEW_STATUS
        FROM quotation_status_history
        WHERE quotation_id = OLD.quotation_id
        ORDER BY created_at DESC, quotation_status_history_id DESC -- Prendi il più recente
        LIMIT 1;

        -- Aggiorna la quotations con il nuovo status, se FOUND è true (ossia se ha trovato una riga)
        IF FOUND THEN
            UPDATE quotations
            SET status_id = NEW_STATUS
            WHERE quotation_id = OLD.quotation_id;
        ELSE
            -- GESTIONE CASO LIMITE: se non c'è più storico, setta status_id a NULL
            UPDATE quotations
            SET status_id = 'LAV' 
            WHERE quotation_id = OLD.quotation_id;
        END IF;

        RETURN OLD;
    END IF;

    -- Caso non gestito (es. UPDATE)
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

-- Rimuovi il vecchio trigger se esiste
DROP TRIGGER IF EXISTS sync_quotation_status ON quotation_status_history;

-- Crea il nuovo trigger che risponde a INSERT e DELETE
CREATE TRIGGER sync_quotation_status
AFTER INSERT
OR DELETE ON quotation_status_history FOR EACH ROW
EXECUTE FUNCTION update_quotation_status_sync ();

-- updated by trigger
ALTER TABLE public.quotations
ALTER COLUMN status_id
DROP NOT NULL;