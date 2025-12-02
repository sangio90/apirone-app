alter table quotations
    drop constraint fk_billing_quotation_profile;

alter table quotations
    drop constraint fk_shipping_quotation_profile;

