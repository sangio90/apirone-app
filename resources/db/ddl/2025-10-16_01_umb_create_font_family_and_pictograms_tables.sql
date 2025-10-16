CREATE TABLE font_families (
    font_family_id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    font_family VARCHAR(255) NOT NULL
);

CREATE TABLE pictograms (
    pictogram_id SERIAL PRIMARY KEY,
    code VARCHAR(255) NOT NULL,
    font_family_id INT NOT NULL,
    CONSTRAINT pictograms_font_family_id_fk
        FOREIGN KEY (font_family_id)
        REFERENCES font_families (font_family_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT pictograms_code_font_family_id_uk
        UNIQUE (code, font_family_id)
);

ALTER TABLE files
ADD COLUMN pictogram_id INT NULL;

ALTER TABLE files
ADD CONSTRAINT files_pictogram_id_fk
    FOREIGN KEY (pictogram_id)
    REFERENCES pictograms (pictogram_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;
