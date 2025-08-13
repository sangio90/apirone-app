CREATE TABLE public.catalog_bundles (
    catalog_bundle_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4 () NOT NULL,
    catalog_bundle VARCHAR(125) STORAGE PLAIN,
    line_id UUID STORAGE PLAIN NOT NULL,
    model_id UUID STORAGE PLAIN NOT NULL,
    product_category_id INTEGER STORAGE PLAIN NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
    CONSTRAINT catalog_bundles_pkey PRIMARY KEY (catalog_bundle_id),
    CONSTRAINT catalog_bundles_line_id_fk FOREIGN KEY (line_id) REFERENCES public.lines (line_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT catalog_bundles_model_id_fk FOREIGN KEY (model_id) REFERENCES public.models (model_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT catalog_bundles_product_category_id_fk FOREIGN KEY (product_category_id) REFERENCES public.product_categories (product_category_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

CREATE UNIQUE INDEX catalog_bundles_idx ON public.catalog_bundles USING btree (line_id, model_id, product_category_id);

ALTER TABLE public.catalog_bundles OWNER TO apiruser;

ALTER TABLE public.catalog_bundles
ALTER COLUMN catalog_bundle
SET
    STORAGE PLAIN;

CREATE TABLE public.signage_configs (
    signage_config_id SERIAL,
    catalog_bundle_id UUID STORAGE PLAIN,
    font_id INTEGER STORAGE PLAIN,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
    CONSTRAINT signage_configs_pkey PRIMARY KEY (signage_config_id),
    CONSTRAINT signage_configs_font_id_fk FOREIGN KEY (font_id) REFERENCES public.fonts (font_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT signage_configs_catalog_bundle_id_fk FOREIGN KEY (catalog_bundle_id) REFERENCES public.catalog_bundles (catalog_bundle_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.signage_configs OWNER TO apiruser;

CREATE TABLE public.signage_config_items (
    signage_config_item_id SERIAL NOT NULL,
    signage_config_id INTEGER STORAGE PLAIN NOT NULL,
    height NUMERIC(10, 5) STORAGE MAIN NOT NULL,
    height_in_pixel INTEGER STORAGE PLAIN,
    row_count INTEGER STORAGE PLAIN NOT NULL,
    char_count INTEGER STORAGE PLAIN NOT NULL,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
    CONSTRAINT signage_config_items_pkey PRIMARY KEY (signage_config_item_id),
    CONSTRAINT signage_config_items_signage_config_id_fk FOREIGN KEY (signage_config_id) REFERENCES public.signage_configs (signage_config_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.signage_config_items OWNER TO apiruser;
