ALTER TABLE signage_config_items
ADD COLUMN font_family_size_id INT;

ALTER TABLE signage_config_items
ADD CONSTRAINT signage_config_items_font_family_size_id_fk
FOREIGN KEY (font_family_size_id)
REFERENCES font_family_sizes (font_family_size_id)
ON UPDATE CASCADE
ON DELETE SET NULL;
