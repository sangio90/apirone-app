ALTER TABLE public.quotation_items
ADD COLUMN quotation_zone_position_id INTEGER;

ALTER TABLE public.quotation_items
ADD CONSTRAINT quotation_items_zone_position_id_fk FOREIGN KEY (quotation_zone_position_id) REFERENCES public.quotation_zone_positions (quotation_zone_position_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.quotation_zone_positions
ADD COLUMN code VARCHAR(15);