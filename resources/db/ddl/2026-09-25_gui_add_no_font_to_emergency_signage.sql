-- Segnaletica emergenza: font fittizio "Nessun font" con altezza "0".
--
-- Alcuni preventivi hanno segnaletica di emergenza stampata senza testo (solo
-- disegni), ma la modale segnaletica impone la scelta di un font e di un'altezza.
-- Qui si crea:
--   - la famiglia font  "Nessun font" (codice NOFNT) con un'unica altezza 0,
--     pittogrammi disabilitati;
--   - il font           "Nessun font" (codice NOFNT), con il nome nelle 5 lingue;
--   - per ogni catalog bundle (linea-modello) della categoria SEGNALETICA EMERGENZA
--     (codice SE) una signage_config con questo font e un solo item di altezza 0,
--     0 righe e 0 caratteri: nella modale non si possono inserire righe di testo.
-- La finitura non fa parte del catalog bundle: la config vale per tutte le finiture.
--
-- Idempotente: ogni INSERT salta le righe già presenti, si può rieseguire (es. dopo
-- aver aggiunto nuovi modelli di emergenza).

-- Anteprima (opzionale): bundle di emergenza e config già presenti
-- SELECT cb.catalog_bundle_id, cb.line_id, cb.model_id, COUNT( sc.signage_config_id ) AS configs
-- FROM catalog_bundles cb
--     INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
--     LEFT JOIN signage_configs sc ON sc.catalog_bundle_id = cb.catalog_bundle_id
-- WHERE pc.code = 'SE'
-- GROUP BY cb.catalog_bundle_id, cb.line_id, cb.model_id;

BEGIN;

-- 1. Famiglia font
INSERT INTO font_families ( code, font_family )
SELECT 'NOFNT', 'Nessun font'
WHERE NOT EXISTS ( SELECT 1 FROM font_families WHERE code = 'NOFNT' );

-- 2. Altezza "0" della famiglia (senza pittogrammi)
INSERT INTO font_family_sizes ( font_family_size, font_family_id, enabled_pictograms )
SELECT 0, ff.font_family_id, FALSE
FROM font_families ff
WHERE ff.code = 'NOFNT'
    AND NOT EXISTS (
        SELECT 1 FROM font_family_sizes ffs
        WHERE ffs.font_family_id = ff.font_family_id AND ffs.font_family_size = 0
    );

-- 3. Font (height_width_ratio è NOT NULL: valore neutro 1)
INSERT INTO fonts ( code, directory, height_width_ratio, family, font_family_id )
SELECT 'NOFNT', NULL, 1, 'Nessun font', ff.font_family_id
FROM font_families ff
WHERE ff.code = 'NOFNT'
    AND NOT EXISTS ( SELECT 1 FROM fonts WHERE code = 'NOFNT' );

-- 4. Nome del font nelle 5 lingue (è il testo mostrato nella tendina "Font")
INSERT INTO texts ( text, lang_id, status_id, font_id, text_kind_id )
SELECT l.name, l.lang_id, 'TRA', f.font_id, 'NAME'
FROM fonts f
    CROSS JOIN ( VALUES
        ( 'IT', 'Nessun font' ),
        ( 'EN', 'No font' ),
        ( 'FR', 'Aucune police' ),
        ( 'ES', 'Sin fuente' ),
        ( 'DE', 'Keine Schriftart' )
    ) AS l ( lang_id, name )
WHERE f.code = 'NOFNT'
    AND NOT EXISTS (
        SELECT 1 FROM texts t
        WHERE t.font_id = f.font_id AND t.lang_id = l.lang_id AND t.text_kind_id = 'NAME'
    );

-- 5. Una signage_config "Nessun font" per ogni linea-modello della segnaletica emergenza
--    (vincolo UNIQUE su catalog_bundle_id + font_id)
INSERT INTO signage_configs ( catalog_bundle_id, font_id )
SELECT cb.catalog_bundle_id, f.font_id
FROM catalog_bundles cb
    INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
    CROSS JOIN fonts f
WHERE pc.code = 'SE'
    AND f.code = 'NOFNT'
ON CONFLICT ( catalog_bundle_id, font_id ) DO NOTHING;

-- 6. Item di altezza 0 per ciascuna di queste config: 0 righe, 0 caratteri
INSERT INTO signage_config_items (
    signage_config_id, height, height_in_pixel, row_count, char_count, font_family_size_id, line_heights
)
SELECT sc.signage_config_id, 0, 0, 0, 0, ffs.font_family_size_id, '[]'::jsonb
FROM signage_configs sc
    INNER JOIN fonts f ON f.font_id = sc.font_id AND f.code = 'NOFNT'
    INNER JOIN font_family_sizes ffs ON ffs.font_family_id = f.font_family_id AND ffs.font_family_size = 0
WHERE NOT EXISTS (
    SELECT 1 FROM signage_config_items sci
    WHERE sci.signage_config_id = sc.signage_config_id
        AND sci.font_family_size_id = ffs.font_family_size_id
);

COMMIT;

-- Verifica: deve restituire una riga per ogni bundle di emergenza
-- SELECT cb.catalog_bundle_id, sc.signage_config_id, sci.signage_config_item_id
-- FROM catalog_bundles cb
--     INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
--     INNER JOIN signage_configs sc ON sc.catalog_bundle_id = cb.catalog_bundle_id
--     INNER JOIN fonts f ON f.font_id = sc.font_id AND f.code = 'NOFNT'
--     INNER JOIN signage_config_items sci ON sci.signage_config_id = sc.signage_config_id
-- WHERE pc.code = 'SE';
