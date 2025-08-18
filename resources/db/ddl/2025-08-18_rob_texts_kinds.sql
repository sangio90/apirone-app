-- 2025-08-18 15:00:07
-- add text_kind_id to all unique keys
--
ALTER TABLE public.texts
DROP CONSTRAINT texts_idx RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx UNIQUE (finish_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.texts
DROP CONSTRAINT texts_idx1 RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx1 UNIQUE (file_kind_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.texts
DROP CONSTRAINT texts_idx3 RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx3 UNIQUE (product_category_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.texts
DROP CONSTRAINT texts_idx4 RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx4 UNIQUE (model_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.texts
DROP CONSTRAINT texts_idx5 RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx5 UNIQUE (attribute_id, lang_id, text_kind_id) NOT DEFERRABLE;

ALTER TABLE public.texts
DROP CONSTRAINT texts_idx7 RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_idx7 UNIQUE (font_id, lang_id, text_kind_id) NOT DEFERRABLE;
