CREATE TABLE public.line_prices (
  line_price_id SERIAL,
  line_id UUID STORAGE PLAIN,
  product_category_id INTEGER STORAGE PLAIN,
  markup_value NUMERIC(10,5) STORAGE PLAIN,
  created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now(),
  CONSTRAINT line_prices_idx UNIQUE(product_category_id, line_id),
  CONSTRAINT line_prices_pkey PRIMARY KEY(line_price_id),
  CONSTRAINT line_prices_category_id_fk FOREIGN KEY (product_category_id)
    REFERENCES public.product_categories(product_category_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT line_prices_line_id_fk FOREIGN KEY (line_id)
    REFERENCES public.lines(line_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE
) ;

ALTER TABLE public.line_prices
  OWNER TO apiruser;

ALTER TABLE public.line_prices
  ALTER COLUMN markup_value SET STORAGE PLAIN;

ALTER TABLE public.line_prices
  RENAME TO product_category_lines;

ALTER TABLE public.product_category_lines
  RENAME COLUMN line_price_id TO product_category_line_id;

ALTER TABLE public.product_category_lines
  RENAME COLUMN markup_value TO markup;