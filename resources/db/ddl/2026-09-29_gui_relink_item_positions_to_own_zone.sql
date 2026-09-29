-- La duplicazione di una zona copiava negli articoli quotation_zone_position_id della zona
-- di origine: la copia puntava a una posizione di un'altra zona. Qui si ricrea la posizione
-- (stesso codice) nella zona dell'articolo e si ricollega l'articolo.
-- Da eseguire dopo 2026-09-29_gui_quotation_items_zone_not_null.sql.

-- 1. Posizioni mancanti nella zona dell'articolo (una per codice)
INSERT INTO quotation_zone_positions ( quotation_zone_id, quotation_zone_position, code )
SELECT DISTINCT ON ( qi.quotation_zone_id, src.code )
    qi.quotation_zone_id, src.quotation_zone_position, src.code
FROM quotation_items qi
JOIN quotation_zone_positions src ON src.quotation_zone_position_id = qi.quotation_zone_position_id
WHERE src.quotation_zone_id <> qi.quotation_zone_id
  AND NOT EXISTS (
      SELECT 1 FROM quotation_zone_positions own
      WHERE own.quotation_zone_id = qi.quotation_zone_id
        AND own.code IS NOT DISTINCT FROM src.code
  )
ORDER BY qi.quotation_zone_id, src.code, src.quotation_zone_position_id;

-- 2. Ricollega gli articoli alla posizione della propria zona
UPDATE quotation_items qi
SET quotation_zone_position_id = (
    SELECT MIN( own.quotation_zone_position_id )
    FROM quotation_zone_positions own
    WHERE own.quotation_zone_id = qi.quotation_zone_id
      AND own.code IS NOT DISTINCT FROM src.code
)
FROM quotation_zone_positions src
WHERE src.quotation_zone_position_id = qi.quotation_zone_position_id
  AND src.quotation_zone_id <> qi.quotation_zone_id;
