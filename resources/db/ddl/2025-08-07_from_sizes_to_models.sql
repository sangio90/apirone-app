-- move from "sizes" to "models"
ALTER TABLE public.sizes
RENAME TO models;

ALTER TABLE public.models
RENAME COLUMN size_id TO model_id;

ALTER TABLE public.texts
RENAME COLUMN size_id TO model_id;

ALTER TABLE public.texts
DROP COLUMN _fruit_id;

ALTER TABLE public.products
RENAME COLUMN size_id TO model_id;

ALTER TABLE public.size_configs
RENAME TO model_configs;

ALTER TABLE public.model_configs
RENAME COLUMN size_config_id TO model_config_id;

ALTER TABLE public.model_configs
RENAME COLUMN size_id TO model_id;

ALTER TABLE public.components
RENAME COLUMN size_id TO model_id;

ALTER TABLE public.components
RENAME CONSTRAINT components_size_id_fk TO components_model_id_fk;

DROP TABLE public._configurations;

ALTER TABLE public.models
RENAME COLUMN size TO model;

ALTER TABLE public.models
RENAME COLUMN size_type_id TO model_type_id;

UPDATE statuses
SET
    entities = '["LINE", "ATTRIBUTE", "FINISH", "MODEL", "ACCOUNT", "PRODUCTION_TIME", "PRODUCT_CATEGORY", "PRODUCT", "RAW_VALUE"]'
WHERE
    status_id IN ('ACT', 'DEA');

UPDATE statuses
SET
    entities = '["QUOTATION"]'
WHERE
    status_id IN (
        'NEW',
        'END',
        'EST',
        'PRO',
        'APR',
        'CON',
        'PER',
        'LAV'
    );

ALTER TABLE public.texts
RENAME CONSTRAINT texts_fk TO texts_model_id_fk;

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_font_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_font_id_fk FOREIGN KEY (font_id) REFERENCES public.fonts (font_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_line_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_line_id_fk FOREIGN KEY (line_id) REFERENCES public.lines (line_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_font_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_font_id_fk FOREIGN KEY (font_id) REFERENCES public.fonts (font_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_lang_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_lang_id_fk FOREIGN KEY (lang_id) REFERENCES public.langs (lang_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_status_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_status_id_fk FOREIGN KEY (status_id) REFERENCES public.statuses (status_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;