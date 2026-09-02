-- Il progressivo identifica la proforma all'interno del preventivo: la coppia
-- (preventivo, progressivo) deve essere unica.
--
-- Un progressivo già usato va RIFIUTATO, non sovrascritto: la proforma emessa
-- resta quella, con il suo PDF. Il controllo esplicito sta in
-- QuotationProformaService.existsProgressivo(), chiamato prima di generare il
-- documento; questo vincolo è l'ultima difesa contro due richieste in parallelo.

-- Eventuali doppioni già presenti: si tiene la generazione più recente.
DELETE FROM quotation_proformas a
USING quotation_proformas b
WHERE a.quotation_id = b.quotation_id
  AND a.progressivo  = b.progressivo
  AND (
        a.created_at < b.created_at
        OR ( a.created_at = b.created_at AND a.quotation_proforma_id < b.quotation_proforma_id )
      );

ALTER TABLE quotation_proformas
    ADD CONSTRAINT quotation_proformas_quotation_progressivo_uk
    UNIQUE ( quotation_id, progressivo );

-- Verifica
SELECT conname, pg_get_constraintdef( oid ) AS definizione
FROM pg_constraint
WHERE conrelid = 'quotation_proformas'::regclass
ORDER BY conname;
