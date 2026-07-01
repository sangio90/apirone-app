-- Rotazione per singolo blocco nelle placche dei preventivi:
-- override dell'orientamento dei blocchi rispetto alla configurazione
-- della placca, valido solo per la riga di preventivo.
-- JSON { "<block order>": "HOR"|"VER" }, es. {"0":"VER"}

ALTER TABLE public.quotation_items
  ADD COLUMN block_orientations TEXT;

COMMENT ON COLUMN public.quotation_items.block_orientations
IS 'Override orientamento blocchi placca, JSON {"<order>":"HOR|VER"}';
