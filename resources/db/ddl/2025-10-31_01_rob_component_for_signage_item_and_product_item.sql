ALTER TABLE public.components
ADD CONSTRAINT components_statsus_id_fk FOREIGN KEY (status_id) REFERENCES public.statuses (status_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.components
DROP COLUMN _fruit_combination_item_id;

ALTER TABLE public.components
DROP COLUMN _fruit_id;

ALTER TABLE public.components
ADD COLUMN signage_config_item_join_id INTEGER STORAGE PLAIN;

ALTER TABLE public.components
ADD COLUMN product_item_join_id INTEGER STORAGE PLAIN;

ALTER TABLE public.components
ADD CONSTRAINT components_signage_config_item_join_id_fk FOREIGN KEY (signage_config_item_join_id) REFERENCES public.signage_config_items (signage_config_item_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.components
ADD CONSTRAINT components_product_item_join_id_fk FOREIGN KEY (product_item_join_id) REFERENCES public.product_items (product_item_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE public.components
ADD CONSTRAINT components_idx1 UNIQUE (
    signage_config_item_join_id,
    product_item_join_id,
    raw_product_id,
    color_id,
    variant_id
) NOT DEFERRABLE;