ALTER TABLE public.product_categories
  ADD COLUMN mode_id VARCHAR(3) DEFAULT 'COM' NOT NULL;

ALTER SEQUENCE public.categories_category_id_seq
  INCREMENT 1 MINVALUE 1
  MAXVALUE 2147483647 START 1
  RESTART 200 CACHE 1
  NO CYCLE OWNED BY public.product_categories.product_category_id;  