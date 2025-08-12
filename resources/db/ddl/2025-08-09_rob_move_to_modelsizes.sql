-- 2025-08-11 17:09
CREATE TABLE public.linemodels (
    linemodel_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4 (),
    linemodel VARCHAR(125) STORAGE PLAIN,
    line_id UUID STORAGE PLAIN,
    model_id UUID STORAGE PLAIN,
    product_category_id INTEGER STORAGE PLAIN,
    created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now(),
    PRIMARY KEY (linemodel_id)
);

ALTER TABLE public.linemodels
ALTER COLUMN product_category_id
SET NOT NULL;

ALTER TABLE public.linemodels
ALTER COLUMN model_id
SET NOT NULL;

ALTER TABLE public.linemodels
ALTER COLUMN line_id
SET NOT NULL;

CREATE UNIQUE INDEX linemodels_idx ON public.linemodels USING btree (line_id, model_id, product_category_id);

ALTER TABLE public.linemodels
ADD CONSTRAINT linemodels_line_id_fk FOREIGN KEY (line_id) REFERENCES public.lines (line_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.linemodels
ADD CONSTRAINT linemodels_model_id_fk FOREIGN KEY (model_id) REFERENCES public.models (model_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.linemodels
ADD CONSTRAINT linemodels_product_category_id_fk FOREIGN KEY (product_category_id) REFERENCES public.product_categories (product_category_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;
