-- Eliminazione delle linee di prova e di tutti i dati di catalogo collegati:
--   N1    LINEA DI PROVA  8ca32202-a41a-4df9-b1e8-7e629a386596
--   PROVA LINEA PROVA     e988d03a-89ea-4b1d-b1a2-f5900dc478d0
--   TEST0 LINEA DI TEST   6904ebdd-7e25-4a19-8ce4-291a0d8829d7
--
-- Analisi fatta sul DB locale il 2026-09-28 (scansione del testo di ogni riga di ogni
-- tabella di tutti gli schemi + grafo delle FK):
--   catalog_bundles 25 (tutti categoria PL), products 266, product_items 671,
--   components 138, model_configs 2, texts (linea) 15, files 3, combinations 2
--   (+ 2 combination_product_items), utils.search_terms 266.
--   Nessun preventivo usa queste linee (quotation_items, quotation_item_fruits,
--   quotation_item_prices, quotation_item_product_items: 0 righe).
--   I modelli usati (17) sono condivisi con altre linee: non vanno eliminati.
--   Nessun prodotto di altre linee le cita nel jsonb products.lines.
--
-- Il guard iniziale blocca la migration se nel frattempo un preventivo ha iniziato a
-- usare questi prodotti (su DB diversi da quello analizzato ricontrollare i conteggi).
--
-- NB: i 3 record di files puntano a immagini su disco che vanno rimosse a mano
-- (directory 2025/08): aaa_placca_4_quadrata_d2815.jpg, aaa_placca_3_rosso_4a2e0.jpg,
-- aaa_placca_3_rosso_41be2.jpg

BEGIN;

CREATE TEMP TABLE del_lines ON COMMIT DROP AS
SELECT line_id FROM lines WHERE code IN ( 'N1', 'PROVA', 'TEST0' );

CREATE TEMP TABLE del_bundles ON COMMIT DROP AS
SELECT catalog_bundle_id FROM catalog_bundles WHERE line_id IN ( SELECT line_id FROM del_lines );

-- products.line_id è legacy (NULL per i prodotti recenti): si considera anche il bundle
CREATE TEMP TABLE del_products ON COMMIT DROP AS
SELECT product_id FROM products
WHERE line_id IN ( SELECT line_id FROM del_lines )
    OR catalog_bundle_id IN ( SELECT catalog_bundle_id FROM del_bundles );

CREATE TEMP TABLE del_product_items ON COMMIT DROP AS
SELECT product_item_id FROM product_items WHERE product_id IN ( SELECT product_id FROM del_products );

CREATE TEMP TABLE del_signage_config_items ON COMMIT DROP AS
SELECT sci.signage_config_item_id
FROM signage_config_items sci
    JOIN signage_configs sc USING ( signage_config_id )
WHERE sc.catalog_bundle_id IN ( SELECT catalog_bundle_id FROM del_bundles );

CREATE TEMP TABLE del_components ON COMMIT DROP AS
SELECT component_id FROM components
WHERE line_id IN ( SELECT line_id FROM del_lines )
    OR catalog_bundle_id IN ( SELECT catalog_bundle_id FROM del_bundles )
    OR product_id IN ( SELECT product_id FROM del_products )
    OR product_item_id IN ( SELECT product_item_id FROM del_product_items )
    OR product_item_join_id IN ( SELECT product_item_id FROM del_product_items )
    OR signage_config_item_id IN ( SELECT signage_config_item_id FROM del_signage_config_items )
    OR signage_config_item_join_id IN ( SELECT signage_config_item_id FROM del_signage_config_items );

-- Guard: nessun dato di preventivo deve riferire i prodotti da eliminare
DO $$
DECLARE n INTEGER;
BEGIN
    SELECT
        ( SELECT count(*) FROM quotation_items
            WHERE product_id IN ( SELECT product_id FROM del_products )
                OR product_origin_id IN ( SELECT product_id FROM del_products )
                OR signage_config_item_id IN ( SELECT signage_config_item_id FROM del_signage_config_items ) )
      + ( SELECT count(*) FROM quotation_item_fruits WHERE fruit_id IN ( SELECT product_id FROM del_products ) )
      + ( SELECT count(*) FROM quotation_item_prices WHERE product_id IN ( SELECT product_id FROM del_products ) )
      + ( SELECT count(*) FROM quotation_item_product_items
            WHERE product_item_id IN ( SELECT product_item_id FROM del_product_items )
                OR origin_id IN ( SELECT product_item_id FROM del_product_items ) )
    INTO n;

    IF n > 0 THEN
        RAISE EXCEPTION 'Ci sono % righe di preventivo che usano prodotti delle linee da eliminare: migration annullata', n;
    END IF;
END $$;

-- combinazioni dei prodotti (cascade su combination_product_items e files.combination_id)
DELETE FROM combinations WHERE product_id IN ( SELECT product_id FROM del_products );

-- files.product_id non ha ON DELETE CASCADE
DELETE FROM files
WHERE product_id IN ( SELECT product_id FROM del_products )
    OR product_item_id IN ( SELECT product_item_id FROM del_product_items );

-- component_overrides.component_id non ha ON DELETE CASCADE
DELETE FROM component_overrides WHERE component_id IN ( SELECT component_id FROM del_components );
DELETE FROM components WHERE component_id IN ( SELECT component_id FROM del_components );

-- cascade: product_items (+ prices, files, component_overrides), prices, texts,
-- product_engraving_markers, quotation_item_price_lines, utils.search_terms
DELETE FROM products WHERE product_id IN ( SELECT product_id FROM del_products );

-- cascade: signage_config_items
DELETE FROM signage_configs WHERE catalog_bundle_id IN ( SELECT catalog_bundle_id FROM del_bundles );

DELETE FROM catalog_bundles WHERE catalog_bundle_id IN ( SELECT catalog_bundle_id FROM del_bundles );

DELETE FROM model_configs WHERE line_id IN ( SELECT line_id FROM del_lines );

-- cascade: texts, line_costs, line_model_costs, product_category_lines
DELETE FROM lines WHERE line_id IN ( SELECT line_id FROM del_lines );

COMMIT;
