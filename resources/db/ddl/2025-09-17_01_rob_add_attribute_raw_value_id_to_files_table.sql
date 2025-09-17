ALTER TABLE public.files
  ADD COLUMN attribute_raw_value_id INTEGER;

ALTER TABLE public.files
  ADD CONSTRAINT files_attribute_raw_value_id_fk FOREIGN KEY (attribute_raw_value_id)
    REFERENCES public.attributes_raw_values(attribute_raw_value_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.files
  ALTER COLUMN type_id TYPE VARCHAR(30) COLLATE pg_catalog."default";    