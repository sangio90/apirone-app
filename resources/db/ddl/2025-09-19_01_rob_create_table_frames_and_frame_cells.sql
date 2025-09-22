CREATE TABLE public.frames (
  frame_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4() NOT NULL,
  frame VARCHAR(200) STORAGE PLAIN,
  orientation_id VARCHAR(3) STORAGE PLAIN,
  cell_orientation_id VARCHAR(3) STORAGE PLAIN,
  code VARCHAR(5) STORAGE PLAIN NOT NULL UNIQUE,
  PRIMARY KEY(frame_id)
) ;

COMMENT ON COLUMN public.frames.orientation_id
IS 'VER = vertical, HOR = horizontal';

COMMENT ON COLUMN public.frames.cell_orientation_id
IS 'VER = vertical, HOR = horizontal';

CREATE TABLE frame_cells (
    frame_cell_id SERIAL PRIMARY KEY,
    frame_id UUID NOT NULL,
    row INTEGER NOT NULL,
    col INTEGER NOT NULL,
    value CHAR(1) CHECK (value IN ('0', '_')),
    CONSTRAINT frames_fk FOREIGN KEY (frame_id) REFERENCES frames(frame_id)
);

ALTER TABLE public.frames
  ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;
  
ALTER TABLE public.frame_cells
  ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now() NOT NULL;  

ALTER TABLE public.frames OWNER TO apirone;
ALTER TABLE public.frame_cells OWNER TO apirone;


ALTER TABLE public.frame_cells
  ADD CONSTRAINT frame_cells_unique_idx 
    UNIQUE (frame_id, "row", col) NOT DEFERRABLE;

ALTER TABLE public.frames
  ADD COLUMN status_id VARCHAR(3) NOT NULL;    

ALTER TABLE public.frames
  ADD CONSTRAINT frames_status_id_fk FOREIGN KEY (status_id)
    REFERENCES public.statuses(status_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;

UPDATE statuses 
SET entities = '["LINE", "ATTRIBUTE", "FINISH", "MODEL", "ACCOUNT", "PRODUCTION_TIME", "PRODUCT_CATEGORY", "PRODUCT", "RAW_VALUE", "METADATA_TYPE", "FRAME"]'
WHERE status_id in ('ACT', 'DEA');    


-- object recreation
ALTER TABLE public.frame_cells
  DROP CONSTRAINT frames_fk RESTRICT;

ALTER TABLE public.frame_cells
  ADD CONSTRAINT frames_fk FOREIGN KEY (frame_id)
    REFERENCES public.frames(frame_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;