-- Storico delle proforma stampate.
--
-- Ogni lancio della stampa proforma produce una riga: progressivo, anticipo
-- indicato (percentuale OPPURE importo, mai entrambi) e riferimento al PDF
-- generato, che da ora viene archiviato su disco invece di essere solo
-- inviato al browser.
--
-- Una riga per stampa, non una per progressivo: ristampando lo stesso
-- progressivo restano visibili entrambe le generazioni.
--
-- stored_name / directory seguono la convenzione dei documenti allegati
-- (vedi quotation_documents e QuotationDocumentAjaxController): i file stanno
-- sotto repository/public/media/quotation-proformas/<directory>/<stored_name>
-- con directory = "yyyy/mm".

CREATE TABLE quotation_proformas (
    quotation_proforma_id UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_id          UUID         NOT NULL REFERENCES quotations(quotation_id) ON DELETE CASCADE,
    progressivo           VARCHAR(10)  NOT NULL,
    -- esattamente uno dei due valorizzato: l'anticipo è espresso in percentuale
    -- sul totale oppure come cifra fissa
    percentuale           NUMERIC(5,2),
    importo               NUMERIC(12,2),
    stored_name           VARCHAR(500) NOT NULL,
    directory             VARCHAR(20)  NOT NULL,
    created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    -- stessa destinazione di quotations.owner_id
    created_by            UUID         REFERENCES membership.users(user_id) ON UPDATE CASCADE,

    CONSTRAINT quotation_proformas_anticipo_chk CHECK (
        ( percentuale IS NOT NULL AND importo IS NULL )
        OR ( percentuale IS NULL AND importo IS NOT NULL )
    )
);

CREATE INDEX ON quotation_proformas(quotation_id);

-- Verifica
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'quotation_proformas'
ORDER BY ordinal_position;
