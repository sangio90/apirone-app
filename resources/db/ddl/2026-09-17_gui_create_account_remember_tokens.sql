-- "Ricordami" al login: token persistenti per account, sopravvivono a un riavvio del
-- server (le sessioni Lucee sono in memoria e vengono perse ad ogni riavvio di CommandBox).
-- Un account puo' avere piu' token attivi contemporaneamente (uno per browser/dispositivo):
-- il logout su un dispositivo non deve invalidare gli altri.
-- Il valore salvato e' l'hash SHA-512 del token, mai il token in chiaro (stesso schema
-- gia' usato per accounts.reset_token).
CREATE TABLE public.account_remember_tokens (
    account_remember_token_id UUID PRIMARY KEY DEFAULT uuid_generate_v4 (),
    account_id UUID NOT NULL,
    token VARCHAR(200) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
    expires_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    CONSTRAINT fk_account_remember_tokens_account_id
        FOREIGN KEY (account_id)
            REFERENCES membership.accounts (account_id)
            ON DELETE CASCADE,
    CONSTRAINT uq_account_remember_tokens_token
        UNIQUE (token)
);

CREATE INDEX idx_account_remember_tokens_account_id ON public.account_remember_tokens (account_id);
