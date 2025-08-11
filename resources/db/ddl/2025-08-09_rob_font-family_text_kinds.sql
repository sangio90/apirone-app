ALTER TABLE public.fonts
ADD COLUMN family VARCHAR(125);

CREATE TABLE public.text_kinds (
    text_kind_id VARCHAR(10) STORAGE PLAIN,
    PRIMARY KEY (text_kind_id)
);

-- CREATE TEXT_KINDS table
ALTER TABLE public.text_kinds
ALTER COLUMN text_kind_id TYPE VARCHAR(25) COLLATE pg_catalog."default";

ALTER TABLE public.text_kinds
ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;

INSERT INTO
    public.text_kinds ("text_kind_id")
VALUES
    (E'DESCRIPTION'),
    (E'NAME');

ALTER TABLE public.texts
ADD COLUMN text_kind_id VARCHAR(25);

ALTER TABLE public.texts
ADD CONSTRAINT texts_kind_id_fk FOREIGN KEY (text_kind_id) REFERENCES public.text_kinds (text_kind_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

UPDATE texts
SET
    text_kind_id = 'NAME';

ALTER TABLE public.fonts
ADD UNIQUE (code);

ALTER TABLE public.lines
ALTER COLUMN code
SET NOT NULL;

ALTER TABLE public.lines
ADD UNIQUE (code);