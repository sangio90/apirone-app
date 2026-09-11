-- Griglia incisioni dei frutti: posizioni ammesse per il simbolo inciso, per frutto e per
-- attributo "radice" dell'incisione (IS = incisione pulsante superiore, II = inferiore,
-- IL = incisione logo quando non sta sotto IS/II). Coordinate del centro del marker rispetto
-- all'angolo in alto a sinistra dell'immagine orizzontale del frutto, in px nativi
-- dell'immagine e in mm (modulo frutto 11,25 x 45 mm).
CREATE TABLE public.product_engraving_markers (
    product_engraving_marker_id SERIAL PRIMARY KEY,
    product_id   UUID NOT NULL,
    attribute_id UUID NOT NULL,
    "order"      INTEGER NOT NULL,
    x_px         NUMERIC(8,2) NOT NULL,
    y_px         NUMERIC(8,2) NOT NULL,
    x_mm         NUMERIC(7,2) NOT NULL,
    y_mm         NUMERIC(7,2) NOT NULL,
    created_at   TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CONSTRAINT product_engraving_markers_product_fk FOREIGN KEY (product_id)
        REFERENCES public.products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT product_engraving_markers_attribute_fk FOREIGN KEY (attribute_id)
        REFERENCES public.attributes(attribute_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT product_engraving_markers_unique_order UNIQUE (product_id, attribute_id, "order")
);

CREATE INDEX product_engraving_markers_product_idx ON public.product_engraving_markers (product_id);

-- Posizione scelta per il simbolo inciso in una riga di preventivo (sulla riga del valore
-- SIMBOLO). Il marker resta un riferimento, le coordinate sono uno snapshot al salvataggio:
-- se la griglia del frutto cambia dopo, il preventivo e le esportazioni non cambiano.
ALTER TABLE public.quotation_item_product_items
    ADD COLUMN engraving_marker_id INTEGER NULL,
    ADD COLUMN engraving_x_px NUMERIC(8,2) NULL,
    ADD COLUMN engraving_y_px NUMERIC(8,2) NULL,
    ADD COLUMN engraving_x_mm NUMERIC(7,2) NULL,
    ADD COLUMN engraving_y_mm NUMERIC(7,2) NULL,
    ADD CONSTRAINT quotation_item_product_items_engraving_marker_fk FOREIGN KEY (engraving_marker_id)
        REFERENCES public.product_engraving_markers(product_engraving_marker_id) ON DELETE SET NULL ON UPDATE CASCADE;
