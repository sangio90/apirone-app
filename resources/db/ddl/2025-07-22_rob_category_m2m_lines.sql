-- 2025-07-22
/*
CREATE TABLE product_categories_lines 
    AS SELECT line_id, product_category_id, status_id from lines ;

ALTER TABLE product_categories_lines 
    OWNER TO apiruser;

ALTER TABLE public.product_categories_lines
  ALTER COLUMN line_id SET NOT NULL;
ALTER TABLE public.product_categories_lines
  ALTER COLUMN product_category_id SET NOT NULL;

ALTER TABLE public.product_categories_lines
  ADD CONSTRAINT product_categories_lines_idx 
    PRIMARY KEY (line_id, product_category_id) NOT DEFERRABLE;

ALTER TABLE public.product_categories_lines
  ADD CONSTRAINT product_categories_lines_line_id_fk FOREIGN KEY (line_id)
    REFERENCES public.lines(line_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.product_categories_lines
  ADD CONSTRAINT product_categories_lines_product_category_id_fk FOREIGN KEY (product_category_id)
    REFERENCES public.product_categories(product_category_id)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE public.product_categories_lines
  ADD COLUMN created_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now();

ALTER TABLE public.product_categories_lines
  ALTER COLUMN created_date SET NOT NULL;

ALTER TABLE public.product_categories_lines
  ADD CONSTRAINT product_categories_lines_status_id_fk FOREIGN KEY (status_id)
    REFERENCES public.statuses(status_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;
*/

ALTER TABLE public.lines
  ADD COLUMN categories JSONB;

 UPDATE lines
    SET categories = json_build_array ( product_category_id );

ALTER TABLE public.lines
    RENAME COLUMN product_category_id TO _product_category_id;

