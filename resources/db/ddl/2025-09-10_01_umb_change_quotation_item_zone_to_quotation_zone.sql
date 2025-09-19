DROP TABLE IF EXISTS quotation_item_zones;

CREATE TABLE quotation_zones (
    quotation_zone_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    quotation_zone varchar(255) NOT NULL,
    quotation_id uuid NOT NULL,
    origin_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    PRIMARY KEY (quotation_zone_id),
    CONSTRAINT fk_quotation_zone_parent 
        FOREIGN KEY (origin_id) REFERENCES quotation_zones(quotation_zone_id),
    CONSTRAINT fk_quotation_zone_quotation 
        FOREIGN KEY (quotation_id) REFERENCES quotations(quotation_id)
);

DROP TABLE IF EXISTS quotation_item_positions;

CREATE TABLE quotation_item_positions (
    quotation_item_position_id uuid NOT NULL DEFAULT uuid_generate_v4(),
    quotation_item_id uuid NOT NULL,
    quotation_zone_id uuid NOT NULL,
    position_coordinate_x varchar(255) NOT NULL,
    position_coordinate_y varchar(255) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    PRIMARY KEY (quotation_item_position_id),
    CONSTRAINT fk_quotation_item_position_quotation_item 
        FOREIGN KEY (quotation_item_id) REFERENCES quotation_items(quotation_item_id),
    CONSTRAINT fk_quotation_item_position_zone 
        FOREIGN key(quotation_zone_id) REFERENCES quotation_zones(quotation_zone_id)
);

-- 6. Aggiungere colonna in quotation_items che punta a quotation_zones
ALTER TABLE quotation_items
    ADD COLUMN quotation_zone_id uuid NULL;

ALTER TABLE quotation_items
    ADD CONSTRAINT fk_quotation_items_quotation_zone
    FOREIGN KEY (quotation_zone_id) REFERENCES quotation_zones(quotation_zone_id);

ALTER TABLE quotation_zones OWNER TO apiruser;