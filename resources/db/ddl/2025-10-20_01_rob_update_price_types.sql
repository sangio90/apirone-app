UPDATE price_types
SET
    price_type = 'Markup attributo generale'
WHERE
    price_type_id = 'PROD_ITEM_GEN';

UPDATE price_types
SET
    price_type = 'Markup attributo'
WHERE
    price_type_id = 'PROD_ITEM_PRICE';