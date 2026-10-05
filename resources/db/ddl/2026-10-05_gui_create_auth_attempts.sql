-- Rate limit di login e recupero password (AuthService). Una riga per tentativo:
--   LOGIN   = login fallito (al login riuscito le righe dell'account vengono cancellate)
--   RECOVER = richiesta di recupero password (riuscita o no: il costo è la mail inviata)
-- identifier è l'hash SHA-256 dell'email normalizzata (lower/trim), non l'email in chiaro:
-- serve solo a contare, e vale anche per email non registrate.
-- Le righe servono solo per la finestra del limite: quelle più vecchie di un giorno vengono
-- cancellate ad ogni inserimento.
CREATE TABLE public.auth_attempts (
    auth_attempt_id BIGSERIAL PRIMARY KEY,
    kind VARCHAR(16) NOT NULL,
    identifier VARCHAR(64) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    CONSTRAINT auth_attempts_kind_chk CHECK (kind IN ('LOGIN', 'RECOVER'))
);

CREATE INDEX idx_auth_attempts_identifier ON public.auth_attempts (kind, identifier, created_at);
CREATE INDEX idx_auth_attempts_ip ON public.auth_attempts (kind, ip_address, created_at);
CREATE INDEX idx_auth_attempts_created_at ON public.auth_attempts (created_at);
