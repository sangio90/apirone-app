ALTER TABLE export_codes 
ADD COLUMN product_hash_id INTEGER,
ADD CONSTRAINT export_codes_product_hash_id_fk 
    FOREIGN KEY (product_hash_id) 
    REFERENCES public.product_hashes (product_hash_id) 
    ON DELETE NO ACTION 
    ON UPDATE CASCADE;

DROP TABLE IF EXISTS public.export_code_raw_values;
DROP TABLE IF EXISTS public.export_code_fruits;