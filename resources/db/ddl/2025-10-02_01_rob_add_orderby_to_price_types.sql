ALTER TABLE public.price_types
  ADD COLUMN orderby INTEGER DEFAULT 10 NOT NULL;


UPDATE price_types
SET orderby = 20
WHERE price_type_id = 'COST_FIXED';

UPDATE price_types
SET orderby = 10
WHERE price_type_id = 'PRICE';

UPDATE price_types
SET orderby = 30
WHERE price_type_id = 'PROD_ITEM_GEN';

UPDATE price_types
SET orderby = 40
WHERE price_type_id = 'PROD_ITEM_PRICE';  