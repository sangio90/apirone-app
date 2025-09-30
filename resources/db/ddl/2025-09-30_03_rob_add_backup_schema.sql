CREATE SCHEMA backup AUTHORIZATION apiruser;

ALTER TABLE public.prices
  RENAME COLUMN product_it TO product_id;