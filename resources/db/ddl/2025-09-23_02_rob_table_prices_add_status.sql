ALTER TABLE public.price_types
  ADD COLUMN status_id VARCHAR(5);

UPDATE public.price_types SET status_id = 'ACT';

ALTER TABLE public.price_types
  ALTER COLUMN status_id SET DEFAULT 'ACT';

ALTER TABLE public.price_types
  ALTER COLUMN status_id SET NOT NULL;

ALTER TABLE public.prices
  ADD CONSTRAINT prices_price_type_id_fk FOREIGN KEY (price_type_id)
    REFERENCES public.price_types(price_type_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;  

