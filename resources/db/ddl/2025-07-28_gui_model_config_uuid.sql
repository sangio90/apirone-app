ALTER TABLE sizes_configs
RENAME TO "size_configs";

ALTER TABLE size_configs
ALTER COLUMN size_config_id
SET DEFAULT uuid_generate_v4 ();