CREATE TABLE product_hashes (
    product_hash_id SERIAL,
    hash varchar(32) NOT NULL,
    json_data text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    PRIMARY KEY (product_hash_id)
);

ALTER TABLE product_hashes
    ADD CONSTRAINT product_hashes_hash_unique UNIQUE (hash);

ALTER TABLE product_hashes OWNER TO apiruser;

ALTER TABLE quotation_items
    ADD COLUMN hash varchar(32); 