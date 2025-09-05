-- object recreation
ALTER TABLE public.component_overrides
  DROP CONSTRAINT component_variations_component_id_fk RESTRICT;

ALTER TABLE public.component_overrides
  ADD CONSTRAINT component_variations_component_id_fk FOREIGN KEY (component_id)
    REFERENCES public.components(component_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;