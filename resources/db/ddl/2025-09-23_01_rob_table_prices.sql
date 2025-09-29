CREATE TABLE public.prices (
  price_id INTEGER STORAGE PLAIN DEFAULT nextval('prices_price_id_seq'::regclass) NOT NULL,
  method_id CHAR(1) DEFAULT 'F'::bpchar NOT NULL,
  price_type_id VARCHAR(15) NOT NULL,
  amount NUMERIC(10,5) STORAGE MAIN,
  created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now(),
  product_item_id INTEGER STORAGE PLAIN,
  product_it UUID STORAGE PLAIN,
  CONSTRAINT prices_idx UNIQUE(product_it, price_type_id),
  CONSTRAINT prices_idx1 UNIQUE(product_item_id, price_type_id),
  CONSTRAINT prices_pkey PRIMARY KEY(price_id),
  CONSTRAINT prices_product_id_fk FOREIGN KEY (product_it)
    REFERENCES public.products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT prices_product_item_id_fk FOREIGN KEY (product_item_id)
    REFERENCES public.product_items(product_item_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE
) ;

COMMENT ON COLUMN public.prices.method_id
IS 'F = fixed, P=percentuale';

ALTER TABLE public.prices
  OWNER TO apiruser;

ALTER TABLE public.prices
  ADD COLUMN status_id VARCHAR(5) DEFAULT 'ACT' NOT NULL;  

ALTER TABLE public.prices
  ADD CONSTRAINT prices_status_id_fk FOREIGN KEY (status_id)
    REFERENCES public.statuses(status_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;    

CREATE TABLE public.price_types (
  price_type_id VARCHAR(15) STORAGE PLAIN NOT NULL,
  price_type VARCHAR(100) STORAGE PLAIN,
  entities JSONB,
  created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
  CONSTRAINT price_types_id_pkey PRIMARY KEY(price_type_id)
) ;

ALTER TABLE public.price_types
  OWNER TO apiruser;

ALTER TABLE public.price_types
  ALTER COLUMN price_type_id SET STORAGE PLAIN;

ALTER TABLE public.price_types
  ALTER COLUMN price_type SET STORAGE PLAIN;


/* Data for the 'public.price_types' table  (Records 1 - 4) */

INSERT INTO public.price_types ("price_type_id", "price_type", "entities", "created_at")
VALUES 
  (E'FIXED', E'Costo fisso', E'["PRODUCT"]', E'2025-09-29 06:03:09'),
  (E'PRICE', E'Prezzo', E'["PRODUCT"]', E'2025-09-29 06:03:09'),
  (E'PROD_ITEM_GEN', E'Prezzo generale attributi', E'["PRODUCT_ITEM"]', E'2025-09-29 06:03:09'),
  (E'PROD_ITEM_PRICE', E'Prezzo attributo', E'["PRODUCT"]', E'2025-09-29 06:03:09');  


ALTER TABLE public.price_types
  ADD COLUMN status_id VARCHAR(5);