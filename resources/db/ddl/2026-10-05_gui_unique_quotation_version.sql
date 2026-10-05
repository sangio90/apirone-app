-- Numero di versione unico per preventivo: UNIQUE ( quotation_number, version_number ).
--
-- Fino al 2026-07-17 ( commit 42f04db2 ) promoteStatus, mandando un preventivo in
-- approvazione, creava la copia con versione N+1 e incrementava ANCHE la versione
-- dell'originale: originale e copia finivano entrambi a N+1. È successo una volta,
-- al preventivo 184 il 2026-07-17 alle 10:26: l'originale 87295b61 ( in realtà la v1,
-- poi approvata ) e la copia 16f6a322 risultano entrambi v2.
-- Si riporta l'originale alla v1 ( non è stato inviato al cliente, esportato né ha
-- proforma: il numero non è uscito dall'applicazione ).
--
-- Il codice ora calcola la versione sotto lock ( QuotationService.nextVersionNumber ):
-- il vincolo è l'ultima difesa.

BEGIN;

UPDATE quotations
SET version_number = 1
WHERE quotation_id = '87295b61-fabe-492d-a71a-4167eb580876'
    AND quotation_number = '184'
    AND version_number = 2
    AND NOT EXISTS (
        SELECT 1 FROM quotations WHERE quotation_number = '184' AND version_number = 1
    );

-- Altri duplicati non previsti: si ferma invece di rinumerare alla cieca
DO $$
DECLARE
    dup TEXT;
BEGIN
    SELECT string_agg( quotation_number || '/' || version_number, ', ' )
    INTO dup
    FROM (
        SELECT quotation_number, version_number
        FROM quotations
        GROUP BY quotation_number, version_number
        HAVING COUNT(*) > 1
    ) d;

    IF dup IS NOT NULL THEN
        RAISE EXCEPTION 'Versioni duplicate da sistemare a mano prima del vincolo: %', dup;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS quotations_number_version_uidx
    ON quotations ( quotation_number, version_number );

COMMIT;

-- Verifica: non deve restituire nulla
-- SELECT quotation_number, version_number, COUNT(*) FROM quotations GROUP BY 1, 2 HAVING COUNT(*) > 1;
