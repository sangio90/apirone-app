ALTER TABLE public.quotation_item_fruits
ADD COLUMN file_id UUID;

ALTER TABLE public.quotation_item_fruits
ADD CONSTRAINT quotation_item_fruits_file_id_fk FOREIGN KEY (file_id) REFERENCES public.files (file_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;
