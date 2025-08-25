CREATE TABLE public.metadata_types (
  metadata_type_id SERIAL,
  code VARCHAR(15) NOT NULL,
  metadata_type VARCHAR(255) NOT NULL,
  unit_id VARCHAR(20) NOT NULL,
  datatype_id VARCHAR(20) NOT NULL,
  entities JSONB,
  status_id VARCHAR(3) NOT NULL,
  orderby INTEGER STORAGE PLAIN DEFAULT 10 NOT NULL,
  created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
  CONSTRAINT metadata_types_code_key UNIQUE(code),
  CONSTRAINT metadata_types_pkey PRIMARY KEY(metadata_type_id),
  CONSTRAINT metadata_types_status_id_fk FOREIGN KEY (status_id)
    REFERENCES public.statuses(status_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE
) ;

ALTER TABLE public.metadata_types
  OWNER TO apiruser;

ALTER SEQUENCE public.metadata_types_metadata_type_id_seq
  INCREMENT 1 MINVALUE 1
  MAXVALUE 2147483647 START 1
  RESTART 100 CACHE 1
  NO CYCLE OWNED BY public.metadata_types.metadata_type_id;

CREATE TABLE public.metadata_values (
    metadata_value_id SERIAL PRIMARY KEY,
    metadata_type_id INTEGER NOT NULL,
    value_text TEXT NULL,
    value_char VARCHAR(255) NULL,
    value_integer INTEGER NULL,
    value_decimal DECIMAL(18,6) NULL,
    raw_value_id INTEGER NULL,
    CONSTRAINT metadata_type_id_fk FOREIGN KEY (metadata_type_id) REFERENCES metadata_types(metadata_type_id),
    CONSTRAINT raw_value_id_fk FOREIGN KEY (raw_value_id) REFERENCES raw_values(raw_value_id)
);

ALTER TABLE public.metadata_types OWNER TO apiruser;
ALTER TABLE public.metadata_values OWNER TO apiruser;


ALTER TABLE public.metadata_types
  ADD COLUMN orderby INTEGER DEFAULT 10 NOT NULL;


UPDATE statuses
SET
    entities = '["LINE", "ATTRIBUTE", "FINISH", "MODEL", "ACCOUNT", "PRODUCTION_TIME", "PRODUCT_CATEGORY", "PRODUCT", "RAW_VALUE", "METADATA_TYPE"]'
WHERE
    status_id IN ('ACT', 'DEA');

ALTER TABLE public.metadata_values
  RENAME TO metadata;

ALTER TABLE public.metadata
  RENAME COLUMN metadata_value_id TO metadata_id;

ALTER TABLE public.metadata
  ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;