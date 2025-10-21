-- Creazioni/estensioni idempotenti
CREATE SCHEMA IF NOT EXISTS utils AUTHORIZATION apiruser;

CREATE TABLE IF NOT EXISTS utils.search_terms (
    search_term_id SERIAL,
    search_term TEXT STORAGE PLAIN,
    product_id UUID STORAGE PLAIN,
    CONSTRAINT search_terms_pkey PRIMARY KEY (search_term_id),
    CONSTRAINT search_terms_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE utils.search_terms OWNER TO apiruser;

ALTER TABLE utils.search_terms
ALTER COLUMN search_term
SET
    STORAGE PLAIN;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE EXTENSION IF NOT EXISTS btree_gin;

-- Indice GIN per ricerche fuzzy con pg_trgm
CREATE INDEX IF NOT EXISTS search_terms_gin_idx ON utils.search_terms USING gin (search_term gin_trgm_ops);

ALTER TABLE utils.search_terms
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;

ALTER TABLE utils.search_terms
ADD COLUMN lang_id CHAR(2);

ALTER TABLE utils.search_terms
ADD CONSTRAINT search_terms_lang_id_fk FOREIGN KEY (lang_id) REFERENCES public.langs (lang_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER SEQUENCE utils.search_terms_search_term_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 100 RESTART 61 CACHE 1 NO CYCLE OWNED BY utils.search_terms.search_term_id;