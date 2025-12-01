ALTER TABLE public.quotation_items
ADD COLUMN price_method_id CHAR(1) DEFAULT 'C' NOT NULL;

ALTER TABLE public.quotation_items
ADD COLUMN price_goods NUMERIC(10, 5);

ALTER TABLE public.quotation_items
ADD COLUMN price_final NUMERIC(10, 5);

ALTER TABLE public.quotation_items
ADD COLUMN discount1 NUMERIC(10, 5);

ALTER TABLE public.quotation_items
ADD COLUMN discount2 NUMERIC(10, 5);

ALTER TABLE public.quotation_items
ALTER COLUMN price
DROP NOT NULL;