select
	product_categories_texts.text,
	lines_texts.text,
	models_texts.text,
	finishes_texts.text
from products
		 inner join catalog_bundles on products.catalog_bundle_id = catalog_bundles.catalog_bundle_id
		 inner join texts product_categories_texts on
	product_categories_texts.product_category_id = catalog_bundles.product_category_id and
	product_categories_texts.lang_id = 'IT' and product_categories_texts.text_kind_id = 'NAME'
		 inner join texts lines_texts on
	lines_texts.line_id = catalog_bundles.line_id and lines_texts.lang_id = 'IT' and lines_texts.text_kind_id = 'NAME'
		 inner join texts models_texts on
	models_texts.model_id = catalog_bundles.model_id and models_texts.lang_id = 'IT' and models_texts.text_kind_id = 'NAME'
		 inner join finishes on products.finish_id = finishes.finish_id
		 inner join texts finishes_texts on
	finishes_texts.finish_id = products.finish_id and finishes_texts.lang_id = 'IT' and finishes_texts.text_kind_id = 'NAME'
where product_categories_texts.text <> 'PLACCHE'
order by product_categories_texts.text

select
	attributes_texts.text,
	attributes_raw_values_texts.text
from
	product_items
		inner join
	attributes_raw_values on product_items.attribute_raw_value_id = attributes_raw_values.attribute_raw_value_id
		inner join texts attributes_raw_values_texts on
		attributes_raw_values_texts.raw_value_id = attributes_raw_values.raw_value_id and attributes_raw_values_texts.lang_id = 'IT' and attributes_raw_values_texts.text_kind_id = 'NAME'
		inner join
	attributes on attributes_raw_values.attribute_id = attributes.attribute_id
		inner join texts attributes_texts on
		attributes_texts.attribute_id = attributes_raw_values.attribute_id and attributes_texts.lang_id = 'IT' and attributes_texts.text_kind_id = 'NAME'