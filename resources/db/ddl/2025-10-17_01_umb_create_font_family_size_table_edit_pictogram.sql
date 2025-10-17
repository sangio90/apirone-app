CREATE TABLE font_family_sizes (
    font_family_size_id SERIAL PRIMARY KEY,
    font_family_size INTEGER NOT NULL,
    font_family_id INT NOT NULL,
    CONSTRAINT font_family_sizes_font_family_id_fk
        FOREIGN KEY (font_family_id)
        REFERENCES font_families (font_family_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT font_family_sizes_code_font_family_id_uk
        UNIQUE (font_family_size, font_family_id)
);