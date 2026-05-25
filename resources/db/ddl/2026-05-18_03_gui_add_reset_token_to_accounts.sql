ALTER TABLE membership.accounts
    ADD COLUMN reset_token            VARCHAR(255),
    ADD COLUMN reset_token_expires_at TIMESTAMP;

CREATE UNIQUE INDEX accounts_reset_token_idx ON membership.accounts (reset_token)
    WHERE reset_token IS NOT NULL;
