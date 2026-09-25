-- Righe preventivo salvate senza prezzo configurato.
--
-- Se il prodotto di una riga (o un suo componente, es. un frutto di una placca) non ha
-- il prezzo "Markup articolo" (prices.price_type_id = 'PRICE'), il calcolo non blocca
-- più il salvataggio: quel prodotto vale 0 e la riga viene marcata con missing_price.
-- Il flag viene riscritto a ogni ricalcolo del prezzo della riga (salvataggio,
-- "Aggiorna tutti i prezzi", aggiornamento dei gemelli): configurato il prezzo, sparisce.
-- Le righe a prezzo fisso (price_method_id = 'F') non vengono mai marcate.

ALTER TABLE public.quotation_item_prices
    ADD COLUMN IF NOT EXISTS missing_price BOOLEAN NOT NULL DEFAULT FALSE;
