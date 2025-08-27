/*
  2025-08-19 21:02:17
*/

ALTER TABLE public.quotation_item_zones
  RENAME COLUMN parent_id TO origin_id;

ALTER TABLE public.product_items
  RENAME COLUMN parent_id TO origin_id;  
  