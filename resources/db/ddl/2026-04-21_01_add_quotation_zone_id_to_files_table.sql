ALTER TABLE public.files
  ADD COLUMN quotation_zone_id UUID;

ALTER TABLE public.files
  ADD CONSTRAINT files_quotation_zone_id_fk FOREIGN KEY (quotation_zone_id)
    REFERENCES public.quotation_zones(quotation_zone_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE; 