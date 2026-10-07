-- Errori non gestiti dell'applicazione (customErrorTemplate di ColdBox: apps/utils/errorReport.cfm).
-- All'utente si mostra solo una pagina generica con il codice dell'errore; i dettagli
-- finiscono qui e si consultano da /manager/error-logs (solo ADM).
--   code        = codice mostrato all'utente, per ritrovare la riga
--   report_html = report completo (dettagli, tag context, form, sessione, cookie)
-- user_id è senza chiave esterna di proposito: l'inserimento non deve mai fallire,
-- anche se l'utente nel frattempo è stato cancellato.
-- Le righe più vecchie di 180 giorni vengono cancellate ad ogni inserimento.
CREATE TABLE public.error_logs (
    error_log_id BIGSERIAL PRIMARY KEY,
    code VARCHAR(40) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    error_type VARCHAR(255),
    message TEXT,
    detail TEXT,
    template VARCHAR(500),
    line INTEGER,
    event VARCHAR(255),
    routed_url VARCHAR(1000),
    http_method VARCHAR(10),
    user_id UUID,
    user_name VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent VARCHAR(1000),
    report_html TEXT,
    CONSTRAINT error_logs_code_uq UNIQUE (code)
);

CREATE INDEX idx_error_logs_created_at ON public.error_logs (created_at DESC);
