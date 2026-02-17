ALTER TABLE public.quotation_items
ADD COLUMN orientation_id VARCHAR(3);

ALTER TABLE public.quotation_items
ALTER COLUMN orientation_id
SET DEFAULT 'HOR';