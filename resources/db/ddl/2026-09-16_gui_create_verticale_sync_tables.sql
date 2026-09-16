-- Tabelle locali "specchio" dei dati oggi letti dal vivo dal gestionale Verticale
-- (datasource "verticale", SQL Server). Vengono svuotate e ripopolate per intero
-- a ogni sincronizzazione manuale (bottone "Sincronizza dati da Verticale").

CREATE TABLE public.verticale_sync_status (
    id SMALLINT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    running BOOLEAN NOT NULL DEFAULT FALSE,
    started_at TIMESTAMP(0) WITHOUT TIME ZONE,
    finished_at TIMESTAMP(0) WITHOUT TIME ZONE,
    started_by_user_id UUID REFERENCES membership.users (user_id),
    last_error TEXT
);

INSERT INTO public.verticale_sync_status (id, running) VALUES (1, FALSE);

-- azapi_listin: listino prezzi (lisart|liscvr|liscol -> lispre)
CREATE TABLE public.verticale_price_list (
    lisart VARCHAR(50),
    liscvr VARCHAR(50),
    liscol VARCHAR(50),
    lispre NUMERIC
);

CREATE INDEX verticale_price_list_lookup_idx
    ON public.verticale_price_list (lisart, liscvr, liscol);

-- azapi_artico: materie prime / articoli
-- (azapi_artico non ha una colonna "codtip": il filtro per tipo in RawProductDAO.find()
-- referenzia una colonna inesistente anche nella query originale su Verticale, quindi
-- non è mai stato realmente utilizzabile - non replicato qui)
CREATE TABLE public.verticale_raw_products (
    arcodart VARCHAR(50) PRIMARY KEY,
    ardesart VARCHAR(255),
    artipmat VARCHAR(50),
    arsemlav VARCHAR(10),
    arunmis1 VARCHAR(10),
    artipcol VARCHAR(10),
    arobsole VARCHAR(10)
);

-- azapi_codtip: tipi materia prima
CREATE TABLE public.verticale_raw_product_types (
    codtip VARCHAR(50) PRIMARY KEY,
    destip VARCHAR(255)
);

-- azapi_codvar: varianti
CREATE TABLE public.verticale_variants (
    varcod VARCHAR(50) PRIMARY KEY,
    vardes VARCHAR(255)
);

-- azapi_comvar: join articolo <-> variante
CREATE TABLE public.verticale_variant_products (
    cbcodart VARCHAR(50),
    cbcodvar VARCHAR(50)
);

CREATE INDEX verticale_variant_products_art_idx
    ON public.verticale_variant_products (cbcodart);

-- azapi_colori: colori
CREATE TABLE public.verticale_colors (
    clcodice VARCHAR(50) PRIMARY KEY,
    cldescri VARCHAR(255)
);

-- azapi_comcol: join articolo <-> colore
CREATE TABLE public.verticale_color_products (
    clcodart VARCHAR(50),
    clcodcol VARCHAR(50)
);

CREATE INDEX verticale_color_products_art_idx
    ON public.verticale_color_products (clcodart);

-- azapi_cvrcom: join articolo+variante <-> colore ("colore per variante")
CREATE TABLE public.verticale_color_variant_products (
    clcodart VARCHAR(50),
    clcodvar VARCHAR(50),
    clcodcol VARCHAR(50)
);

CREATE INDEX verticale_color_variant_products_art_var_idx
    ON public.verticale_color_variant_products (clcodart, clcodvar);

-- codval: valute
CREATE TABLE public.verticale_currencies (
    valcod VARCHAR(20) PRIMARY KEY,
    valdes VARCHAR(255),
    valsim VARCHAR(10)
);

-- codiva: aliquote IVA
CREATE TABLE public.verticale_vat_codes (
    ivacod VARCHAR(20) PRIMARY KEY,
    ivades VARCHAR(255),
    ivaper NUMERIC(5, 2)
);

-- codpag: metodi di pagamento
CREATE TABLE public.verticale_payment_methods (
    pagcod VARCHAR(20) PRIMARY KEY,
    pagdes VARCHAR(255)
);

-- codnaz: nazioni
-- (isonaz può essere NULL/duplicato su alcune righe reali di Verticale - es. voci
-- non-nazione come "CAL"/"CALIFORNIA" - quindi la chiave naturale pulita è codnaz)
CREATE TABLE public.verticale_countries (
    codnaz VARCHAR(20) PRIMARY KEY,
    isonaz VARCHAR(10),
    desnaz VARCHAR(255)
);

CREATE INDEX verticale_countries_isonaz_idx
    ON public.verticale_countries (isonaz);
