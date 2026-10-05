-- 1. Segnaletica esterna: font fittizio "Nessun font" con altezza "0".
--    Come 2026-09-25_gui_add_no_font_to_emergency_signage.sql per la segnaletica di
--    emergenza: per ogni catalog bundle (linea-modello) della categoria SEGNALETICA
--    ESTERNA (codice SO) una signage_config con il font NOFNT e un solo item di altezza
--    0, 0 righe e 0 caratteri. Font, famiglia e altezza 0 esistono già: li ha creati
--    quella migration, che va eseguita prima di questa.
--
-- 2. Rimozione della categoria RIGHE LETTERING (codice RL) e di tutto ciò che c'è sotto:
--    prodotti ( con product_items, prezzi, testi, termini di ricerca, in cascata ),
--    catalog bundle, signage config, componenti, costi linea, model config, testi della
--    categoria. Al 2026-10-05 sotto RL c'è un solo prodotto ("RIGA PER LETTERING", mai
--    usato in un preventivo) e il nome della categoria nelle 5 lingue.
--    Se qualcosa di RL risulta usato in un preventivo la migration si ferma: quei
--    preventivi vanno sistemati a mano prima.
--
-- Idempotente: si può rieseguire ( la parte 1 salta ciò che c'è già, la parte 2 non
-- trova più nulla da cancellare ).

-- Anteprima (opzionale)
-- SELECT pc.code, COUNT( DISTINCT cb.catalog_bundle_id ) AS bundles,
--        COUNT( DISTINCT sc.signage_config_id ) FILTER ( WHERE f.code = 'NOFNT' ) AS nofnt_configs
-- FROM catalog_bundles cb
--     INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
--     LEFT JOIN signage_configs sc ON sc.catalog_bundle_id = cb.catalog_bundle_id
--     LEFT JOIN fonts f ON f.font_id = sc.font_id
-- WHERE pc.code IN ( 'SO', 'SE' )
-- GROUP BY pc.code;

BEGIN;

-- Prerequisito: font NOFNT con altezza 0
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM fonts f
            INNER JOIN font_family_sizes ffs ON ffs.font_family_id = f.font_family_id AND ffs.font_family_size = 0
        WHERE f.code = 'NOFNT'
    ) THEN
        RAISE EXCEPTION 'Font NOFNT con altezza 0 mancante: eseguire prima 2026-09-25_gui_add_no_font_to_emergency_signage.sql';
    END IF;
END $$;


-- ============================================================================
-- 1. Segnaletica esterna ( SO ): config "Nessun font" con item di altezza 0
-- ============================================================================

-- Una signage_config "Nessun font" per ogni linea-modello della segnaletica esterna
-- (vincolo UNIQUE su catalog_bundle_id + font_id)
INSERT INTO signage_configs ( catalog_bundle_id, font_id )
SELECT cb.catalog_bundle_id, f.font_id
FROM catalog_bundles cb
    INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
    CROSS JOIN fonts f
WHERE pc.code = 'SO'
    AND f.code = 'NOFNT'
ON CONFLICT ( catalog_bundle_id, font_id ) DO NOTHING;

-- Item di altezza 0 per ciascuna di queste config: 0 righe, 0 caratteri
INSERT INTO signage_config_items (
    signage_config_id, height, height_in_pixel, row_count, char_count, font_family_size_id, line_heights
)
SELECT sc.signage_config_id, 0, 0, 0, 0, ffs.font_family_size_id, '[]'::jsonb
FROM signage_configs sc
    INNER JOIN catalog_bundles cb ON cb.catalog_bundle_id = sc.catalog_bundle_id
    INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id AND pc.code = 'SO'
    INNER JOIN fonts f ON f.font_id = sc.font_id AND f.code = 'NOFNT'
    INNER JOIN font_family_sizes ffs ON ffs.font_family_id = f.font_family_id AND ffs.font_family_size = 0
WHERE NOT EXISTS (
    SELECT 1 FROM signage_config_items sci
    WHERE sci.signage_config_id = sc.signage_config_id
        AND sci.font_family_size_id = ffs.font_family_size_id
);


-- ============================================================================
-- 2. Rimozione categoria RIGHE LETTERING ( RL )
-- ============================================================================

-- Insiemi di lavoro: bundle, prodotti ( per categoria o per bundle ), signage config item
CREATE TEMP TABLE rl_bundles ON COMMIT DROP AS
SELECT cb.catalog_bundle_id
FROM catalog_bundles cb
    INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
WHERE pc.code = 'RL';

CREATE TEMP TABLE rl_products ON COMMIT DROP AS
SELECT p.product_id
FROM products p
WHERE p.product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' )
    OR p.catalog_bundle_id IN ( SELECT catalog_bundle_id FROM rl_bundles );

CREATE TEMP TABLE rl_signage_config_items ON COMMIT DROP AS
SELECT sci.signage_config_item_id
FROM signage_config_items sci
    INNER JOIN signage_configs sc ON sc.signage_config_id = sci.signage_config_id
WHERE sc.catalog_bundle_id IN ( SELECT catalog_bundle_id FROM rl_bundles );

-- Nessun preventivo deve usare dati RL ( FK senza cascade: la cancellazione fallirebbe
-- comunque, così il messaggio dice perché )
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM quotation_items
        WHERE product_id IN ( SELECT product_id FROM rl_products )
            OR product_origin_id IN ( SELECT product_id FROM rl_products )
            OR signage_config_item_id IN ( SELECT signage_config_item_id FROM rl_signage_config_items )
    ) OR EXISTS (
        SELECT 1 FROM quotation_item_fruits WHERE fruit_id IN ( SELECT product_id FROM rl_products )
    ) OR EXISTS (
        SELECT 1 FROM quotation_item_prices WHERE product_id IN ( SELECT product_id FROM rl_products )
    ) OR EXISTS (
        SELECT 1 FROM quotation_item_product_items qipi
            INNER JOIN product_items pi ON pi.product_item_id IN ( qipi.product_item_id, qipi.origin_id )
        WHERE pi.product_id IN ( SELECT product_id FROM rl_products )
    ) THEN
        RAISE EXCEPTION 'Categoria RL usata in almeno un preventivo: rimuovere quelle righe prima di eseguire la migration';
    END IF;

    -- combinazioni: non previste per RL, e la loro rimozione tocca altre tabelle
    IF EXISTS ( SELECT 1 FROM combinations WHERE product_id IN ( SELECT product_id FROM rl_products ) ) THEN
        RAISE EXCEPTION 'Prodotti RL con combinazioni: rimuoverle a mano prima di eseguire la migration';
    END IF;
END $$;

-- Componenti legati a RL ( component_overrides non ha cascade sul componente )
CREATE TEMP TABLE rl_components ON COMMIT DROP AS
SELECT c.component_id
FROM components c
WHERE c.product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' )
    OR c.catalog_bundle_id IN ( SELECT catalog_bundle_id FROM rl_bundles )
    OR c.product_id IN ( SELECT product_id FROM rl_products );

DELETE FROM component_overrides WHERE component_id IN ( SELECT component_id FROM rl_components );
DELETE FROM components WHERE component_id IN ( SELECT component_id FROM rl_components );

-- Signage config dei bundle RL ( item in cascata )
DELETE FROM signage_configs WHERE catalog_bundle_id IN ( SELECT catalog_bundle_id FROM rl_bundles );

-- Immagini dei prodotti ( solo le righe: i file su disco restano )
DELETE FROM files WHERE product_id IN ( SELECT product_id FROM rl_products );

-- Prodotti: product_items, prezzi, testi, marker incisione, termini di ricerca in cascata
DELETE FROM products WHERE product_id IN ( SELECT product_id FROM rl_products );

DELETE FROM catalog_bundles WHERE catalog_bundle_id IN ( SELECT catalog_bundle_id FROM rl_bundles );

DELETE FROM model_configs    WHERE product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' );
DELETE FROM line_costs       WHERE product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' );
DELETE FROM line_model_costs WHERE product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' );

-- colonna legacy delle linee
UPDATE lines SET _product_category_id = NULL
WHERE _product_category_id = ( SELECT product_category_id FROM product_categories WHERE code = 'RL' );

-- Categoria: testi e product_category_lines in cascata
DELETE FROM product_categories WHERE code = 'RL';

COMMIT;

-- Verifica
-- 1. deve restituire una riga per ogni bundle della segnaletica esterna
-- SELECT cb.catalog_bundle_id, sc.signage_config_id, sci.signage_config_item_id
-- FROM catalog_bundles cb
--     INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
--     INNER JOIN signage_configs sc ON sc.catalog_bundle_id = cb.catalog_bundle_id
--     INNER JOIN fonts f ON f.font_id = sc.font_id AND f.code = 'NOFNT'
--     INNER JOIN signage_config_items sci ON sci.signage_config_id = sc.signage_config_id
-- WHERE pc.code = 'SO';
-- 2. non deve restituire nulla
-- SELECT * FROM product_categories WHERE code = 'RL';
