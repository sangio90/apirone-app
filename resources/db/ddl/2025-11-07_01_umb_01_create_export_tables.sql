CREATE TABLE public.export_codes (
  export_code_id SERIAL PRIMARY KEY,
  export_code VARCHAR(15) NOT NULL,
  product_category_id INTEGER NOT NULL,
  line_id UUID NOT NULL,
  model_id UUID,
  finish_id UUID,
  product_id UUID,
  CONSTRAINT export_codes_product_category_id_fk FOREIGN KEY (product_category_id)
    REFERENCES public.product_categories (product_category_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT export_codes_line_id_fk FOREIGN KEY (line_id)
    REFERENCES public.lines (line_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT export_codes_model_id_fk FOREIGN KEY (model_id)
    REFERENCES public.models (model_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT export_codes_finish_id_fk FOREIGN KEY (finish_id)
    REFERENCES public.finishes (finish_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE,
  CONSTRAINT export_codes_product_id_fk FOREIGN KEY (product_id)
    REFERENCES public.products (product_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE
);

ALTER TABLE export_codes owner TO apiruser;

CREATE TABLE public.export_code_raw_values (
  export_code_raw_value_id SERIAL PRIMARY KEY,
  raw_value_id INTEGER NOT NULL,
  important BOOLEAN DEFAULT TRUE,
  suffix_code VARCHAR(6) NOT NULL,
  CONSTRAINT export_codes_raw_value_id_fk FOREIGN KEY (raw_value_id)
    REFERENCES public.raw_values (raw_value_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE
)

ALTER TABLE export_code_raw_values owner TO apiruser;