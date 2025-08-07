/*
  2025-07-24
*/

-- create table sizes_configs

CREATE TABLE public.sizes_configs (
  size_config_id UUID STORAGE PLAIN NOT NULL,
  size_id UUID STORAGE PLAIN NOT NULL,
  product_category_id INTEGER STORAGE PLAIN NOT NULL,
  line_id UUID STORAGE PLAIN NOT NULL,
  width NUMERIC(10,2) STORAGE MAIN,
  height NUMERIC(10,2) STORAGE MAIN,
  CONSTRAINT size_configs_pkey PRIMARY KEY(size_config_id),
  CONSTRAINT size_configs_line_id_fk FOREIGN KEY (line_id)
    REFERENCES public.lines(line_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT size_configs_product_category_id_fk FOREIGN KEY (product_category_id)
    REFERENCES public.product_categories(product_category_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT size_configs_size_id_fk FOREIGN KEY (size_id)
    REFERENCES public.sizes(size_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE
) ;

CREATE INDEX sizes_configs_idx ON public.sizes_configs
  USING btree (size_id, product_category_id, line_id);

ALTER TABLE public.sizes_configs
  OWNER TO apiruser;