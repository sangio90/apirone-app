-- Fatture soggette a reclamo ( Verticale: AZAPI_DATDOC + AZAPI_PARTIT, fatture FI con
-- partita aperta ), copiate dalla sincronizzazione Verticale. Alimentano le tendine
-- del tab "Reclamo" della testata preventivo ( quotations.reclamo_anno / numero / alfa ).
CREATE TABLE public.verticale_claim_invoices (
    anno VARCHAR(4) NOT NULL,
    numero INTEGER NOT NULL,
    alfa VARCHAR(2) NOT NULL DEFAULT '',
    PRIMARY KEY ( anno, numero, alfa )
);
