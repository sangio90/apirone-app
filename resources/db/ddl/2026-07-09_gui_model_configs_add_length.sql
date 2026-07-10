-- Aggiunge il campo lunghezza a model_configs.
-- Usato per le categorie diverse da placche e segnaletica (es. accessori, reception).
ALTER TABLE model_configs
    ADD COLUMN length NUMERIC(10,2) DEFAULT NULL;
