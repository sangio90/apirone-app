ALTER TABLE public.components
  ADD COLUMN signage_config_item_id INTEGER;

ALTER TABLE public.components
  ADD CONSTRAINT components_signage_config_item_id_fk FOREIGN KEY (signage_config_item_id)
    REFERENCES public.signage_config_items(signage_config_item_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;