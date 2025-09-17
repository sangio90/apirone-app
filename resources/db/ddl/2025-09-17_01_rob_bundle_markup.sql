ALTER TABLE public.catalog_bundles
  ADD COLUMN markup_percent NUMERIC(10,2);

COMMENT ON COLUMN public.catalog_bundles.markup_percent
IS 'Markup di incremento';

ALTER TABLE public.catalog_bundles
  ALTER COLUMN markup_percent SET DEFAULT 0;  