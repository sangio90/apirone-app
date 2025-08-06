-- object recreation
ALTER TABLE public.components
DROP CONSTRAINT components_product_id_fk RESTRICT;

ALTER TABLE public.components
ADD CONSTRAINT components_product_id_fk FOREIGN KEY (product_id) REFERENCES public.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;