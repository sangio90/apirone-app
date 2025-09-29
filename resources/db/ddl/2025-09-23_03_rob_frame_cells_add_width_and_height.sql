ALTER TABLE public.frame_cells
  ADD COLUMN width INTEGER;
  
ALTER TABLE public.frame_cells
  ADD COLUMN height INTEGER;

ALTER TABLE public.frame_cells
  ALTER COLUMN width SET DEFAULT 0;  

ALTER TABLE public.frame_cells
  ALTER COLUMN height SET DEFAULT 0;

ALTER TABLE public.frame_cells
  DROP COLUMN value;  