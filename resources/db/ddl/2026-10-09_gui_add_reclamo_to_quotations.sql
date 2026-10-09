-- Riferimento alla fattura del reclamo ( verticale: MMESEREC, MMDOCREC, MMALFREC )
ALTER TABLE quotations ADD COLUMN reclamo_anno VARCHAR(4) NULL;
ALTER TABLE quotations ADD COLUMN reclamo_numero INTEGER NULL;
ALTER TABLE quotations ADD COLUMN reclamo_alfa VARCHAR(2) NULL;
