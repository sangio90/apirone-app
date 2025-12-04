CREATE TABLE quotation_status_history (
    quotation_status_history_id SERIAL,
    quotation_id UUID STORAGE PLAIN NOT NULL,
    account_id UUID NOT NULL,
    status_id VARCHAR(3) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    PRIMARY KEY (quotation_status_history_id),
    FOREIGN KEY (quotation_id) REFERENCES quotations (quotation_id),
    FOREIGN KEY (account_id) REFERENCES accounts (account_id),
    FOREIGN KEY (status_id) REFERENCES statuses (status_id)
);

ALTER TABLE files
ADD COLUMN quotation_status_history_id INTEGER;

ALTER TABLE files
ADD CONSTRAINT files_quotation_status_history_id_fk FOREIGN KEY (quotation_status_history_id) REFERENCES quotation_status_history (quotation_status_history_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE;

ALTER TABLE quotation_status_history OWNER TO apiruser;