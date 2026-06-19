-- Placche personalizzate: blocchi di slot con margini in mm e orientamento per blocco.
-- Gli slot non hanno tabella propria: sono derivati da slot_count, numerati
-- progressivamente per placca (1..N) nell'ordine dei blocchi.

CREATE TABLE public.frame_blocks (
    frame_block_id   SERIAL PRIMARY KEY,
    frame_id         UUID NOT NULL,
    "order"          INTEGER NOT NULL,
    slot_count       INTEGER NOT NULL,
    margin_top_mm    NUMERIC(6,2) NOT NULL DEFAULT 0,
    margin_left_mm   NUMERIC(6,2) NOT NULL DEFAULT 0,
    orientation_mode VARCHAR(3) NOT NULL DEFAULT 'HAV',
    created_at       TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CONSTRAINT frame_blocks_frame_fk FOREIGN KEY (frame_id)
        REFERENCES public.frames(frame_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
        NOT DEFERRABLE,
    CONSTRAINT frame_blocks_unique_order UNIQUE (frame_id, "order")
);

COMMENT ON COLUMN public.frame_blocks.orientation_mode
IS 'HAV = ruota con la placca, HOR = fisso orizzontale, VER = fisso verticale';

COMMENT ON COLUMN public.frame_blocks.margin_top_mm
IS 'mm. Placca HOR: dal bordo top. Placca VER: dal blocco precedente (primo blocco: dal bordo top)';

COMMENT ON COLUMN public.frame_blocks.margin_left_mm
IS 'mm. Placca HOR: dal blocco precedente (primo blocco: dal bordo left). Placca VER: dal bordo left';
