INSERT INTO catalog_bundles (id, line_id, model_id, product_category_id)
SELECT gen_random_uuid(), line_id, model_id, product_category_id
FROM products
GROUP BY line_id, model_id, product_category_id
ON CONFLICT (line_id, model_id, product_category_id) DO NOTHING;

ALTER TABLE products
ADD COLUMN catalog_bundle_id UUID;

UPDATE products
SET catalog_bundle_id = catalog_bundles.id
FROM catalog_bundles
WHERE products.line_id = catalog_bundles.line_id
  AND products.model_id = catalog_bundles.model_id
  AND products.product_category_id = catalog_bundles.product_category_id;

ALTER TABLE products
ADD CONSTRAINT fk_products_catalog_bundle
FOREIGN KEY (catalog_bundle_id)
REFERENCES catalog_bundles(id);

