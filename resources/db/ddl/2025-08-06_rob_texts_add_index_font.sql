CREATE UNIQUE INDEX texts_idx7 ON texts ("lang_id", "font_id");

-- ATTENTION
-- This delete orphaned data from texts table
DELETE FROM texts
WHERE
    line_id NOT IN (
        SELECT
            line_id
        FROM
            lines
    );

ALTER INDEX public.component_variations_idx
RENAME TO component_override_idx;

ALTER INDEX public.components_variations_pkey
RENAME TO components_override_pkey;