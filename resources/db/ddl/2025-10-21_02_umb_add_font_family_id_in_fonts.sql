ALTER TABLE fonts
ADD COLUMN font_family_id INT;

ALTER TABLE fonts
ADD CONSTRAINT fonts_font_family_id_fk
FOREIGN KEY (font_family_id)
REFERENCES font_families (font_family_id)
ON UPDATE CASCADE
ON DELETE SET NULL;
