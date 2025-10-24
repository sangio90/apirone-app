component extends="com.apirone.core.controller.AbsController" {

	function updateSearchTerms( event, rc, prc ){
		requestTimeOut = 99999999999999;

		var containter = server[ "wirebox-apirone" ];
		var svc        = containter.getInstance( "ProductService" );

		var q = QueryExecute(
			"
			SELECT 
				products.product_id
			FROM products
			ORDER BY products.created_at DESC
		",
			[],
			{ datasource = "apirone" }
		);

		for ( var row in q ) {
			var product = svc.get( row.product_id );
			var term    = "";

			if ( IsNull( product.getModel() ) ) {
				term &= product.getName() & " ";
			} else {
				if ( !IsNull( product.getCategory() ) ) {
					term &= product.getCategory().getName() & " ";
				}

				if ( !IsNull( product.getLine() ) ) {
					term &= product.getLine().getName() & " ";
				}

				if ( !IsNull( product.getModel() ) ) {
					term &= product.getModel().getName() & " ";
				}

				if ( !IsNull( product.getFinish() ) ) {
					term &= product.getFinish().getName();
				}
			}

			var existingElement = QueryExecute(
				"
				SELECT product_id, search_term
				FROM utils.search_terms
				WHERE product_id = CAST(:product_id AS uuid) and lang_id = 'IT'
			",
				{ product_id = product.getId() },
				{ datasource = "apirone" }
			);

			// CREATE
			if ( IsNull( existingElement ) ) {
				WriteDump( "Create " & existingElement.search_term );
				QueryExecute(
					"
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
				",
					{ term = term, product_id = product.getId() },
					{ datasource = "apirone" }
				);
				// UPDATE
			}
			elseif( Trim( existingElement.search_term ) != Trim( term ) ){
				WriteDump( "Update " & existingElement.search_term );
				QueryExecute(
					"
					UPDATE utils.search_terms
					SET search_term = :term
					WHERE product_id = CAST(:product_id AS uuid) and lang_id = 'IT'
				",
					{ term = term, product_id = product.getId() },
					{ datasource = "apirone" }
				);
			}
		}
	}

}
