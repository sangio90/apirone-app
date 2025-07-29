/*
  2025-07-29
*/

-- add status_id column to combinations table

ALTER TABLE public.combinations
  ADD COLUMN status_id VARCHAR(3) DEFAULT 'ACT' NOT NULL;

-- set status_id not null and default to 'ACT'

ALTER TABLE public.combinations
  ALTER COLUMN status_id SET DEFAULT 'ACT'::character varying;

ALTER TABLE public.combinations
  ALTER COLUMN status_id SET NOT NULL;