ALTER TABLE public.quotations
ADD COLUMN active INTEGER NOT NULL DEFAULT 1,
ADD COLUMN version_number INTEGER NOT NULL DEFAULT 1;

ALTER TABLE quotations DROP CONSTRAINT quotations_quotation_number_key;