ALTER TABLE profiles
ALTER COLUMN created_at
SET NOT NULL;

CREATE TABLE fonts (
  font_id SERIAL PRIMARY KEY,
  code VARCHAR(5) NOT NULL,
  directory VARCHAR,
  dimension NUMERIC(10, 2) NOT NULL,
  created_at timestamp DEFAULT now()
);

ALTER TABLE texts
ADD COLUMN font_id integer;

ALTER TABLE texts
ADD CONSTRAINT texts_font_id_fk FOREIGN KEY (font_id) REFERENCES fonts (font_id);

ALTER TABLE texts
ADD CONSTRAINT texts_line_id_fk FOREIGN KEY (line_id) REFERENCES lines (line_id);
