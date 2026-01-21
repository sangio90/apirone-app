ALTER TABLE public.quotation_item_prices
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;

ALTER TABLE public.quotation_item_price_lines
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;