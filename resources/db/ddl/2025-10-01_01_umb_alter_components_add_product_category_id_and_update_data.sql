ALTER TABLE components
ADD COLUMN product_category_id INTEGER;
ALTER TABLE components
ADD CONSTRAINT components_product_category_id_fk FOREIGN KEY (product_category_id) REFERENCES product_categories (product_category_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

UPDATE components c
SET product_category_id = cb.product_category_id
FROM catalog_bundles cb
WHERE cb.line_id = c.line_id
  AND cb.model_id = c.model_id;