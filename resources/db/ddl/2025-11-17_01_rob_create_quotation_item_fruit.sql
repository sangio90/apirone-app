CREATE TABLE public.quotation_item_fruits (
    quotation_item_fruit_id SERIAL,
    quotation_item_id UUID STORAGE PLAIN NOT NULL,
    "position" INTEGER STORAGE PLAIN NOT NULL,
    product_id UUID STORAGE PLAIN NOT NULL,
    CONSTRAINT quotation_item_fruits_pkey PRIMARY KEY (quotation_item_fruit_id),
    CONSTRAINT quotation_item_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) MATCH FULL ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_item_fruits OWNER TO apiruser;

ALTER TABLE public.quotation_item_product_items
ADD COLUMN quotation_item_fruit_id INTEGER;

ALTER TABLE public.quotation_item_product_items
ADD CONSTRAINT quotation_item_product_items_fruit_id_fk FOREIGN KEY (quotation_item_fruit_id) REFERENCES public.quotation_item_fruits (quotation_item_fruit_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;