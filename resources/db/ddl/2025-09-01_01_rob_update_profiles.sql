UPDATE profiles 
SET
    country_id = '693a3dda-bf35-4556-9a12-2c693afce836'
WHERE profile_id IN ('3a9253a7-f299-4b46-8e6f-49d608eafc96', '9f36b292-7467-41de-91b2-51223f9694fa');

UPDATE profiles 
SET
    type = 'B'
WHERE profile_id = '3a9253a7-f299-4b46-8e6f-49d608eafc96';

UPDATE profiles 
SET
    type = 'S'
WHERE profile_id = '9f36b292-7467-41de-91b2-51223f9694fa';

ALTER TABLE public.profiles
  ALTER COLUMN country_id SET NOT NULL;

ALTER TABLE public.profiles
  ALTER COLUMN type SET DEFAULT 'B'::bpchar;