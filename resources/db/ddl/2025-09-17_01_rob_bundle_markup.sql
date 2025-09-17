ALTER TABLE public.catalog_bundles
  ADD COLUMN markup_value NUMERIC(10,2);

COMMENT ON COLUMN public.catalog_bundles.markup_value
IS 'Markup di incremento';

ALTER TABLE public.catalog_bundles
  ALTER COLUMN markup_value SET DEFAULT 0;  