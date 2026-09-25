-- File del font (woff2/woff/ttf/otf) caricato per ciascuna font family.
--
-- L'anteprima della segnaletica lo carica nel browser (FontFace API) invece di dipendere
-- dai font installati sul computer dell'utente o dalle regole statiche di fonts.css.
-- File di kind "fontFamily" (Configuration.imagesConfig), salvati sotto media/font-families.
-- Una font family ha al massimo un file attivo: caricandone uno nuovo il precedente viene
-- soft-eliminato (deleted_at), vedi FontFamilyAjaxController.save().

ALTER TABLE public.files
    ADD COLUMN IF NOT EXISTS font_family_id INTEGER;

DO $$
BEGIN
    IF NOT EXISTS ( SELECT 1 FROM pg_constraint WHERE conname = 'files_font_family_id_fk' ) THEN
        ALTER TABLE public.files
            ADD CONSTRAINT files_font_family_id_fk FOREIGN KEY ( font_family_id )
            REFERENCES public.font_families ( font_family_id ) ON UPDATE CASCADE ON DELETE CASCADE;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS files_font_family_id_idx ON public.files ( font_family_id );
