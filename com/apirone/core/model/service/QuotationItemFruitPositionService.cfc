component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationItemFruitPositionDAO";

	public com.apirone.core.model.bean.QuotationItemFruit function get( required Numeric quotationItemFruitPositionId ){
		return build( arguments.quotationItemFruitPositionId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	/**
	 * Il search() legge direttamente le colonne position e order dal find() del DAO.
	 */
	public com.apirone.core.model.bean.Result function search(
		String quotationItemFruitId,
	){

		var rows    = [];
		var result  = super.getResult();
		var records = getDao().find( argumentCollection = arguments );

		// Costruisce struct inline dalle colonne del find()
		records.each( function( record ){
			rows.add( {
				'position' = record.position,
				'order'    = record.order
			 } );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required Numeric quotationItemFruitPositionId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitPositionId = arguments.quotationItemFruitPositionId } );

		transaction {
			try {
				getDao().delete( arguments.quotationItemFruitPositionId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruitPosition" );
				outcome.setMessage( "Cannot delete quotation item fruit position [#arguments.quotationItemFruitPositionId#]" );
			}
		}

		return outcome;
	}

	public com.apirone.core.model.bean.Outcome function deleteByQuotationItemFruitId( required Numeric quotationItemFruitId ){
		var outcome = super.bean( "Outcome" );

		outcome.setData( { quotationItemFruitId = arguments.quotationItemFruitId } );

		transaction {
			try {
				getDao().deleteByQuotationItemFruitId( arguments.quotationItemFruitId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteQuotationItemFruitPosition" );
				outcome.setMessage( "Cannot delete quotation item fruit position by fruitId: [#arguments.quotationItemFruitId#]" );
			}
		}

		return outcome;
	}

	public Numeric function create( required quotationItemFruitId, required String position, required Numeric order ){
		var newId = getDao().insert( argumentCollection = arguments );

		return newId;
	}

	private com.apirone.core.model.bean.QuotationItemFruit function build( required Numeric quotationItemFruitPositionId ){
		return NullValue();
	}

}
