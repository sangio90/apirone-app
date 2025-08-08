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

-- object recreation
ALTER TABLE public.texts
DROP CONSTRAINT texts_line_id_fk RESTRICT;

ALTER TABLE public.texts
ADD CONSTRAINT texts_line_id_fk FOREIGN KEY (line_id) REFERENCES public.lines (line_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;