CREATE TABLE public.pictogram_dimensions (
    pictogram_dimension_id SERIAL,
    font_family_size_id INTEGER STORAGE PLAIN NOT NULL,
    width INTEGER STORAGE PLAIN NOT NULL,
    heigth INTEGER STORAGE PLAIN NOT NULL,
    CONSTRAINT pictogram_dimensions_pkey PRIMARY KEY (pictogram_dimension_id)
);

ALTER TABLE public.pictogram_dimensions OWNER TO apiruser;

ALTER TABLE public.pictogram_dimensions
ADD CONSTRAINT pictogram_dimensions_font_family_size_id_fk FOREIGN KEY (font_family_size_id) REFERENCES public.font_family_sizes (font_family_size_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.pictogram_dimensions
ALTER COLUMN height
DROP NOT NULL;

ALTER TABLE public.pictogram_dimensions
ALTER COLUMN heigth
DROP NOT NULL;

ALTER TABLE public.pictogram_dimensions
ADD COLUMN pictogram_id INTEGER;

ALTER TABLE public.pictogram_dimensions
ADD CONSTRAINT pictogram_dimensions_pictogram_id_fk FOREIGN KEY (pictogram_id) REFERENCES public.pictograms (pictogram_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.pictogram_dimensions
RENAME COLUMN heigth TO height;

ALTER SEQUENCE public.font_family_sizes_font_family_size_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 RESTART 100 CACHE 1 NO CYCLE OWNED BY public.font_family_sizes.font_family_size_id;

ALTER SEQUENCE public.font_families_font_family_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 RESTART 100 CACHE 1 NO CYCLE OWNED BY public.font_families.font_family_id;

ALTER TABLE public.pictogram_dimensions
ADD CONSTRAINT pictogram_dimensions_idx UNIQUE (font_family_size_id, pictogram_id) NOT DEFERRABLE;

ALTER TABLE public.pictogram_dimensions
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;

ALTER TABLE public.pictogram_dimensions
ALTER COLUMN pictogram_id
SET NOT NULL;

ALTER TABLE public.pictogram_dimensions OWNER TO apiruser;
