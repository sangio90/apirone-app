-- **
-- use create-users-from-roles.cfm script
-- **
ALTER TABLE accounts
RENAME role_id TO role_id_to_remove;

ALTER TABLE accounts
RENAME lang_id TO lang_id_to_remove;

ALTER TABLE accounts
RENAME phone TO phone_to_remove;

ALTER TABLE accounts
RENAME api_key TO api_key_to_remove;

ALTER TABLE accounts
RENAME roles TO roles_to_remove;

-- 1. Aggiungi la nuova colonna user_id
ALTER TABLE audit_logs
ADD COLUMN user_id UUID;

CREATE TABLE public.users (
    user_id UUID STORAGE PLAIN DEFAULT uuid_generate_v4 () NOT NULL,
    account_id UUID STORAGE PLAIN NOT NULL,
    serial SERIAL,
    "user" VARCHAR(125) STORAGE PLAIN,
    status_id VARCHAR(3) STORAGE PLAIN DEFAULT 'DEA'::character varying NOT NULL,
    role_id VARCHAR(3) STORAGE PLAIN DEFAULT 'DEF'::character varying NOT NULL,
    lang_id VARCHAR(2) DEFAULT 'IT'::character varying NOT NULL,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE STORAGE PLAIN DEFAULT now() NOT NULL,
    phone VARCHAR(50),
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_serial_key UNIQUE (serial),
    CONSTRAINT users_account_id_fk FOREIGN KEY (account_id) REFERENCES public.accounts (account_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT users_lang_id_fk FOREIGN KEY (lang_id) REFERENCES public.langs (lang_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT users_status_id_fk FOREIGN KEY (status_id) REFERENCES public.statuses (status_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE
);

ALTER TABLE public.users OWNER TO apiruser;

ALTER TABLE public.users
ALTER COLUMN "user"
SET
    STORAGE PLAIN;

ALTER TABLE public.users
ALTER COLUMN status_id
SET
    STORAGE PLAIN;

ALTER TABLE public.users
ALTER COLUMN role_id
SET
    STORAGE PLAIN;

-- 2. Migra i dati esistenti (se i log hanno account_id e vuoi mantenere il riferimento)
-- Questo aggiorna user_id con il primo user di ogni account
UPDATE audit_logs
SET
    user_id = (
        SELECT
            user_id
        FROM
            users
        WHERE
            users.account_id = audit_logs.account_id
        LIMIT
            1
    );

-- 3. Aggiungi il foreign key constraint
ALTER TABLE audit_logs
ADD CONSTRAINT audit_logs_user_id_fk FOREIGN KEY (user_id) REFERENCES users (user_id);

-- 4. (Opzionale) Rimuovi la vecchia colonna account_id
ALTER TABLE audit_logs
RENAME account_id TO account_id_to_remove;

ALTER TABLE public.audit_logs
ALTER COLUMN account_id_to_remove
DROP NOT NULL;

UPDATE users
SET
    user_id = '91ba7bf0-3fa6-4473-9fa2-380bfcc900c4'
WHERE
    "user" = 'Service account';