alter table public.quotation_item_product_items
    drop constraint fk_quotation_item_product_item_quotation_item;

alter table public.quotation_item_product_items
    add constraint fk_quotation_item_product_item_quotation_item
        foreign key (quotation_item_id) references public.quotation_items
            on delete cascade;

