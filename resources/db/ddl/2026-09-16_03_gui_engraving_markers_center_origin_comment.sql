-- Nessun cambio di schema: le colonne erano già NUMERIC senza vincoli di segno.
-- Cambia solo la semantica delle coordinate (nessun marker esistente da convertire,
-- la tabella era vuota al momento di questa modifica): lo zero ora è il centro
-- dell'immagine base del frutto (prima era l'angolo in alto a sinistra), con
-- un'area di lavoro di ±80mm per asse (160x160mm) invece dei soli bordi dell'immagine,
-- per poter posizionare incisioni anche fuori dal frutto (es. scritte sopra al pulsante).

COMMENT ON TABLE public.product_engraving_markers IS
    'Griglia incisioni dei frutti: posizioni ammesse per il simbolo inciso, per frutto e per attributo "radice" (IS/II/IL). Coordinate del centro del marker RISPETTO AL CENTRO dell''immagine orizzontale del frutto (non più l''angolo in alto a sinistra), in px nativi e in mm (modulo frutto 11,25 x 45 mm). Range ammesso -80..80mm per asse (area di lavoro 160x160mm, frutto al centro).';

COMMENT ON COLUMN public.product_engraving_markers.x_mm IS
    'Offset dal centro dell''immagine in mm, positivo verso destra. Range -80..80.';

COMMENT ON COLUMN public.product_engraving_markers.y_mm IS
    'Offset dal centro dell''immagine in mm, positivo verso il basso. Range -80..80.';

COMMENT ON COLUMN public.product_engraving_markers.x_px IS
    'Offset dal centro dell''immagine in px nativi (stessa scala di x_mm), può eccedere la larghezza dell''immagine.';

COMMENT ON COLUMN public.product_engraving_markers.y_px IS
    'Offset dal centro dell''immagine in px nativi (stessa scala di y_mm), può eccedere l''altezza dell''immagine.';
