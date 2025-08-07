-- unused field
ALTER TABLE public.texts
DROP CONSTRAINT texts_idx6 RESTRICT;

-- object recreation
DROP INDEX public.texts_idx7;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx7 UNIQUE (font_id, lang_id) NOT DEFERRABLE;

-- add cascade on texts
ALTER TABLE public.texts
DROP CONSTRAINT texts_font_id_fk RESTRICT;

ALTER TABLE texts
ADD CONSTRAINT texts_font_id_fk FOREIGN KEY (font_id) REFERENCES fonts (font_id) ON UPDATE CASCADE ON DELETE CASCADE;

-- add cascade on texts
ALTER TABLE public.texts
DROP CONSTRAINT texts_line_id_fk RESTRICT;

ALTER TABLE texts
ADD CONSTRAINT texts_line_id_fk FOREIGN KEY (line_id) REFERENCES lines (line_id) ON UPDATE CASCADE ON DELETE CASCADE;
