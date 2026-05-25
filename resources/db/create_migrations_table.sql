CREATE TABLE IF NOT EXISTS public.migrations (
    id                 SERIAL PRIMARY KEY,
    name               VARCHAR(255) NOT NULL UNIQUE,
    migration_datetime TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
