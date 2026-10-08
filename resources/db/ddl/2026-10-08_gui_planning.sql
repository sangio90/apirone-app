-- Pianificazione ( Gantt ): persone con tipo di lavoro e ore disponibili per
-- giorno della settimana, ore di attività stimate per preventivo, blocchi di
-- lavoro pianificati giorno per giorno, chiusure aziendali.
-- Tipi di lavoro / attività ( config/data/workTypes.json.cfm ):
-- COM commerciale, DIS disegno, PRD produzione, MON montaggio, AMM amministrazione, ALT altro.

-- Persone: tipo di lavoro ( indipendente dal ruolo di accesso; NULL = non si
-- pianifica ) e ore disponibili da lunedì a domenica
ALTER TABLE membership.users ADD COLUMN work_type_id VARCHAR(3) NULL;
ALTER TABLE membership.users ADD COLUMN hours_mon NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_tue NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_wed NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_thu NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_fri NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_sat NUMERIC(4,2) NOT NULL DEFAULT 0;
ALTER TABLE membership.users ADD COLUMN hours_sun NUMERIC(4,2) NOT NULL DEFAULT 0;
-- ora di inizio della giornata: le ore del giorno partono da qui, senza pausa
ALTER TABLE membership.users ADD COLUMN day_start TIME NOT NULL DEFAULT '08:00';

-- Ore di attività stimate per preventivo, una riga per tipo
CREATE TABLE quotation_work_hours (
	quotation_id UUID NOT NULL REFERENCES quotations ( quotation_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	work_type_id VARCHAR(3) NOT NULL,
	hours NUMERIC(7,2) NOT NULL DEFAULT 0,
	updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
	PRIMARY KEY ( quotation_id, work_type_id )
);

-- Stato del progetto nel Gantt: concluso, non compare più tra quelli da pianificare
CREATE TABLE planning_quotations (
	quotation_id UUID PRIMARY KEY REFERENCES quotations ( quotation_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	completed_at TIMESTAMP NULL,
	completed_by UUID NULL
);

-- Blocco di lavoro: una persona su un'attività di un preventivo
CREATE TABLE planning_blocks (
	block_id SERIAL PRIMARY KEY,
	quotation_id UUID NOT NULL REFERENCES quotations ( quotation_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	user_id UUID NOT NULL REFERENCES membership.users ( user_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	work_type_id VARCHAR(3) NOT NULL,
	-- giorni non lavorativi usabili dal blocco: sabati / domeniche e festivi
	use_saturday BOOLEAN NOT NULL DEFAULT FALSE,
	force_holidays BOOLEAN NOT NULL DEFAULT FALSE,
	-- giorno di inizio scelto ( rilascio / spostamento ): anche non lavorativo,
	-- da qui ripartono le ore quando si attivano sabati o festivi
	start_day DATE NULL,
	-- descrizione facoltativa ( es. per le attività "Altro" )
	note TEXT NULL,
	-- ore extra: oltre la stima del progetto ( costo in più ), non la consumano
	extra BOOLEAN NOT NULL DEFAULT FALSE,
	created_at TIMESTAMP NOT NULL DEFAULT NOW(),
	created_by UUID NULL
);
CREATE INDEX planning_blocks_quotation_idx ON planning_blocks ( quotation_id );
CREATE INDEX planning_blocks_user_idx ON planning_blocks ( user_id );

-- Ore del blocco giorno per giorno ( forzabili a mano oltre o sotto la disponibilità )
CREATE TABLE planning_block_days (
	block_id INTEGER NOT NULL REFERENCES planning_blocks ( block_id ) ON UPDATE CASCADE ON DELETE CASCADE,
	day DATE NOT NULL,
	hours NUMERIC(5,2) NOT NULL,
	-- ora di inizio nel giorno ( a passi di 30 minuti ); NULL = inizio giornata della persona
	start_time TIME NULL,
	PRIMARY KEY ( block_id, day )
);
CREATE INDEX planning_block_days_day_idx ON planning_block_days ( day );

-- Chiusure aziendali, in aggiunta ai festivi di San Marino ( WorkCalendarService )
CREATE TABLE planning_closures (
	closure_id SERIAL PRIMARY KEY,
	day DATE NOT NULL UNIQUE,
	description VARCHAR(255) NULL,
	created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
