-- add service account
INSERT INTO
    public.accounts (
        "account_id",
        "status_id",
        "role_id",
        "lang_id",
        "account",
        "email",
        "phone",
        "serial",
        "pwd",
        "created_at",
        "api_key",
        "roles"
    )
VALUES
    (
        E'e702bf0b-d047-4ed7-bd64-5975efab123a',
        E'ACT',
        NULL,
        E'IT',
        E'Service account',
        E'\\xc30d040703021ecf8fc6e8c944106ed2500172c32fa457090f03b28a30bc4a98319f8255503fc06d1a3542ab71c611d6ef584be87e4f3c88f45ef2b0d0848939d9568708b6b2a4c637617cd91ce1877516905c548e07c181516c35dc8de64d92ca',
        NULL,
        0,
        E'926291934811EBE8948E6CD78B84DF4DBCFD7575B8F64E114ADAFEEAF59B5EAFFE81283AC7EB8A3C147F36D7A53166AE6C24DDED39E333BB90A5D66C6C41E564',
        E'2025-08-14 13:37:20',
        NULL,
        E'["ADM"]'
    );

-- text_kind moved to lookup
ALTER TABLE public.texts
DROP CONSTRAINT IF EXISTS texts_kind_id_fk RESTRICT;

DROP TABLE IF EXISTS public.text_kinds;

UPDATE texts
SET
    text_kind_id = 'NAME';

ALTER TABLE public.texts
ALTER COLUMN text_kind_id
SET NOT NULL;

ALTER TABLE public.texts
ALTER COLUMN text_kind_id
SET DEFAULT 'NAME';
