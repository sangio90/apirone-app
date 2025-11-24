ALTER TABLE public.currencies
RENAME TO _currencies;

ALTER TABLE public.payment_methods
RENAME TO _payment_methods;

ALTER TABLE public.quotations
DROP payment_method_id;

ALTER TABLE public.quotations
DROP currency_id;

ALTER TABLE public.quotations
ADD COLUMN currency_id INTEGER;

ALTER TABLE public.quotations
ADD COLUMN payment_method_id INTEGER;

ALTER TABLE public.quotations
ALTER COLUMN created_at
SET NOT NULL;