ALTER TABLE public.quotation_item_product_items
DROP CONSTRAINT quotation_item_product_item_parent;

ALTER TABLE quotation_item_product_items
ALTER COLUMN origin_id DROP DEFAULT,
ALTER COLUMN origin_id TYPE integer
USING NULL;

ALTER TABLE public.quotation_item_product_items
ADD CONSTRAINT fk_quotation_item_product_item_origin_id FOREIGN KEY (origin_id) REFERENCES public.product_items (product_item_id);
