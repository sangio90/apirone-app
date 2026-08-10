-- Cambio colore del componente "scatola cartone per placche" 504/507.
--
--   Articolo  MATIMBCARSCATOL  (SCATOLA CARTONE X PLACCHE)
--   Variante  SCA504/507       (CM 23 X 10,5 X H9,5)
--   Colore    _NOCOL (Nessun colore)  ->  BIALOG (BIANCO LOGO APIR)
--
-- Le righe interessate sono tutte componenti di distinta base a livello
-- LINEA + MODELLO (line_id + model_id valorizzati, product_id / product_item_id
-- NULL): 122 righe su 15 linee x 9 modelli, tutte con status ACT.
--
-- VERIFICHE FATTE SU VERTICALE (SQL Server, 2026-08-10):
--   azapi_colori   -> BIALOG = "BIANCO LOGO APIR"                        OK
--   azapi_artico   -> MATIMBCARSCATOL, artipcol = 'C' (colori a livello articolo)
--   azapi_comcol   -> MATIMBCARSCATOL / BIALOG                           OK
--   azapi_cvrcom   -> MATIMBCARSCATOL / SCA504/507 / BIALOG              OK
--   azapi_listin   -> SCA504/507 + BIALOG = 0,39   (SCA502/503 + BIALOG = 0,28)
--
-- Il costo non cambia: oggi la terna con _NOCOL non trova match esatto in
-- listino e CostService ricade su articolo+variante, che restituisce comunque
-- 0,39. Dopo l'update il match esatto dà lo stesso valore.
--
-- Nota: essendo ora BIALOG l'unico colore associato all'articolo su Verticale,
-- l'app non genera più il colore fittizio _NOCOL (RawProductService.cfc:112) e
-- _NOCOL non compare più nella tendina colori del componente. Le righe rimaste
-- a _NOCOL sono quindi valori orfani rispetto all'anagrafica.

-- Fotografia pre-update (per confronto / eventuale rollback puntuale)
SELECT component_id, line_id, model_id, raw_product_id, variant_id, color_id, quantity
FROM components
WHERE TRIM(raw_product_id) = 'MATIMBCARSCATOL'
  AND TRIM(variant_id)     = 'SCA504/507'
  AND TRIM(color_id)       = '_NOCOL'
ORDER BY component_id;

-- Update
UPDATE components
SET color_id = 'BIALOG'
WHERE TRIM(raw_product_id) = 'MATIMBCARSCATOL'
  AND TRIM(variant_id)     = 'SCA504/507'
  AND TRIM(color_id)       = '_NOCOL';

-- Verifica: attese 122 righe BIALOG e 0 righe _NOCOL per questa variante
SELECT raw_product_id, variant_id, color_id, COUNT(*) AS righe
FROM components
WHERE TRIM(raw_product_id) = 'MATIMBCARSCATOL'
GROUP BY raw_product_id, variant_id, color_id
ORDER BY variant_id, color_id;


-- ---------------------------------------------------------------------------
-- IN ATTESA DI CONFERMA — variante SCA502/503 (scatola piccola, 46 righe)
--
-- Non è nella richiesta, ma su Verticale BIALOG è associato all'ARTICOLO
-- (azapi_comcol, artipcol = 'C' => vale per tutte le varianti) ed esiste già il
-- prezzo di listino SCA502/503 + BIALOG = 0,28. Anche queste 46 righe sono
-- quindi rimaste con un _NOCOL che l'anagrafica non prevede più.
-- Da scommentare solo dopo conferma del cliente.
--
UPDATE components
SET color_id = 'BIALOG'
WHERE TRIM(raw_product_id) = 'MATIMBCARSCATOL'
  AND TRIM(variant_id)     = 'SCA502/503'
  AND TRIM(color_id)       = '_NOCOL';
-- ---------------------------------------------------------------------------


-- ROLLBACK (da lanciare a mano solo in caso di ripensamento):
-- UPDATE components
-- SET color_id = '_NOCOL'
-- WHERE TRIM(raw_product_id) = 'MATIMBCARSCATOL'
--   AND TRIM(variant_id)     = 'SCA504/507'
--   AND TRIM(color_id)       = 'BIALOG';
