-- Costi fissi per coppia linea/modello (qualsiasi finitura).
-- Si sommano ai costi fissi linea/finitura (line_costs): nel preventivo ogni costo viene
-- ripartito sulla quantità totale delle righe del suo gruppo (stessa linea+modello qui,
-- stessa linea+finitura per line_costs). Vale solo per prodotti di tipo PLA/SEG.
-- Linea e modello del prodotto si leggono da catalog_bundles (products.catalog_bundle_id):
-- le colonne products.line_id/model_id sono legacy e NULL per i prodotti creati dopo
-- l'introduzione dei catalog_bundles.
-- product_category_id serve solo per filtrare nella UI: oggi una coppia linea+modello
-- appartiene a una sola categoria (vincolo di fatto dei catalog_bundles).
CREATE TABLE public.line_model_costs (
    line_model_cost_id SERIAL NOT NULL,
    line_id UUID NOT NULL,
    model_id UUID NOT NULL,
    product_category_id INTEGER NOT NULL,
    cost NUMERIC(10, 5) NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    CONSTRAINT line_model_costs_pkey PRIMARY KEY (line_model_cost_id),
    CONSTRAINT line_model_costs_line_id_fk FOREIGN KEY (line_id) REFERENCES public.lines (line_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT line_model_costs_model_id_fk FOREIGN KEY (model_id) REFERENCES public.models (model_id) ON DELETE CASCADE ON UPDATE CASCADE NOT DEFERRABLE,
    CONSTRAINT line_model_costs_product_category_id_fk FOREIGN KEY (product_category_id) REFERENCES public.product_categories (product_category_id) ON DELETE NO ACTION ON UPDATE CASCADE NOT DEFERRABLE
);

CREATE UNIQUE INDEX line_model_costs_line_model_idx ON public.line_model_costs USING btree (line_id, model_id);

ALTER TABLE public.line_model_costs OWNER TO apiruser;
