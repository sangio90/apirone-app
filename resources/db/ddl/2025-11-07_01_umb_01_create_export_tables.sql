CREATE TABLE public.export_codes (
    export_code_id SERIAL PRIMARY KEY,
    export_code VARCHAR(25) NOT NULL,
    "counter" VARCHAR(6) NOT NULL,
    CONSTRAINT export_codes_unique UNIQUE (export_code, "counter")
);

ALTER TABLE export_codes owner TO apiruser;

CREATE TABLE public.export_code_raw_values (
    export_code_raw_value_id SERIAL PRIMARY KEY,
    export_code_id INTEGER NOT NULL,
    raw_value_id INTEGER NOT NULL,
    attribute_id UUID NOT NULL,
    important BOOLEAN DEFAULT TRUE,
    CONSTRAINT export_codes_raw_value_id_fk FOREIGN KEY (raw_value_id) REFERENCES public.raw_values (raw_value_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT export_codes_attribute_id_fk FOREIGN KEY (attribute_id) REFERENCES public.attributes (attribute_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT export_codes_export_code_raw_values_id_fk FOREIGN KEY (export_code_id) REFERENCES public.export_codes (export_code_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE export_code_raw_values owner TO apiruser;