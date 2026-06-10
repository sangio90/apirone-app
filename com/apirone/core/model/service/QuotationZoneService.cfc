component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationZoneDAO";
	property name="QuotationService" inject="QuotationService";
	property name="QuotationItemService" inject="QuotationItemService";
	property name="QuotationItemFruitService" inject="QuotationItemFruitService";
	property name="QuotationItemPriceService" inject="QuotationItemPriceService";
	property name="QuotationItemProductItemService" inject="QuotationItemProductItemService";
	property name="QuotationItemSignageRowService" inject="QuotationItemSignageRowService";
	property name="FileService" inject="FileService";
	property name="QuotationZoneService" inject="QuotationZoneService";

	public com.apirone.core.model.bean.QuotationZone function get( required String zoneId ){
		return build( arguments.zoneId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "quotation.id" } ]
	){
		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var rows    = [];
		var result  = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		if ( records.recordCount ) {
			// Raccoglie tutti gli ID e carica i record in blocco con una sola query
			var ids = [];
			for ( var record in records ) {
				ids.append( record.quotation_zone_id );
			}

			var loadedRecords = getDao().readByIds( ids );
			var recordMap = {};
			for ( var loadedRecord in loadedRecords ) {
				recordMap[ loadedRecord.quotation_zone_id ] = loadedRecord;
			}

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				var fullRecord = recordMap[ record.quotation_zone_id ];
				if ( !IsNull( fullRecord ) ) {
					rows.add( buildFromRow( fullRecord ) );
				}
			}
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String zoneId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.zoneId );

		outcome.setData( { zoneId = arguments.zoneId } );

		transaction {
			try {
				getDao().delete( arguments.zoneId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotationZone" );
				outcome.setMessage( "Cannot delete zone [#arguments.zoneId#]" );
			}
		}
		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.QuotationZone zone ){
		var newId = getDao().insert( arguments.zone );

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.QuotationZone zone ){
		getDao().update( arguments.zone );

		return arguments.zone.getId();
	}

	public function duplicate( required String zoneId, required quotationId, duplicaConSottozone = true, name = null ) {
		var quotationZone = super.bean( "QuotationZone" );

		var zoneToDuplicate = get(arguments.zoneId);
		var name = !isNull(arguments.name) ? arguments.name : zoneToDuplicate.getName();

		var zoneObject = {
			quotationId = arguments.quotationId,
			name = name,
			quantity = zoneToDuplicate.getQuantity(),
			originId = !isNull( zoneToDuplicate.getOrigin() ) ?	zoneToDuplicate.getOrigin().getId() : null,
		}

		var existingCombination = search( argumentCollection = zoneObject );

		if( Len( existingCombination.getData() ) ) {
			Throw(
				type    = "ApirOne.errors.quotationZone.DuplicateZoneExists",
				message = getMessage( "zone.existInQuotation" ),
				detail  = "A zone with the same combination already exists in this quotation"
			);
		}
		var quotation = getQuotationService().get( arguments.quotationId )
		quotationZone.setQuotation( quotation );
		quotationZone.setName( name );
		quotationZone.setQuantity( zoneToDuplicate.getQuantity() );

		if ( !isNull( zoneObject.originId ) && !duplicaConSottozone ) {
			quotationZone.setOrigin( zoneToDuplicate.getOrigin() );
		}

		transaction {
			messageId = "quotationZone.created";
			thisId    = create( quotationZone )

			var duplicatedZone = duplicateZoneItems( duplicatedZoneId: zoneToDuplicate.getId(), newZoneId: thisId, quotation: quotation  );
			if (arguments.duplicaConSottozone) {
				var sottozone = list( originId = zoneToDuplicate.getId() )
				for (sottozona in sottozone) {
					var newSottozona = super.bean( "QuotationZone" );
					newSottozona.setQuotation( quotation );
					newSottozona.setName( sottozona.getName() );
					newSottozona.setQuantity( sottozona.getQuantity() );
					newSottozona.setOrigin( duplicatedZone );
					var newSottozonaId = create( newSottozona )
					//in caso di duplica all'interno di un preventivo passare quotation è superfluo, perché sto clonando una zona dentro lo stesso preventivo
					//in caso però di duplica del preventivo (e.g. approvazione preventivo) il preventivo che passo è quello clonato, quindi i nuovi items che creo dentro duplicateZoneItems, porteranno l'id del quotation clonato
					duplicateZoneItems( duplicatedZoneId: sottozona.getId(), newZoneId: newSottozonaId, quotation: quotation );
				}
			}
		}

		return { 'messageId': messageId, 'zoneId': thisId }
	}

	public function duplicateZoneItems( required String duplicatedZoneId, required String newZoneId, required quotation ) {
		var items = getQuotationItemService().list( quotationZoneId = arguments.duplicatedZoneId );
		var newZone = getQuotationZoneService().get( arguments.newZoneId )

		for (var quotationItem in items) {
			var duplicatedItem = Duplicate( quotationItem );
			duplicatedItem.setQuotationZone( newZone )
			duplicatedItem.setQuotation( quotation )
			var newItemId = getQuotationItemService().create( duplicatedItem );
			var newItem = getQuotationItemService().get( newItemId );

			//file
			var quotationItemFile = getFileService().search( quotationItemId = quotationItem.getId() ).getData();
			if ( Len(quotationItemFile) > 0 ) {
				var duplicatedFile = Duplicate( quotationItemFile[1] );
				getFileService().duplicate( duplicatedFile.getId(), newItem );
			}

			//quotation Item Product items
			var quotationItemProductItems = getQuotationItemProductItemService().list( quotationItemId = quotationItem.getId() );
			for ( var quotationItemProductItem in quotationItemProductItems ) {
				quotationItemProductItem.setId('')
				quotationItemProductItem.setQuotationItemId( newItemId )
				getQuotationItemProductItemService().create( quotationItemProductItem )
			}

			//quotation item signage rows
			var quotationItemSignageRows = getQuotationItemSignageRowService().list( quotationItemId = quotationItem.getId() );
			for ( var quotationItemSignageRow in quotationItemSignageRows ) {
				quotationItemSignageRow.setId('')
				quotationItemSignageRow.setQuotationItemId( newItemId )
				getQuotationItemSignageRowService().create( quotationItemSignageRow )
			}
		}

		return newZone
	}

	private com.apirone.core.model.bean.QuotationZone function buildFromRow( required any record ){
		var bean = super.bean( "QuotationZone" );

		// Campi diretti dal record
		bean.setId( record.quotation_zone_id );
		bean.setName( record.quotation_zone );
		bean.setQuantity( record.quantity );

		// Entity collegate (caricate singolarmente)
		bean.setQuotation( getQuotationService().get( record.quotation_id ) );

		bean.setOrigin(
			IsNull( record.origin_id ) ? NullValue() : getQuotationZoneService().get( record.origin_id )
		);

		var images = getFileService().list( quotationZoneId = record.quotation_zone_id );
		if ( Len( images ) ) {
			bean.setImage( images[ 1 ] );
		}

		return bean;
	}

	private com.apirone.core.model.bean.QuotationZone function build( required String zoneId ){
		var record = getDao().read( arguments.zoneId );
		if ( record.recordCount ) {
			return buildFromRow( record );
		}
		return NullValue();
	}

}
