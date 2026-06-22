CREATE TABLE quotation_item_drafts (
  quotation_item_draft_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quotation_id            UUID NOT NULL,
  quotation_zone_id       UUID NOT NULL,
  item_type               VARCHAR(3) NOT NULL CHECK (item_type IN ('ACC', 'SEG', 'PLA')),
  coordinate_x            NUMERIC(5,4) NOT NULL DEFAULT 0.5000,
  coordinate_y            NUMERIC(5,4) NOT NULL DEFAULT 0.5000,
  angle                   INTEGER NOT NULL DEFAULT 0,
  created_at              TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  CONSTRAINT fk_qid_quotation
    FOREIGN KEY (quotation_id)
    REFERENCES quotations (quotation_id) ON DELETE CASCADE,
  CONSTRAINT fk_qid_zone
    FOREIGN KEY (quotation_zone_id)
    REFERENCES quotation_zones (quotation_zone_id) ON DELETE CASCADE
);

CREATE INDEX idx_qid_quotation ON quotation_item_drafts (quotation_id);
CREATE INDEX idx_qid_zone      ON quotation_item_drafts (quotation_zone_id);
