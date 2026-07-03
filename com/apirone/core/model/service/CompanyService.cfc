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

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

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

	/**
	 * Recupera in batch più Company dato un array di ID.
	 * Restituisce uno Struct chiave = companyId, valore = bean Company.
	 * Precarica account, companyType e status in batch per evitare il problema N+1.
	 * Le location sono caricate una volta per ogni companyId univoco.
	 *
	 * @ids Array di companyId
	 * @return Struct mappato per companyId -> Company
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di tutte le FK da tutti i record
		var accountIds  = [];
		var allTypeIds  = [];
		for ( var record in records ) {
			if ( !IsNull( record.account_id ) ) {
				accountIds.append( record.account_id );
			}
			// Raccoglie i typeId dal JSONB types
			var types = IsNull( record.types ) ? [] : DeserializeJSON( record.types );
			if ( !IsNull( types ) && ArrayLen( types ) ) {
				for ( var tid in types ) {
					allTypeIds.append( tid );
				}
			}
		}

		// Precarica le location in batch: una chiamata list() per ogni companyId univoco.
		// LocationService.list() filtra per company_id e internamente fa già batch via search().
		var locationMap = {};
		for ( var cid in arguments.ids ) {
			if ( !StructKeyExists( locationMap, cid ) ) {
				var locs = getLocationService().list( companyId = cid ).getData();
				if ( ArrayLen( locs ) ) {
					locationMap[ cid ] = locs[ 1 ];
				}
			}
		}

		// Precarica gli account in batch: AccountService non ha getMany(), usa DAO
		var accountMap = {};
		if ( ArrayLen( accountIds ) ) {
			var uniqueAccountIds = [];
			for ( var aid in accountIds ) {
				if ( !IsNull( aid ) ) {
					var aidStr = aid.toString();
					if ( !ArrayContains( uniqueAccountIds, aidStr ) ) {
						uniqueAccountIds.append( aidStr );
					}
				}
			}
			if ( ArrayLen( uniqueAccountIds ) ) {
				var accRecords = getAccountService().getDao().readByIds( uniqueAccountIds );
				for ( var ar in accRecords ) {
					var accBean = super.bean( "Account" );
					accBean.setId( ar.account_id.toString() );
					accBean.setEmail( ar.email );
					accBean.setName( ar.account );
					accBean.setPwd( ar.pwd );
					accBean.setSerial( ar.serial );
					accBean.setLastLoggedUserId( ar.last_logged_user_id );
					accBean.setCreatedAt( ar.created_at );
					accBean.setUserCount( ar.user_count );
					accBean.setIdUtenteVerticale( ar.id_utente_verticale );
					accBean.setIdAgenteVerticale( ar.id_agente_verticale );
					accBean.setStatus( getStatusService().get( ar.status_id ) );
					accountMap[ ar.account_id.toString() ] = accBean;
				}
			}
		}

		// Precarica i companyType in batch: CompanyTypeService non ha getMany(), usa DAO
		var typeMap = {};
		if ( ArrayLen( allTypeIds ) ) {
			var typeRecords = getCompanyTypeService().getDao().readByIds( allTypeIds );
			for ( var tr in typeRecords ) {
				var typeBean = super.bean( "CompanyType" );
				typeBean.setId( tr.company_type_id );
				typeBean.setName( tr.company_type );
				typeMap[ tr.company_type_id ] = typeBean;
			}
		}

		// Cache locale per status
		var statuses = {};

		for ( var record in records ) {
			var company = super.bean( "Company" );

			// Campi diretti dal record
			company.setId( record.company_id.toString() );
			company.setName( record.company );
			company.setVat( record.vat );
			company.setContact( record.contact );
			company.setPhone( record.phone );
			company.setCode( record.code );

			// Location: dalla mappa pre-caricata
			if ( StructKeyExists( locationMap, record.company_id ) ) {
				company.setLocation( locationMap[ record.company_id ] );
			}

			// Account: dalla mappa pre-caricata
			if ( !IsNull( record.account_id ) && StructKeyExists( accountMap, record.account_id.toString() ) ) {
				company.setAccount( accountMap[ record.account_id.toString() ] );
			}

			// Types: dalla mappa pre-caricata
			var types = IsNull( record.types ) ? [] : DeserializeJSON( record.types.getValue() );
			var typeBeans = [];
			if ( !IsNull( types ) && ArrayLen( types ) ) {
				for ( var typeId in types ) {
					if ( StructKeyExists( typeMap, typeId ) ) {
						typeBeans.append( typeMap[ typeId ] );
					}
				}
			}
			company.setTypes( ArrayLen( typeBeans ) ? typeBeans : [] );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			company.setStatus( statuses[ record.status_id ] );

			map[ record.company_id ] = company;
		}

		return map;
	}

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
