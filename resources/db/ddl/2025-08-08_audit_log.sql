CREATE TABLE audit_logs (
    audit_log_id SERIAL PRIMARY KEY,
    account_id UUID NOT NULL,
    action VARCHAR(64) NOT NULL,
    message TEXT,
    payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NOT NULL,
    user_agent TEXT NOT NULL
);

ALTER TABLE public.audit_logs
ADD COLUMN severity VARCHAR(10) DEFAULT 'INFO';

ALTER TABLE public.audit_logs
ADD COLUMN entity VARCHAR(64);

ALTER SEQUENCE public.audit_logs_audit_log_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 2147483647 START 1 RESTART 100 CACHE 1 NO CYCLE OWNED BY public.audit_logs.audit_log_id;