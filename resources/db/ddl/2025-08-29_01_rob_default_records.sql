INSERT INTO public.pricelists ("pricelist_id", "pricelist", "created_at")
VALUES 
  (E'15460ccc-bda3-4657-abdb-96b369cd8649', E'Listino prezzi base', E'2025-08-29 12:21:48.760');

INSERT INTO public.payment_methods ("payment_method_id", "payment_method", "created_at")
VALUES 
  (E'479afd16-b5f4-476b-90b3-93c7ee169118', E'Bonifico bancario', E'2025-08-29 12:21:19.322');  


INSERT INTO public.currencies ("currency_id", "currency", "created_at")
VALUES 
  (E'f6a97ea2-d9d7-4c43-bc21-0d4a7111d85b', E'EUR', E'2025-08-29 12:23:00.589');

INSERT INTO public.profiles ("profile_id", "first_name", "last_name", "company", "vat_number", "email", "phone", "country_id", "state", "city", "postal_code", "street", "created_at", "type")
VALUES 
  (E'3a9253a7-f299-4b46-8e6f-49d608eafc96', E'Roberto Sped', E'Marzialetti Sped', E'Nimesia Sped Snc', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, E'2025-08-29 12:25:54.826', E'G'),
  (E'9f36b292-7467-41de-91b2-51223f9694fa', E'Roberto', E'Marzialetti', E'Nimesia Snc', NULL, E'roberto@nimesia.it', NULL, NULL, NULL, NULL, NULL, NULL, E'2025-08-29 12:24:23.092', E'G');  
