CREATE TABLE public.pricelists (
  pricelist_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
  pricelist VARCHAR(255) NOT NULL,
  created_at timestamp default now ()
);

CREATE TABLE public.payment_methods (
  payment_method_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
  payment_method VARCHAR(255) NOT NULL,
  created_at timestamp default now ()
);

CREATE TABLE public.currencies (
  currency_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
  currency VARCHAR(255) NOT NULL,
  created_at timestamp default now ()
);

ALTER TABLE public.quotations
DROP COLUMN pricelist,
DROP COLUMN payment_method,
DROP COLUMN currency,
ADD COLUMN pricelist_id UUID REFERENCES public.pricelists (pricelist_id),
ADD COLUMN payment_method_id UUID REFERENCES public.payment_methods (payment_method_id),
ADD COLUMN currency_id UUID REFERENCES public.currencies (currency_id),
ADD CONSTRAINT fk_pricelist FOREIGN KEY (pricelist_id) REFERENCES public.pricelists (pricelist_id),
ADD CONSTRAINT fk_payment_method FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods (payment_method_id),
ADD CONSTRAINT fk_currency FOREIGN KEY (currency_id) REFERENCES public.currencies (currency_id);

ALTER TABLE public.profiles
ADD COLUMN type CHAR(1) NOT NULL DEFAULT 'G';
