CREATE SCHEMA backup AUTHORIZATION apiruser;

ALTER TABLE public.prices
  RENAME COLUMN product_it TO product_id;

 UPDATE price_types SET price_type_id ='COST_FIXED' 
 WHERE price_type_id='FIXED';  