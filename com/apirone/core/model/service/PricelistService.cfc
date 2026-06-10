component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PricelistDAO";

	public com.apirone.core.model.bean.Pricelist function get( required String pricelistId ){
		return build( arguments.pricelistId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return read( argumentCollection = arguments ).getData()
	}

	private com.apirone.core.model.bean.Result function read(
		String pricelistId,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Unica query per tutti i record, senza chiamate individuali a get()
		var records = getDao().read( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( buildFromQueryRow( record ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );

		return result;
	}

	private com.apirone.core.model.bean.Pricelist function build( required String pricelistId ){
		var record = getDao().read( arguments.pricelistId );

		if ( record.RecordCount ) {
			return buildFromQueryRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Pricelist a partire da una riga della query, senza chiamata DB aggiuntiva.
	 * Utilizzato sia da build() (record singolo) che da read() (iterazione batch).
	 */
	private com.apirone.core.model.bean.Pricelist function buildFromQueryRow( required any record ){
		var obj = super.bean( "Pricelist" );

		// Campi diretti dal record (il pricelist non ha sub-entity)
		obj.setId( record.pricelist_id.toString() );
		obj.setName( record.pricelist );

		return obj;
	}

}
