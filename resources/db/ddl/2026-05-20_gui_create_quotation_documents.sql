CREATE TABLE quotation_documents (
    quotation_document_id UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    quotation_id          UUID        NOT NULL REFERENCES quotations(quotation_id) ON DELETE CASCADE,
    original_name         VARCHAR(500) NOT NULL,
    stored_name           VARCHAR(500) NOT NULL,
    directory             VARCHAR(20)  NOT NULL,
    sort_order            INTEGER      NOT NULL DEFAULT 0,
    created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX ON quotation_documents(quotation_id);
