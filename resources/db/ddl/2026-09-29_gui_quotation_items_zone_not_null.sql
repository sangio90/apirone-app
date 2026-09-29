-- Ogni articolo di preventivo deve avere una zona (almeno "Non assegnato"): diversi punti
-- (totali, stampe tecniche, export) leggono zone.getQuantity()/getOrigin() senza controlli
-- e con zona NULL vanno in errore 500.

-- 1. Crea la zona "Non assegnato" per i preventivi che hanno articoli senza zona e ne sono privi
INSERT INTO quotation_zones ( quotation_id, quotation_zone, quantity )
SELECT DISTINCT qi.quotation_id, 'Non assegnato', 1
FROM quotation_items qi
WHERE qi.quotation_zone_id IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM quotation_zones qz
      WHERE qz.quotation_id = qi.quotation_id
        AND qz.quotation_zone = 'Non assegnato'
        AND qz.origin_id IS NULL
  );

-- 2. Sposta gli articoli senza zona nella zona "Non assegnato" del loro preventivo
UPDATE quotation_items qi
SET quotation_zone_id = qz.quotation_zone_id
FROM quotation_zones qz
WHERE qi.quotation_zone_id IS NULL
  AND qz.quotation_id = qi.quotation_id
  AND qz.quotation_zone = 'Non assegnato'
  AND qz.origin_id IS NULL;

-- 3. Da qui in avanti un articolo senza zona è un errore esplicito, non un dato corrotto
ALTER TABLE quotation_items ALTER COLUMN quotation_zone_id SET NOT NULL;
