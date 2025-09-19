ALTER TABLE quotation_items
ADD COLUMN signage_config_item_id INTEGER NULL,
ADD COLUMN font_size FLOAT NULL,
ADD COLUMN char_count INTEGER NULL,
ADD COLUMN height FLOAT NULL,
ADD COLUMN height_in_pixel FLOAT NULL,
ADD COLUMN row_count INTEGER NULL;

ALTER TABLE quotation_items
ADD CONSTRAINT quotation_items_signage_config_items_fk
FOREIGN KEY (signage_config_item_id)
REFERENCES signage_config_items(signage_config_item_id);

CREATE TABLE quotation_item_signage_rows (
    quotation_item_signage_row_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_item_id UUID NOT NULL REFERENCES quotation_items(quotation_item_id) ON DELETE CASCADE,
    text_align VARCHAR(10) NOT NULL,
    content TEXT NOT NULL,
    char_count INTEGER NULL,
    orderby INTEGER NOT NULL
);


ALTER TABLE quotation_item_signage_rows OWNER TO apiruser;