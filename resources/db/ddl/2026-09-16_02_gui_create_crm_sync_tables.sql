-- Tabelle locali "specchio" dei dati oggi letti dal vivo dal CRM (SuiteCRM,
-- via CrmApiService/HTTP). Vengono svuotate e ripopolate per intero a ogni
-- sincronizzazione (bottone "Sincronizza" > CRM, o schedulazione).
-- A differenza di Verticale il CRM ha uno schema molto largo (decine di
-- campi custom per account/lead) e in evoluzione: il record intero viene
-- conservato in una colonna JSONB (così CrmMapper.mapCustomer/mapLead/
-- mapOpportunity continuano a funzionare invariati, deserializzando lo
-- stesso struct che prima arrivava dalla chiamata HTTP), con "id"/"name"/
-- "deleted" estratti in colonne per ricerca e lookup veloci.

CREATE TABLE public.crm_sync_status (
    id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    running BOOLEAN NOT NULL DEFAULT FALSE,
    started_at TIMESTAMP(0) WITHOUT TIME ZONE,
    finished_at TIMESTAMP(0) WITHOUT TIME ZONE,
    started_by_user_id UUID REFERENCES membership.users (user_id),
    last_error TEXT
);

INSERT INTO public.crm_sync_status (id, running) VALUES (1, FALSE);

CREATE TABLE public.crm_accounts (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255),
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    data JSONB NOT NULL
);

CREATE INDEX crm_accounts_name_trgm_idx ON public.crm_accounts USING GIN (name gin_trgm_ops);

CREATE TABLE public.crm_leads (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255),
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    data JSONB NOT NULL
);

CREATE INDEX crm_leads_name_trgm_idx ON public.crm_leads USING GIN (name gin_trgm_ops);

CREATE TABLE public.crm_opportunities (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(255),
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    data JSONB NOT NULL
);

CREATE INDEX crm_opportunities_name_trgm_idx ON public.crm_opportunities USING GIN (name gin_trgm_ops);
