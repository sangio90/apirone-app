/*
  2025-07-28
*/
-- create table documents
DROP TABLE IF EXISTS public.quotations;
DROP TABLE IF EXISTS public.quotation_status;

INSERT INTO statuses (
    status_id, "status", entities, created_at, orderby, color_id
) VALUES
    ('LAV', 'In Lavorazione', '["QUOTATIONS"]', NOW(), 1, '#eff2b2ff'),
    ('PRO', 'Pronto', '["QUOTATIONS"]', NOW(), 2, '#36cc00ff'),
    ('APR', 'In Approvazione', '["QUOTATIONS"]', NOW(), 3, '#cdee98ff'),
    ('CON', 'Convertito in Ordine', '["QUOTATIONS"]', NOW(), 4, '#0088CC'),
    ('PER', 'Perso', '["QUOTATIONS"]', NOW(), 5, '#f0b49eff'),
    ('EST', 'Estinto', '["QUOTATIONS"]', NOW(), 6, '#babfc2ff');

CREATE TABLE public.quotations (
  quotation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quotation_description TEXT,
  quotation_number VARCHAR(100) UNIQUE NOT NULL,
  status_id VARCHAR(3) NOT NULL,
  lang_id VARCHAR(2),
  quotation_date DATE,
  notes TEXT,
  validity_date DATE,
  opportunity_name VARCHAR(255),
  lead_name VARCHAR(255),
  pricelist VARCHAR(255),
  payment_method VARCHAR(255),
  custom_payment_method VARCHAR(255),
  currency VARCHAR(10),
  billing_profile_id UUID,
  shipping_profile_id UUID NULL,
  sales_agent_account_id UUID,
  graphic_technician_account_id UUID,
  created_at timestamp default now(),
  CONSTRAINT fk_sales_agent_account
    FOREIGN KEY(sales_agent_account_id) REFERENCES public.accounts(account_id),
  CONSTRAINT fk_graphic_technician_account
    FOREIGN KEY(graphic_technician_account_id) REFERENCES public.accounts(account_id)
);

CREATE TABLE public.profiles (
  profile_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name VARCHAR(255),
  last_name VARCHAR(255),
  company VARCHAR(255),
  vat_number VARCHAR(50),
  email VARCHAR(255),
  phone VARCHAR(50),
  country_id UUID,
  state VARCHAR(100),
  city VARCHAR(100),
  postal_code VARCHAR(20),
  street TEXT,
  created_at timestamp default now(),
  CONSTRAINT fk_profile_country_id
	  FOREIGN KEY(country_id) REFERENCES public.countries(country_id)
);

CREATE TABLE public.quotation_items (
  quotation_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quotation_id UUID NOT NULL,
  quotation_item_zone_id UUID NOT NULL,
  quotation_item_position_id UUID NOT NULL,
  quotation_item_product_id UUID NOT NULL,
  price NUMERIC(12, 2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  created_at timestamp default now()
);

CREATE TABLE public.quotation_item_zones (
  quotation_item_zone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  zone_name VARCHAR(255) NOT NULL,
  quotation_item_id UUID,
  parent_id UUID NULL,
  created_at timestamp default now()
);

CREATE TABLE public.quotation_item_positions (
  quotation_item_position_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quotation_item_zone_id UUID NOT NULL,
  position_coordinate_x VARCHAR(255) NOT NULL,
  position_coordinate_y VARCHAR(255) NOT NULL,
  created_at timestamp default now()
);

CREATE TABLE public.quotation_item_products (
  quotation_item_product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quotation_item_id UUID,
  product_id UUID,
  parent_id UUID NULL,
  created_at timestamp default now()
);

CREATE TABLE public.quotation_item_product_items (
  quotation_item_product_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quotation_item_product_id UUID,
  product_item_id INT,
  parent_id UUID NULL,
  created_at timestamp default now()
);



--quotations foreign keys
ALTER TABLE public.quotations
	ADD CONSTRAINT fk_billing_quotation_profile
		FOREIGN KEY (billing_profile_id) REFERENCES public.profiles(profile_id);
ALTER TABLE public.quotations
	ADD CONSTRAINT fk_shipping_quotation_profile
		FOREIGN KEY (shipping_profile_id) REFERENCES public.profiles(profile_id);

--quotation_item_zones foreign keys
ALTER TABLE public.quotation_item_zones
  ADD CONSTRAINT fk_quotation_item_zone_parent
  FOREIGN KEY (parent_id) REFERENCES public.quotation_item_zones(quotation_item_zone_id);
ALTER TABLE public.quotation_item_zones
  ADD CONSTRAINT fk_quotation_item_zone_quotation_item
  FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(quotation_item_id);

--quotation_item_positions foreign keys
ALTER TABLE public.quotation_item_positions
  ADD CONSTRAINT fk_quotation_positions_zone
  FOREIGN KEY (quotation_item_zone_id) REFERENCES public.quotation_item_zones(quotation_item_zone_id);

--quotation_item_products foreign keys
ALTER TABLE public.quotation_item_products
  ADD CONSTRAINT quotation_item_product_parent
  FOREIGN KEY (parent_id) REFERENCES public.quotation_item_products(quotation_item_product_id);

ALTER TABLE public.quotation_item_products
  ADD CONSTRAINT fk_quotation_item_product_quotation_item
  FOREIGN KEY (quotation_item_id) REFERENCES public.quotation_items(quotation_item_id);

ALTER TABLE public.quotation_item_products
  ADD CONSTRAINT fk_quotation_item_product_product
  FOREIGN KEY (product_id) REFERENCES public.products(product_id);

--quotation_item_product_items foreign keys
ALTER TABLE public.quotation_item_product_items
	ADD CONSTRAINT quotation_item_product_item_parent
	FOREIGN KEY (parent_id) REFERENCES public.quotation_item_product_items(quotation_item_product_item_id);

ALTER TABLE public.quotation_item_product_items
  ADD CONSTRAINT fk_quotation_item_product_item_quotation_item_product
  FOREIGN KEY (quotation_item_product_id) REFERENCES public.quotation_item_products(quotation_item_product_id);

ALTER TABLE public.quotation_item_product_items
  ADD CONSTRAINT fk_quotation_item_product_item_product_item
  FOREIGN KEY (product_item_id) REFERENCES public.product_items(product_item_id);

--quotation_items foreign keys
ALTER TABLE public.quotation_items
  ADD CONSTRAINT fk_quotation_items_quotation
  FOREIGN KEY (quotation_id) REFERENCES public.quotations(quotation_id);

ALTER TABLE public.quotation_items
  ADD CONSTRAINT fk_quotation_item_quotation_item_zone
  FOREIGN KEY (quotation_item_zone_id) REFERENCES public.quotation_item_zones(quotation_item_zone_id);

ALTER TABLE public.quotation_items
  ADD CONSTRAINT fk_quotation_item_quotation_item_position
  FOREIGN KEY (quotation_item_position_id) REFERENCES public.quotation_item_positions(quotation_item_position_id);

ALTER TABLE public.quotation_items
  ADD CONSTRAINT fk_quotation_item_quotation_item_product
  FOREIGN KEY (quotation_item_product_id) REFERENCES public.quotation_item_products(quotation_item_product_id);