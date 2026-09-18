-- components.catalog_bundle_id non aveva indice: ogni DELETE su catalog_bundles deve
-- verificare l'assenza di componenti collegati (FK components_catalog_bundle_id_fk) e,
-- con la nuova pulizia dei catalog_bundles orfani in ProductService, questo controllo
-- ora gira ad ogni cancellazione di prodotto invece che raramente.
CREATE INDEX IF NOT EXISTS components_catalog_bundle_id_idx ON components (catalog_bundle_id);
