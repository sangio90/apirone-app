-- Il campo "Posizione" (quotation_zone_positions.code, varchar 15) puo' andare in
-- overflow quando si duplica un articolo con "Copia": QuotationItemService.clone()
-- accoda "-BIS" al codice originale. Il codice non viene mai inviato al gestionale
-- Verticale, quindi possiamo allargare la colonna senza vincoli esterni. Lato client
-- l'input resta limitato a 15 caratteri (vedi plate-modal.cfm, plate-modal-vue.cfm,
-- item-pricing.cfm), cosi' restano sempre almeno 5 caratteri di margine per il suffisso.
ALTER TABLE public.quotation_zone_positions
ALTER COLUMN code TYPE character varying(20);
