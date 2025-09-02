INSERT INTO catalog_bundles (catalog_bundle_id, line_id, model_id, product_category_id)
SELECT gen_random_uuid(), line_id, model_id, product_category_id
FROM products
WHERE line_id IS NOT NULL AND model_id IS NOT NULL AND product_category_id IS NOT NULL
GROUP BY line_id, model_id, product_category_id
ON CONFLICT (line_id, model_id, product_category_id) DO NOTHING;

ALTER TABLE products
ADD COLUMN catalog_bundle_id UUID;

UPDATE products
SET catalog_bundle_id = catalog_bundles.catalog_bundle_id
FROM catalog_bundles
WHERE products.line_id = catalog_bundles.line_id
  AND products.model_id = catalog_bundles.model_id
  AND products.product_category_id = catalog_bundles.product_category_id;

ALTER TABLE products
ADD CONSTRAINT products_catalog_bundle_fk
FOREIGN KEY (catalog_bundle_id)
REFERENCES catalog_bundles(catalog_bundle_id);

