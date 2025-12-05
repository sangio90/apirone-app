ALTER TABLE public.quotation_prices
ADD UNIQUE (quotation_id);

ALTER TABLE public.quotation_item_prices
ADD UNIQUE (quotation_item_id);
