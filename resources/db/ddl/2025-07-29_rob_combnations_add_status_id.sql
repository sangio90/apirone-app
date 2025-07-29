/*
  2025-07-29
*/

-- add status_id column to combinations table

ALTER TABLE public.combinations
  ADD COLUMN status_id VARCHAR(3) DEFAULT 'ACT' NOT NULL;

