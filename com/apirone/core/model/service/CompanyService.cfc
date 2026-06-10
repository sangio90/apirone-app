component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CompanyDAO";
	property name="statusService" inject="StatusService";
	property name="locationService" inject="LocationService";
	property name="accountService" inject="AccountService";
	property name="companyTypeService" inject="CompanyTypeService";

	public com.apirone.core.model.bean.Company function get( required String companyId ){
		return build( arguments.companyId );
	}

	public Boolean function vatExists( required String vat ){
		var companies = list( argumentCollection = arguments ).getData();

		return !IsNull( companies[ 1 ] )
	}

	public com.apirone.core.model.bean.Result function list( String vat ){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments )
	}


	public com.apirone.core.model.bean.Result function search(
		String vat,
		required Numeric limit  = 20,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.company_id );
		} );

		var beanMap = {};
		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );

			allRecords.each( function( r ){
				beanMap[ r.company_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.company_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Company company ){
		if ( vatExists( arguments.company.getVat() ) ) {
			Throw( type = "apirone.VatExits", message = "Vat [#arguments.company.getVat()#] exists" );
		}

		transaction {
			var accountId = getAccountService().create( account = arguments.company.getAccount() );

			arguments.company.getAccount().setId( accountId );

			var id = getDao().insert( company = arguments.company );

			var entity = super.bean( "Entity" );

			entity.setType( "C" );
			entity.setId( id );

			getLocationService().create( entity = entity, location = arguments.company.getLocation() );

			return id;
		}
	}

	public String function update( required com.apirone.core.model.bean.Company company ){
		transaction {
			var id = getDao().update( company = arguments.company );

			getLocationService().update( location = arguments.company.getLocation() );

			return id;
		}
	}

	public Boolean function delete( required String companyId ){
		var result = getDao().delete( arguments.companyId );

		return result;
	}

	/*
    	private method
	*/

	private com.apirone.core.model.bean.Company function build( required String companyId ){
		var record = getDao().read( arguments.companyId );

		if ( record.RecordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Company a partire da una riga della query.
	 * Le sub-entity (Location, Account, Types, Status) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Company function buildFromRow( required any record ){
		var company = super.bean( "Company" );
		var types = [];

		// Campi diretti dal record
		company.setId( arguments.record.company_id.toString() );
		company.setName( arguments.record.company );
		company.setVat( arguments.record.vat );
		company.setContact( arguments.record.contact );
		company.setPhone( arguments.record.phone );
		company.setCode( arguments.record.code );

		// Entity collegate (caricate singolarmente)
		company.setLocation( getLocationService().list( companyId = arguments.record.company_id ).getData()[ 1 ] );
		company.setAccount( getAccountService().get( accountId = arguments.record.account_id.toString() ) );

		DeserializeJSON( arguments.record.types.getValue() ).each( function( typeId ){
			types.push( getCompanyTypeService().get( typeId ) );
		} );

		company.setTypes( types );
		company.setStatus( getStatusService().get( arguments.record.status_id ) );

		return company;
	}

}
