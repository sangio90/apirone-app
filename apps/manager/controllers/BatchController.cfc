component extends="com.apirone.core.controller.AbsController" {

	function updateSearchTerms( event, rc, prc ){
		requestTimeOut = 99999999999999;

		containter = server["wirebox-apirone"];
		svc = containter.getInstance("ProductService");

		q = queryExecute("
			SELECT 
				products.product_id
			FROM products
			ORDER BY products.created_at DESC
		", [], { datasource = "apirone" });

		for (row in q) {
			product = svc.get(row.product_id);
			term = "";

			if (isNull(product.getModel())) {
				term &= product.getName() & " ";
			} else {
				if (!isNull(product.getCategory())) {
					term &= product.getCategory().getName() & " ";
				}

				if (!isNull(product.getLine())) {
					term &= product.getLine().getName() & " ";
				}

				if (!isNull(product.getModel())) {
					term &= product.getModel().getName() & " ";
				}

				if (!isNull(product.getFinish())) {
					term &= product.getFinish().getName();
				}
			}

			var existingElement = queryExecute("
				SELECT product_id, search_term
				FROM utils.search_terms
				WHERE product_id = CAST(:product_id AS uuid) and lang_id = 'IT'
			", { product_id = product.getId() }, { datasource = "apirone" });

			//CREATE
			if (isNull(existingElement)) {
				WriteDump('Create ' & existingElement.search_term);
				queryExecute("
					INSERT INTO utils.search_terms (
						search_term,
						product_id,
						lang_id
					)
					VALUES (
						:term,
						:product_id::uuid,
						'IT'
					)
				", { term: term, product_id = product.getId() }, { datasource = "apirone" });
			//UPDATE
			} elseif (trim(existingElement.search_term) != trim(term)) {
				WriteDump('Update ' & existingElement.search_term);
				queryExecute("
					UPDATE utils.search_terms
					SET search_term = :term
					WHERE product_id = CAST(:product_id AS uuid) and lang_id = 'IT'
				", { term: term, product_id = product.getId() }, { datasource = "apirone" });
			}
		}
	}

}
