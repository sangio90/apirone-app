
ALTER TABLE public.texts
ADD COLUMN country_id UUID;

ALTER TABLE public.texts
ADD CONSTRAINT texts_country_id_fk FOREIGN KEY (country_id) REFERENCES public.countries (country_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx8 UNIQUE (country_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE countries
ALTER COLUMN country_id SET DEFAULT uuid_generate_v4();

INSERT INTO texts (country_id, lang_id, text, status_id, text_kind_id)
SELECT 
    c.country_id,
    l.lang_id,
    CASE 
        WHEN l.lang_id = 'IT' THEN c.country
        ELSE '** To translate'
    END AS text,
    CASE 
        WHEN l.lang_id = 'IT' THEN 'TRA'
        ELSE 'TOT'
    END AS status_id,
    'NAME' AS text_kind_id
FROM countries c
CROSS JOIN (
    VALUES ('ES'), ('DE'), ('FR'), ('EN'), ('IT')
) AS l(lang_id);