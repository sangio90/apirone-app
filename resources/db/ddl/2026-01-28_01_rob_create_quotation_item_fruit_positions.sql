CREATE TABLE public.quotation_item_fruit_positions (
    quotation_item_fruit_position_id SERIAL,
    "position" VARCHAR(50) NOT NULL,
    quotation_item_fruit_id INTEGER STORAGE PLAIN,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
    CONSTRAINT quotation_item_fruit_cells_idx UNIQUE (quotation_item_fruit_id, "position"),
    CONSTRAINT quotation_item_fruit_cells_pkey PRIMARY KEY (quotation_item_fruit_position_id),
    CONSTRAINT quotation_item_fruit_cells_fk FOREIGN KEY (quotation_item_fruit_id) REFERENCES public.quotation_item_fruits (quotation_item_fruit_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.quotation_item_fruit_positions OWNER TO apiruser;