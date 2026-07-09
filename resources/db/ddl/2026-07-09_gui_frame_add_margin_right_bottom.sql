-- Aggiunge margini finali alla placca: spazio dopo l'ultimo blocco verso il bordo destro e inferiore.
ALTER TABLE frames
    ADD COLUMN margin_right_mm  NUMERIC(6,2) NOT NULL DEFAULT 0,
    ADD COLUMN margin_bottom_mm NUMERIC(6,2) NOT NULL DEFAULT 0;

COMMENT ON COLUMN frames.margin_right_mm  IS 'Margine dal bordo destro del contenuto (dopo l''ultimo blocco) al bordo destro della placca, in mm.';
COMMENT ON COLUMN frames.margin_bottom_mm IS 'Margine dal bordo inferiore del contenuto (dopo l''ultimo blocco) al bordo inferiore della placca, in mm.';
