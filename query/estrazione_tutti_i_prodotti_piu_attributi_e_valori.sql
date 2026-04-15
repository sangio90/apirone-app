select
	p.product_id,
	product_categories_texts.text as categoria,
	lines_texts.text as linea,
	models_texts.text as modello,
	finishes_texts.text as finitura,

	(
		select json_agg(
				   json_build_object(
					   'attributo', t.attributo,
					   'valore', t.valore
				   )
				   order by t.attributo, t.valore
			   )
		from (
				 select distinct
					 at.text as attributo,
					 arv_t.text as valore
				 from product_items pi
						  join attributes_raw_values arv
							   on pi.attribute_raw_value_id = arv.attribute_raw_value_id
						  join texts arv_t
							   on arv_t.raw_value_id = arv.raw_value_id
								   and arv_t.lang_id = 'IT'
								   and arv_t.text_kind_id = 'NAME'
						  join texts at
							   on at.attribute_id = arv.attribute_id
								   and at.lang_id = 'IT'
								   and at.text_kind_id = 'NAME'
				 where pi.product_id = p.product_id
			 ) t
	) as configurazioni

from products p

		 inner join catalog_bundles cb
					on p.catalog_bundle_id = cb.catalog_bundle_id

		 inner join texts product_categories_texts
					on product_categories_texts.product_category_id = cb.product_category_id
						and product_categories_texts.lang_id = 'IT'
						and product_categories_texts.text_kind_id = 'NAME'

		 inner join texts lines_texts
					on lines_texts.line_id = cb.line_id
						and lines_texts.lang_id = 'IT'
						and lines_texts.text_kind_id = 'NAME'

		 inner join texts models_texts
					on models_texts.model_id = cb.model_id
						and models_texts.lang_id = 'IT'
						and models_texts.text_kind_id = 'NAME'

		 inner join finishes f
					on p.finish_id = f.finish_id

		 inner join texts finishes_texts
					on finishes_texts.finish_id = p.finish_id
						and finishes_texts.lang_id = 'IT'
						and finishes_texts.text_kind_id = 'NAME'

-- JOIN attributi
		 left join product_items pi
				   on pi.product_id = p.product_id

		 left join attributes_raw_values arv
				   on pi.attribute_raw_value_id = arv.attribute_raw_value_id

		 left join texts attributes_raw_values_texts
				   on attributes_raw_values_texts.raw_value_id = arv.raw_value_id
					   and attributes_raw_values_texts.lang_id = 'IT'
					   and attributes_raw_values_texts.text_kind_id = 'NAME'

		 left join attributes a
				   on arv.attribute_id = a.attribute_id

		 left join texts attributes_texts
				   on attributes_texts.attribute_id = a.attribute_id
					   and attributes_texts.lang_id = 'IT'
					   and attributes_texts.text_kind_id = 'NAME'

where product_categories_texts.text <> 'PLACCHE'

group by
	p.product_id,
	product_categories_texts.text,
	lines_texts.text,
	models_texts.text,
	finishes_texts.text

order by product_categories_texts.text;
