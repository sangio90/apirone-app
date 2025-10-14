ALTER TABLE public.files
	ADD COLUMN deleted_at timestamp NULL;

WITH duplicates AS (
    SELECT
        file_id,
        ROW_NUMBER() OVER (
            PARTITION BY
                type_id,
                COALESCE(product_id, '00000000-0000-0000-0000-000000000000'),
                COALESCE(combination_id, '00000000-0000-0000-0000-000000000000'),
                COALESCE(quotation_item_id, '00000000-0000-0000-0000-000000000000'),
                COALESCE(product_item_id, -1),
                COALESCE(combination_item_id, -1),
                COALESCE(attribute_raw_value_id, -1)
            ORDER BY created_at DESC
        ) AS rn
    FROM files
    WHERE deleted_at IS NULL
)
UPDATE files f
SET deleted_at = CURRENT_TIMESTAMP(0)
	FROM duplicates d
WHERE f.file_id = d.file_id
  AND d.rn > 1;