ALTER TABLE quotation_items
    ADD COLUMN instance_group_id UUID NULL;

CREATE INDEX idx_quotation_items_instance_group_id
    ON quotation_items (instance_group_id)
    WHERE instance_group_id IS NOT NULL;
