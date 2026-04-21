CREATE TABLE quotation_item_positions (
  quotation_item_position_id SERIAL PRIMARY KEY,
  quotation_item_id uuid NOT NULL,
  sequence INTEGER NOT NULL,
  coordinate_x NUMERIC(5,4) NOT NULL DEFAULT 0.5,
  coordinate_y NUMERIC(5,4) NOT NULL DEFAULT 0.5,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  CONSTRAINT fk_quotation_item_positions_quotation_item_id
	  FOREIGN KEY (quotation_item_id)
		  REFERENCES quotation_items (quotation_item_id)
		  ON DELETE CASCADE,
  CONSTRAINT uq_quotation_item_sequence
	  UNIQUE (quotation_item_id, sequence)
);

ALTER TABLE quotation_zones
	ADD COLUMN map_file TEXT;


















