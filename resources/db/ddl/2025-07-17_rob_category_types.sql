-- 2025-07-14

ALTER TABLE public.combinations
  RENAME TO products;

ALTER TABLE public.products
  RENAME COLUMN combination_id TO product_id;

ALTER INDEX public.combinations_pkey
  RENAME TO combinations_idx;

 -- object recreation
ALTER TABLE public.products
  DROP CONSTRAINT combinations_idx RESTRICT;

CREATE UNIQUE INDEX combinations_idx ON public.products
  USING btree (finish_id, line_id, size_id);

ALTER INDEX public.combinations_idx
  RENAME TO products_idx;

 -- object recreation
DROP INDEX public.products_idx;

ALTER TABLE public.products
  ADD CONSTRAINT products_idx 
    UNIQUE (finish_id, line_id, size_id) NOT DEFERRABLE;

ALTER INDEX public.combinations_combination_id_unique
  RENAME TO products_pkey2;

ALTER TABLE public.products
  ADD CONSTRAINT products_pkey 
    PRIMARY KEY (product_id) NOT DEFERRABLE;

-- DA RICOSTRUIRE
ALTER TABLE public.components
  DROP CONSTRAINT components_combination_id_fk RESTRICT;

-- DA RICOSTRUIRE
ALTER TABLE public.files
  DROP CONSTRAINT files_combination_id_fk RESTRICT;

-- DA RICOSTRUIRE
ALTER TABLE public.product_items
  DROP CONSTRAINT combination_items_combination_id_fk RESTRICT;

ALTER TABLE public.products
  DROP CONSTRAINT products_pkey2 RESTRICT;


-- RICOSTRUITO
ALTER TABLE public.components
  RENAME COLUMN combination_id TO product_id;

ALTER TABLE public.components
  ADD CONSTRAINT components_product_id_fk FOREIGN KEY (product_id)
    REFERENCES public.products(product_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;

-- RICOSTRUITO
ALTER TABLE public.files
  RENAME COLUMN combination_id TO product_id;

ALTER TABLE public.files
  ADD CONSTRAINT files_product_id_fk FOREIGN KEY (product_id)
    REFERENCES public.products(product_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;

-- RICOSTRUITO
ALTER TABLE public.product_items
  RENAME COLUMN combination_id TO product_id;

ALTER TABLE public.product_items
  ADD CONSTRAINT product_items_product_id_fk FOREIGN KEY (product_id)
    REFERENCES public.products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.products
  ADD COLUMN product_category_id INTEGER;

UPDATE products SET product_category_id = 22;


ALTER TABLE public.components
  RENAME COLUMN fruit_id TO _fruit_id;

ALTER TABLE public.components
  RENAME COLUMN fruit_combination_item_id TO _fruit_combination_item_id;

ALTER TABLE public.fruits
  RENAME TO _fruits;

ALTER TABLE public.product_items
  RENAME COLUMN fruit_id TO _fruit_id;

ALTER TABLE public.texts
  RENAME COLUMN fruit_id TO _fruit_id;

ALTER TABLE public.texts
  ADD COLUMN product_id UUID;

ALTER TABLE public.products
  ADD COLUMN code VARCHAR(15) UNIQUE;


ALTER TABLE public.products
  ADD CONSTRAINT products_product_category_id_fk FOREIGN KEY (product_category_id)
    REFERENCES public.product_categories(product_category_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.products
  ALTER COLUMN product_category_id SET NOT NULL;

UPDATE status set entities = '["LINE", "ATTRIBUTE", "FINISH", "SIZE", "ACCOUNT", "PRODUCTION_TIME", "PRODUCT_CATEGORY", "PRODUCT", "RAW_VALUE"]'
WHERE status_id IN ('ACT', 'DEA');

ALTER TABLE public.status
  RENAME TO statuses;

ALTER TABLE public.products
  ALTER COLUMN finish_id DROP NOT NULL;

ALTER TABLE public.products
  ALTER COLUMN line_id DROP NOT NULL;

ALTER TABLE public.products
  ALTER COLUMN size_id DROP NOT NULL;

ALTER TABLE public.texts
  ADD CONSTRAINT texts_product_id_fk FOREIGN KEY (product_id)
    REFERENCES public.products(product_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.products
  ADD COLUMN position_count INTEGER DEFAULT 0;


-- 2025-07-15

create table combinations
(
    combination_id uuid      default uuid_generate_v4(),
    product_id     uuid not null
        constraint combinations_products_product_id_fk
            references products
            on update cascade,
    created_at     timestamp default now()
);

alter table combinations
    add constraint combinations_pk
        primary key (combination_id);

create table combination_product_items
(
    combination_product_item_id uuid      default uuid_generate_v4() not null,
    product_item_id             int
        constraint combination_product_items_product_items_product_item_id_fk
            references product_items
            on update cascade,
    combination_id              uuid
        constraint combination_product_items_combinations_combination_id_fk
            references combinations (combination_id)
            on update cascade on delete cascade,
    created_at                  timestamp default now()
);

alter table combination_product_items
    add constraint combination_product_items_pk
        primary key (combination_product_item_id);

alter table files
    drop column combination_id;

ALTER TABLE public.files
  ADD COLUMN combination_id UUID;

ALTER TABLE public.files
  ADD CONSTRAINT files_combination_id_fk FOREIGN KEY (combination_id)
    REFERENCES public.combinations(combination_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
    NOT DEFERRABLE;

alter table products alter code type varchar(20);


-- 2025-07-17

CREATE TABLE public.category_types (
  category_type_id VARCHAR(5) STORAGE PLAIN,
  category_type VARCHAR(255) STORAGE PLAIN,
  orderby INTEGER STORAGE PLAIN,
  PRIMARY KEY(category_type_id)
) ;

ALTER TABLE public.product_categories
  ADD COLUMN category_type_id VARCHAR(5);

ALTER TABLE public.product_categories
  ADD CONSTRAINT product_categories_type_id_fk FOREIGN KEY (category_type_id)
    REFERENCES public.category_types(category_type_id)
    ON DELETE NO ACTION
    ON UPDATE CASCADE
    NOT DEFERRABLE;

ALTER TABLE public.category_types
  RENAME TO product_category_types;

ALTER TABLE public.product_category_types
  RENAME COLUMN category_type_id TO product_category_type_id;

ALTER TABLE public.product_category_types
  RENAME COLUMN category_type TO product_category_type;

ALTER TABLE public.product_category_types
  ADD COLUMN created_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT now();

ALTER TABLE public.product_category_types
  ADD COLUMN status_id VARCHAR(3);

INSERT INTO public.product_category_types ("product_category_type_id", "product_category_type", "orderby", "created_at", "status_id")
VALUES 
  (E'ACC', E'Accessori', 40, E'2025-07-17 13:11:55', E'ACT'),
  (E'FRU', E'Frutti', 20, E'2025-07-17 13:12:01', E'ACT'),
  (E'PLA', E'Placche', 10, E'2025-07-17 13:12:49', E'ACT'),
  (E'SEG', E'Segnaletica', 30, E'2025-07-17 13:12:54', E'ACT');

ALTER TABLE public.product_categories
  RENAME COLUMN category_type_id TO procut_category_type_id;

ALTER TABLE public.product_categories
  RENAME COLUMN procut_category_type_id TO product_category_type_id;

UPDATE product_categories SET product_category_type_id = 'ACC'
WHERE product_category_id in (4,5,6,7,8,9,10,11,12,13,14,15,16,17,18);

UPDATE product_categories SET product_category_type_id = 'SEG'
WHERE product_category_id in (19,20,21);

UPDATE product_categories SET product_category_type_id = 'PLA'
WHERE product_category_id in (22);

UPDATE product_categories SET product_category_type_id = 'FRU'
WHERE product_category_id in (167);

