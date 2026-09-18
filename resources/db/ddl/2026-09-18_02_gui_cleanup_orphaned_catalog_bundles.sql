-- Pulizia dei catalog_bundles orfani: righe rimaste dopo che tutti i prodotti che le
-- usavano sono stati cancellati (il codice non ripuliva mai catalog_bundles alla
-- cancellazione dell'ultimo prodotto di una combinazione linea+modello+categoria - vedi
-- ProductService.delete()/deleteByParams()/deleteAllByParams(), ora corretti per farlo).
-- Un catalog_bundle e' sicuro da eliminare solo se nessuna delle 3 FK esistenti lo
-- referenzia ancora: products, components, signage_configs.
--
-- Sintomo osservato: un modello gia' cancellato da una linea+categoria (es. DIR su
-- linea .../categoria 15) restava comunque selezionabile nella select "Modello" del
-- dettaglio prodotto, perche' quella select leggeva da catalog_bundles senza verificare
-- l'esistenza di prodotti live.
DELETE FROM catalog_bundles cb
WHERE NOT EXISTS ( SELECT 1 FROM products p WHERE p.catalog_bundle_id = cb.catalog_bundle_id )
    AND NOT EXISTS ( SELECT 1 FROM components c WHERE c.catalog_bundle_id = cb.catalog_bundle_id )
    AND NOT EXISTS ( SELECT 1 FROM signage_configs sc WHERE sc.catalog_bundle_id = cb.catalog_bundle_id );
