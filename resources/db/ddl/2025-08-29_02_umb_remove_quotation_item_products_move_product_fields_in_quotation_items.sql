

-- Prima rimuovi la foreign key che dipende dalla tabella
ALTER TABLE quotation_item_product_items
  DROP CONSTRAINT IF EXISTS fk_quotation_item_product_item_quotation_item_product;

DROP TABLE quotation_item_products;


-- Assicurati che quotation_item_id sia dello stesso tipo della chiave primaria di quotation_items (uuid)
ALTER TABLE quotation_item_product_items
  DROP COLUMN quotation_item_product_id,
  ADD COLUMN quotation_item_id uuid;


ALTER TABLE quotation_item_product_items
  ADD CONSTRAINT fk_quotation_item_product_item_quotation_item
    FOREIGN KEY (quotation_item_id) REFERENCES quotation_items (quotation_item_id);


-- Assicurati che product_id e product_parent_id siano dello stesso tipo della chiave primaria di products (uuid)
ALTER TABLE quotation_items
  ADD COLUMN product_id uuid,
  ADD COLUMN product_origin_id uuid;


ALTER TABLE quotation_items
  ADD CONSTRAINT fk_quotation_items_product_id
    FOREIGN KEY (product_id) REFERENCES products (product_id),
  ADD CONSTRAINT fk_quotation_items_product_origin_id
    FOREIGN KEY (product_origin_id) REFERENCES products (product_id);

ALTER TABLE public.quotation_item_product_items
  RENAME COLUMN parent_id TO origin_id;  