alter table sizes_configs
	rename to "size_configs";

alter table size_configs
	alter column size_config_id set default uuid_generate_v4();