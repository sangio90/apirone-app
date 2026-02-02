CREATE TABLE public.quotation_zone_positions (
    quotation_zone_position_id SERIAL,
    quotation_zone_id UUID STORAGE PLAIN NOT NULL,
    quotation_zone_position VARCHAR(100),
    created_at TIMESTAMP WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now(),
    CONSTRAINT quotation_zone_positions_pkey PRIMARY KEY (quotation_zone_position_id),
    CONSTRAINT quotation_zone_positions_quotaion_zone_id_fk FOREIGN KEY (quotation_zone_id) REFERENCES public.quotation_zones (quotation_zone_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_zone_positions OWNER TO apiruser;