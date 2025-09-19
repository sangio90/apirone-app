ALTER TABLE public.files
  ADD COLUMN quotation_item_id UUID;

ALTER TABLE public.files
  ADD CONSTRAINT files_quotation_item_id_fk FOREIGN KEY (quotation_item_id)
    REFERENCES public.quotation_items(quotation_item_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE; 