ALTER TABLE public.font_family_sizes
ADD COLUMN enabled_pictograms BOOLEAN DEFAULT TRUE NOT NULL;

ALTER TABLE public.font_family_sizes
DROP CONSTRAINT font_family_sizes_code_font_family_id_uk RESTRICT;

ALTER TABLE public.font_family_sizes
ADD CONSTRAINT font_family_sizes_idx UNIQUE (font_family_size_id, font_family_id) NOT DEFERRABLE;

ALTER TABLE public.metadata
ALTER COLUMN value_decimal TYPE NUMERIC(18, 7);