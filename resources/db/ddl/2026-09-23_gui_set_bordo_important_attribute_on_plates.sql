-- Codice export placche: il codice variante (10 caratteri) è composto da
-- orientamento ("HO" + HOR/VER, calcolato in QuotationService.composeExportCode)
-- seguito dall'attributo "BORDO". Qui BORDO diventa l'UNICO attributo importante
-- di tutte le placche: eventuali altri attributi importanti già impostati sulle
-- placche vengono sostituiti.
--
-- L'attributo si riconosce dal nome italiano (texts NAME/IT = 'BORDO') ed è preso
-- fra quelli effettivamente presenti nei product_items di ciascun prodotto, così
-- funziona anche se esistessero più attributi chiamati BORDO (es. per linea).

-- Anteprima (da eseguire prima, opzionale): placche per stato di BORDO
-- SELECT p.product_id, p.attributes_important, bordo.ids
-- FROM products p
--     INNER JOIN catalog_bundles cb ON cb.catalog_bundle_id = p.catalog_bundle_id
--     INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
--     LEFT JOIN LATERAL (
--         SELECT jsonb_agg( DISTINCT arv.attribute_id::text ) AS ids
--         FROM product_items pi
--             INNER JOIN attributes_raw_values arv USING ( attribute_raw_value_id )
--             INNER JOIN texts t ON t.attribute_id = arv.attribute_id
--                 AND t.lang_id = 'IT' AND t.text_kind_id = 'NAME'
--         WHERE pi.product_id = p.product_id
--             AND UPPER( TRIM( t.text ) ) = 'BORDO'
--     ) bordo ON TRUE
-- WHERE pc.product_category_type_id = 'PLA';

BEGIN;

WITH plate_bordo AS (
    SELECT
        p.product_id,
        jsonb_agg( DISTINCT arv.attribute_id::text ) AS bordo_ids
    FROM products p
        INNER JOIN catalog_bundles cb ON cb.catalog_bundle_id = p.catalog_bundle_id
        INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
        INNER JOIN product_items pi ON pi.product_id = p.product_id
        INNER JOIN attributes_raw_values arv ON arv.attribute_raw_value_id = pi.attribute_raw_value_id
        INNER JOIN texts t ON t.attribute_id = arv.attribute_id
            AND t.lang_id = 'IT'
            AND t.text_kind_id = 'NAME'
    WHERE pc.product_category_type_id = 'PLA'
        AND UPPER( TRIM( t.text ) ) = 'BORDO'
    GROUP BY p.product_id
)
UPDATE products
SET attributes_important = plate_bordo.bordo_ids
FROM plate_bordo
WHERE products.product_id = plate_bordo.product_id;

-- Placche SENZA attributo BORDO (restano invariate): da verificare a mano
SELECT p.product_id, p.attributes_important
FROM products p
    INNER JOIN catalog_bundles cb ON cb.catalog_bundle_id = p.catalog_bundle_id
    INNER JOIN product_categories pc ON pc.product_category_id = cb.product_category_id
WHERE pc.product_category_type_id = 'PLA'
    AND NOT EXISTS (
        SELECT 1
        FROM product_items pi
            INNER JOIN attributes_raw_values arv ON arv.attribute_raw_value_id = pi.attribute_raw_value_id
            INNER JOIN texts t ON t.attribute_id = arv.attribute_id
                AND t.lang_id = 'IT'
                AND t.text_kind_id = 'NAME'
        WHERE pi.product_id = p.product_id
            AND UPPER( TRIM( t.text ) ) = 'BORDO'
    );

COMMIT;
