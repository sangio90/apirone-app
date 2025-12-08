ALTER TABLE public.quotations
ADD COLUMN owner_id UUID;

ALTER TABLE public.quotations
ADD CONSTRAINT quotations_owner_id_fk FOREIGN KEY (owner_id) REFERENCES public.accounts (account_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

UPDATE public.quotations
SET
    owner_id = 'a3c69ebc-b06e-49b0-ac97-5e7004cd1cf8';

ALTER TABLE public.quotations
ALTER COLUMN owner_id
SET NOT NULL;