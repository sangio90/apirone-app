ALTER TABLE profiles ALTER COLUMN created_at SET NOT NULL;

CREATE TABLE fonts (
    font_id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL,
    directory VARCHAR,
    dimension NUMERIC(10,2) NOT NULL,
    created_at timestamp default now()
);

ALTER TABLE texts
  ADD COLUMN font_id SERIAL;
CREATE UNIQUE INDEX texts_idx7 ON texts ("lang_id","font_id");