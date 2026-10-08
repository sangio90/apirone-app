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
	property name="QuotationZonePositionService" inject="QuotationZonePositionService";
	property name="QuotationItemPositionService" inject="QuotationItemPositionService";
	property name="QuotationItemDraftService" inject="QuotationItemDraftService";
	property name="ProductHashService" inject="ProductHashService";

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

			// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
			var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

			// Ricostruisce le righe nell'ordine del find() originale
			for ( var record in records ) {
				if ( StructKeyExists( beanMap, record.quotation_zone_id ) ) {
					rows.add( beanMap[ record.quotation_zone_id ] );
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

	/**
	 * skipItemIds: righe da non copiare ( struct id -> true ), es. quelle con
	 * elementi non più a catalogo ( CatalogUsageService.deletedInQuotation );
	 * quelle effettivamente saltate tornano in skippedItemIds.
	 */
	public function duplicate( required String zoneId, required quotationId, duplicaConSottozone = true, name = null, Struct skipItemIds = {} ) {
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

		// struct: passa per riferimento, duplicateZoneItems ci aggiunge le righe saltate
		var skipped = { "itemIds" = [] };

		transaction {
			messageId = "zone.duplicated";
			thisId    = create( quotationZone )

			if ( !isNull( zoneToDuplicate.getImage() ) ) {
				getFileService().duplicateForZone( zoneToDuplicate.getImage().getId(), thisId );
			}

			var duplicatedZone = duplicateZoneItems( duplicatedZoneId: zoneToDuplicate.getId(), newZoneId: thisId, quotation: quotation, skipItemIds: arguments.skipItemIds, skipped: skipped );
			if (arguments.duplicaConSottozone) {
				var sottozone = list( originId = zoneToDuplicate.getId() )
				for (sottozona in sottozone) {
					var newSottozona = super.bean( "QuotationZone" );
					newSottozona.setQuotation( quotation );
					newSottozona.setName( sottozona.getName() );
					newSottozona.setQuantity( sottozona.getQuantity() );
					newSottozona.setOrigin( duplicatedZone );
					var newSottozonaId = create( newSottozona )
					if ( !isNull( sottozona.getImage() ) ) {
						getFileService().duplicateForZone( sottozona.getImage().getId(), newSottozonaId );
					}
					//in caso di duplica all'interno di un preventivo passare quotation è superfluo, perché sto clonando una zona dentro lo stesso preventivo
					//in caso però di duplica del preventivo (e.g. approvazione preventivo) il preventivo che passo è quello clonato, quindi i nuovi items che creo dentro duplicateZoneItems, porteranno l'id del quotation clonato
					duplicateZoneItems( duplicatedZoneId: sottozona.getId(), newZoneId: newSottozonaId, quotation: quotation, skipItemIds: arguments.skipItemIds, skipped: skipped );
				}
			}
		}

		return { 'messageId': messageId, 'zoneId': thisId, 'skippedItemIds': skipped.itemIds }
	}

	public function duplicateZoneItems( required String duplicatedZoneId, required String newZoneId, required quotation, Struct skipItemIds = {}, Struct skipped = { "itemIds" = [] } ) {
		var items = getQuotationItemService().list( quotationZoneId = arguments.duplicatedZoneId );
		var newZone = getQuotationZoneService().get( arguments.newZoneId )
		// codice posizione -> id della posizione ricreata nella nuova zona (una per codice)
		var newPositionIds = {};

		// Tutti i codici posizione della zona, anche quelli non ancora usati da un articolo
		for ( var zonePosition in getQuotationZonePositionService().list( zoneId = arguments.duplicatedZoneId ) ) {
			if ( IsNull( zonePosition.getCode() ) || !Len( zonePosition.getCode() ) || StructKeyExists( newPositionIds, zonePosition.getCode() ) ) {
				continue;
			}
			var newZonePosition = super.bean( "QuotationZonePosition" );
			newZonePosition.setCode( zonePosition.getCode() );
			newZonePosition.setZoneId( arguments.newZoneId );
			newPositionIds[ zonePosition.getCode() ] = getQuotationZonePositionService().create( newZonePosition );
		}

		// Segnaposto in pianta non ancora configurati
		for ( var draft in getQuotationItemDraftService().listByZone( arguments.duplicatedZoneId ) ) {
			var newDraft = super.bean( "QuotationItemDraft" );
			newDraft.setQuotationId( arguments.quotation.getId() );
			newDraft.setQuotationZoneId( arguments.newZoneId );
			newDraft.setItemType( draft.getItemType() );
			newDraft.setCoordinateX( draft.getCoordinateX() );
			newDraft.setCoordinateY( draft.getCoordinateY() );
			newDraft.setAngle( draft.getAngle() ?: 0 );
			getQuotationItemDraftService().create( newDraft );
		}

		for (var quotationItem in items) {
			if ( StructKeyExists( arguments.skipItemIds, quotationItem.getId() ) ) {
				arguments.skipped.itemIds.append( quotationItem.getId() );
				continue;
			}
			var duplicatedItem = Duplicate( quotationItem );
			duplicatedItem.setQuotationZone( newZone )
			duplicatedItem.setQuotation( quotation )

			// La posizione appartiene alla zona: la copia non può puntare a quella della zona
			// di origine, si ricrea nella nuova zona con lo stesso codice.
			if ( !IsNull( duplicatedItem.getPosition() ) ) {
				var position = duplicatedItem.getPosition();
				if ( Len( position.getCode() ) ) {
					if ( !StructKeyExists( newPositionIds, position.getCode() ) ) {
						var newPosition = super.bean( "QuotationZonePosition" );
						newPosition.setCode( position.getCode() );
						newPosition.setZoneId( arguments.newZoneId );
						newPositionIds[ position.getCode() ] = getQuotationZonePositionService().create( newPosition );
					}
					position.setId( newPositionIds[ position.getCode() ] );
					position.setZoneId( arguments.newZoneId );
				} else {
					duplicatedItem.setPosition( NullValue() );
				}
			}
			var newItemId = getQuotationItemService().create( duplicatedItem );
			var newItem = getQuotationItemService().get( newItemId );

			// Posizionamento in pianta: create() genera una posizione di default (centro, non
			// visibile) per ogni pezzo; le allineo una a una, in ordine, a quelle dell'originale.
			// Ordine numerico per id: la query restituisce l'id come varchar e lo ordinerebbe come testo
			var byNumericId          = function( a, b ){ return Sgn( Val( a.getId() ) - Val( b.getId() ) ); };
			var sourcePlantPositions = getQuotationItemPositionService().list( quotationItemId = quotationItem.getId() );
			var newPlantPositions    = getQuotationItemPositionService().list( quotationItemId = newItemId );
			ArraySort( sourcePlantPositions, byNumericId );
			ArraySort( newPlantPositions, byNumericId );
			for ( var i = 1; i <= Min( ArrayLen( sourcePlantPositions ), ArrayLen( newPlantPositions ) ); i++ ) {
				var plantPosition = newPlantPositions[ i ];
				plantPosition.setCoordinateX( sourcePlantPositions[ i ].getCoordinateX() );
				plantPosition.setCoordinateY( sourcePlantPositions[ i ].getCoordinateY() );
				plantPosition.setVisible( sourcePlantPositions[ i ].getVisible() ?: false );
				plantPosition.setAngle( sourcePlantPositions[ i ].getAngle() ?: 0 );
				plantPosition.setSizeMultiplier( sourcePlantPositions[ i ].getSizeMultiplier() ?: 100 );
				getQuotationItemPositionService().update( plantPosition );
			}

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

			// ricalcola l'hash ora che product items e signage rows sono stati copiati
			if ( isNull( quotationItem.getArticle() ) ) {
				var newHash = getProductHashService().createHash( newItemId );
				if ( !isNull( newHash ) ) {
					getQuotationItemService().updateHash( newItemId, newHash );
				}
			}
		}

		return newZone
	}

	/**
	 * Recupera in batch più QuotationZone dato un array di ID.
	 * Restituisce uno Struct chiave = zoneId, valore = bean QuotationZone.
	 * Precarica Quotation, Origin e File in batch per evitare il problema N+1.
	 *
	 * @ids Array di quotationZoneId
	 * @return Struct mappato per quotationZoneId -> QuotationZone
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti i quotation_id e origin_id per precaricarli in batch
		var quotationIds = [];
		var originIds    = [];

		for ( var record in records ) {
			if ( !IsNull( record.quotation_id ) ) {
				quotationIds.append( record.quotation_id );
			}
			if ( !IsNull( record.origin_id ) ) {
				originIds.append( record.origin_id );
			}
		}

		// Precarica le Quotation in batch con getMany() ottimizzato
		var quotationMap = ArrayLen( quotationIds ) ? getQuotationService().getMany( quotationIds ) : {};

		// Precarica le Origin Zone in batch (self-reference: ricorsione gestita via getMany)
		var originMap = {};
		if ( ArrayLen( originIds ) ) {
			var originRecords = getDao().readByIds( originIds );
			for ( var or in originRecords ) {
				var oBean = super.bean( "QuotationZone" );
				oBean.setId( or.quotation_zone_id );
				oBean.setName( or.quotation_zone );
				oBean.setQuantity( or.quantity );
				originMap[ or.quotation_zone_id ] = oBean;
			}
		}

		// Precarica i File in batch per tutti i zone_id
		var fileMap = getFileService().listByEntityIds( "quotationZone.id", arguments.ids );

		for ( var record in records ) {
			var bean = super.bean( "QuotationZone" );

			// Campi diretti dal record
			bean.setId( record.quotation_zone_id );
			bean.setName( record.quotation_zone );
			bean.setQuantity( record.quantity );

			// Quotation: dalla mappa pre-caricata
			if ( StructKeyExists( quotationMap, record.quotation_id ) ) {
				bean.setQuotation( quotationMap[ record.quotation_id ] );
			}

			// Origin: dalla mappa pre-caricata o NullValue
			if ( !IsNull( record.origin_id ) && StructKeyExists( originMap, record.origin_id ) ) {
				bean.setOrigin( originMap[ record.origin_id ] );
			} else {
				bean.setOrigin( NullValue() );
			}

			// File: dalla mappa pre-caricata (prende il primo come immagine)
			if ( StructKeyExists( fileMap, record.quotation_zone_id ) && ArrayLen( fileMap[ record.quotation_zone_id ] ) ) {
				bean.setImage( fileMap[ record.quotation_zone_id ][ 1 ] );
			}

			map[ record.quotation_zone_id ] = bean;
		}

		return map;
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
