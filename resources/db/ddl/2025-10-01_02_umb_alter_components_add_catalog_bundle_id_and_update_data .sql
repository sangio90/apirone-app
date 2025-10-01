ALTER TABLE components
ADD COLUMN catalog_bundle_id UUID;
ALTER TABLE components
ADD CONSTRAINT components_catalog_bundle_id_fk FOREIGN KEY (catalog_bundle_id) REFERENCES catalog_bundles (catalog_bundle_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE;

UPDATE components c
SET catalog_bundle_id = cb.catalog_bundle_id
FROM catalog_bundles cb
WHERE cb.line_id = c.line_id
  AND cb.model_id = c.model_id
  AND cb.product_category_id = c.product_category_id;