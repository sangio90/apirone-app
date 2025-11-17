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

ALTER TABLE public.quotation_item_fruits
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;

ALTER TABLE public.quotation_item_fruits
ADD CONSTRAINT quotation_item_fruits_quotation_item_idfk FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items (quotation_item_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.quotation_item_fruits
RENAME COLUMN product_id TO fruit_id;

CREATE TABLE public.quotation_item_prices (
    quotation_item_price_id SERIAL,
    product_id UUID STORAGE PLAIN,
    name VARCHAR(255) STORAGE PLAIN,
    amount NUMERIC(10, 4) STORAGE PLAIN,
    CONSTRAINT quotation_item_prices_pkey PRIMARY KEY (quotation_item_price_id),
    CONSTRAINT quotation_item_prices_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_item_prices OWNER TO apiruser;

ALTER TABLE public.quotation_item_prices
ALTER COLUMN name
SET
    STORAGE PLAIN;

ALTER TABLE public.quotation_item_prices
ALTER COLUMN amount
SET
    STORAGE PLAIN;

ALTER TABLE public.quotation_items
ADD COLUMN discount1 NUMERIC(10, 4);

ALTER TABLE public.quotation_items
ADD COLUMN discount2 NUMERIC(10, 4);

ALTER TABLE public.quotation_items
ADD COLUMN price NUMERIC(10, 4);

ALTER TABLE public.quotation_items
ADD COLUMN price_mode CHAR(1) DEFAULT 'A' NOT NULL;

COMMENT ON COLUMN public.quotation_items.price_mode IS 'A or F';

ALTER TABLE public.quotation_item_prices
ADD COLUMN quotation_item_id UUID NOT NULL;

ALTER TABLE public.quotation_item_prices
ADD CONSTRAINT quotation_item_prices_quotation_item_id_fk FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items (quotation_item_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;