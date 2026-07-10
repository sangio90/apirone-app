-- Performance indexes for /manager/ajax/product-items endpoint
-- These tables have no FK indexes (PostgreSQL does not create them automatically).

-- Main query in ProductItemDAO.find(): WHERE product_id = ? AND origin_id = ? ORDER BY orderby
-- Covers both IS NULL and = value cases for origin_id.
CREATE INDEX IF NOT EXISTS idx_product_items_product_origin_order
    ON product_items (product_id, origin_id, orderby);

-- PriceDAO.findByProductItemIds(): WHERE product_item_id IN (...)
CREATE INDEX IF NOT EXISTS idx_prices_product_item_id
    ON prices (product_item_id);

-- FileDAO.findByEntityIds("productItem.id", ...): WHERE product_item_id IN (...)
CREATE INDEX IF NOT EXISTS idx_files_product_item_id
    ON files (product_item_id) WHERE deleted_at IS NULL;

-- FileDAO.findByEntityIds("attributeValue.id", ...): WHERE attribute_raw_value_id IN (...)
CREATE INDEX IF NOT EXISTS idx_files_attribute_raw_value_id
    ON files (attribute_raw_value_id) WHERE deleted_at IS NULL;

-- TextDAO.findByEntityIds("rawValue.id", ...): WHERE raw_value_id IN (...)
CREATE INDEX IF NOT EXISTS idx_texts_raw_value_id
    ON texts (raw_value_id);

-- TextDAO.findByEntityIds("attribute.id", ...): WHERE attribute_id = ANY(...)
CREATE INDEX IF NOT EXISTS idx_texts_attribute_id
    ON texts (attribute_id);

-- AttributeValueDAO.readByAttributeIds(): WHERE attribute_id = ANY(...)
CREATE INDEX IF NOT EXISTS idx_attributes_raw_values_attribute_id
    ON attributes_raw_values (attribute_id);