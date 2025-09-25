ALTER TABLE public.frame_cells
  ADD COLUMN type_id VARCHAR(5) DEFAULT 'AVAIL' NOT NULL;

COMMENT ON COLUMN public.frame_cells.type_id
IS 'EMPTY: Vuoto, AVAIL: Disponibile, NOTAV: Non disponibile';

ALTER TABLE public.frame_cells
  ADD COLUMN orientatio_id VARCHAR(3) DEFAULT 'HOR' NOT NULL;