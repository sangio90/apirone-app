-- Costi della pianificazione ( dopo 2026-10-08_gui_planning.sql ):
-- - costo orario delle persone con storico: vale dalla data valid_from fino
--   alla tariffa successiva; il costo di un giorno pianificato usa la tariffa
--   in vigore quel giorno;
-- - budget ( costo stimato in euro ) per attività di un progetto.

CREATE TABLE planning_person_costs (
	cost_id SERIAL PRIMARY KEY,
	user_id UUID NOT NULL REFERENCES membership.users ( user_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	valid_from DATE NOT NULL,
	hourly_cost NUMERIC(8,2) NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	created_by UUID NULL,
	CONSTRAINT planning_person_costs_user_from_uk UNIQUE ( user_id, valid_from )
);

-- NULL: nessun budget per quell'attività
ALTER TABLE quotation_work_hours ADD COLUMN budget NUMERIC(10,2) NULL;
