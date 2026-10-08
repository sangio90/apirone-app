-- Eliminazione "logica" di prodotti, attributi e valori usati solo in preventivi
-- chiusi ( Convertito in ordine, Perso, Estinto ): la riga resta per i preventivi
-- che la usano, ma da deleted_at in poi non compare più nel catalogo né nella
-- creazione / modifica dei preventivi. Vedi CatalogUsageService.
ALTER TABLE products ADD COLUMN deleted_at TIMESTAMP NULL;
ALTER TABLE product_items ADD COLUMN deleted_at TIMESTAMP NULL;
ALTER TABLE attributes ADD COLUMN deleted_at TIMESTAMP NULL;
ALTER TABLE attributes_raw_values ADD COLUMN deleted_at TIMESTAMP NULL;
ALTER TABLE raw_values ADD COLUMN deleted_at TIMESTAMP NULL;
