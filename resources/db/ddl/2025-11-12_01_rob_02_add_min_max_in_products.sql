ALTER TABLE public.products
ADD COLUMN min_quantity INTEGER DEFAULT 0;

ALTER TABLE public.products
ADD COLUMN max_quantity INTEGER DEFAULT 0;

ALTER TABLE public.products
ADD COLUMN special BOOLEAN DEFAULT FALSE;