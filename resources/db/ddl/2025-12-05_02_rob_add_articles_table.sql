CREATE TABLE public.articles (
    article_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4 () NOT NULL,
    type_id VARCHAR(3) STORAGE PLAIN,
    price NUMERIC(10, 5) STORAGE PLAIN,
    external_id VARCHAR(15) STORAGE PLAIN,
    code VARCHAR(10),
    CONSTRAINT articles_code_key UNIQUE (code),
    CONSTRAINT articles_pkey PRIMARY KEY (article_id)
);

ALTER TABLE public.articles OWNER TO apiruser;

ALTER TABLE public.articles
ALTER COLUMN type_id
SET
    STORAGE PLAIN;

ALTER TABLE public.articles
ALTER COLUMN price
SET
    STORAGE PLAIN;

ALTER TABLE public.articles
ALTER COLUMN external_id
SET
    STORAGE PLAIN;

ALTER TABLE public.texts
ADD COLUMN article_id UUID;

ALTER TABLE public.texts
ADD CONSTRAINT texts_article_id FOREIGN KEY (article_id) REFERENCES public.articles (article_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx2 UNIQUE (article_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.articles
ADD COLUMN status_id VARCHAR(3);

ALTER TABLE public.articles
ADD CONSTRAINT "articles_status_id_fk" FOREIGN KEY (status_id) REFERENCES public.statuses (status_id) ON DELETE NO ACTION ON UPDATE NO ACTION NOT DEFERRABLE;

ALTER TABLE public.articles
ALTER COLUMN code
SET NOT NULL;

UPDATE statuses
SET
    entities = '["LINE", "ATTRIBUTE", "FINISH", "MODEL", "ACCOUNT", "PRODUCTION_TIME", "PRODUCT_CATEGORY", "PRODUCT", "RAW_VALUE", "METADATA_TYPE", "FRAME", "PRICE_TYPE", "ARTICLE"]'
WHERE
    status_id IN ('ACT', 'DEA');

ALTER TABLE public.prices
ADD COLUMN article_id UUID;

ALTER TABLE public.prices
ADD CONSTRAINT prices_article_id_fk FOREIGN KEY (article_id) REFERENCES public.articles (article_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

INSERT INTO
    public.price_types (
        "price_type_id",
        "price_type",
        "entities",
        "created_at",
        "status_id",
        "orderby",
        "methods"
    )
VALUES
    (
        E'SERVICE_PRICE',
        E'PREZZI DEI SERVIZI',
        E'null',
        E'2025-12-06 23:46:06',
        E'ACT',
        10,
        E'["F"]'
    );

ALTER TABLE public.prices
ADD CONSTRAINT prices_idx2 UNIQUE (article_id) NOT DEFERRABLE;

ALTER TABLE public.articles
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;