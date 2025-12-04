CREATE TABLE public.quotation_prices (
    quotation_price_id SERIAL,
    amount NUMERIC(10, 4) STORAGE PLAIN,
    quotation_id UUID STORAGE PLAIN NOT NULL,
    discount1 NUMERIC(10, 5) STORAGE MAIN,
    discount2 NUMERIC(10, 5) STORAGE MAIN,
    price_method_id CHAR(1) DEFAULT 'C'::bpchar NOT NULL,
    shipment_cost NUMERIC(10, 5),
    CONSTRAINT quotation_prices_pkey PRIMARY KEY (quotation_price_id),
    CONSTRAINT quotation_prices_quotation_id_fk FOREIGN KEY (quotation_id) REFERENCES public.quotations (quotation_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_prices OWNER TO apiruser;

COMMENT ON COLUMN public.quotation_prices.price_method_id IS 'C = calculated, F = fixed';

CREATE TABLE public.quotation_price_lines (
    quotation_price_line_id SERIAL,
    name VARCHAR(255) STORAGE PLAIN,
    amount NUMERIC(10, 4) STORAGE PLAIN,
    quotation_price_id INTEGER STORAGE PLAIN NOT NULL,
    CONSTRAINT quotation_price_lines_pkey PRIMARY KEY (quotation_price_line_id),
    CONSTRAINT quotation_prices_lines_quotation_price_id_fk FOREIGN KEY (quotation_price_id) REFERENCES public.quotation_prices (quotation_price_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_price_lines OWNER TO apiruser;

ALTER TABLE public.quotations
DROP COLUMN discount1;

ALTER TABLE public.quotations
DROP COLUMN discount2;