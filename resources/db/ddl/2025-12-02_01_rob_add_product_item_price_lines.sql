CREATE TABLE public.quotation_item_price_lines (
    quotation_item_price_line_id SERIAL,
    product_id UUID STORAGE PLAIN,
    name VARCHAR(255) STORAGE PLAIN,
    amount NUMERIC(10, 4) STORAGE PLAIN,
    --discount1 NUMERIC(10, 5) STORAGE MAIN,
    --discount2 NUMERIC(10, 5) STORAGE MAIN,
    --price_method_it VARCHAR(1),
    quotation_item_price_id INTEGER STORAGE PLAIN NOT NULL,
    CONSTRAINT quotation_item_price_lines_pkey PRIMARY KEY (quotation_item_price_line_id),
    CONSTRAINT quotation_item_price_lines_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) ON DELETE CASCADE ON UPDATE NO ACTION NOT DEFERRABLE,
    CONSTRAINT quotation_item_price_lines_quotation_item_price_id_fk FOREIGN KEY (quotation_item_price_id) REFERENCES public.quotation_item_prices (quotation_item_price_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_item_price_lines OWNER TO apiruser;

ALTER TABLE public.quotation_item_price_lines
ALTER COLUMN name
SET
    STORAGE PLAIN;

ALTER TABLE public.quotation_item_price_lines
ALTER COLUMN amount
SET
    STORAGE PLAIN;

ALTER TABLE public.quotation_item_prices
ADD COLUMN discount1 NUMERIC(10, 5);

ALTER TABLE public.quotation_item_prices
ADD COLUMN discount1 NUMERIC(10, 5);

ALTER TABLE public.quotation_item_prices
ADD COLUMN price_method_id CHAR(1) NOT NULL DEFAULT 'C';
