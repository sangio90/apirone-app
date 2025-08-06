component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationDAO";
	property name="quotationSvc" inject="QuotationService";
	property name="quotationItemSvc" inject="QuotationItemService";
	property name="quotationItemProductSvc" inject="QuotationItemProductService";
	property name="quotationItemProductItemSvc" inject="QuotationItemProductItemService";
	property name="quotationItemZoneSvc" inject="QuotationItemZoneService";
	property name="quotationItemPositionSvc" inject="QuotationItemPositionService";
	property name="AccountService" inject="AccountService";
	property name="ProfileService" inject="ProfileService";
	property name="LangService" inject="LangService";
	property name="StatusService" inject="StatusService";
	property name="PricelistService" inject="PricelistService";
	property name="PaymentMethodService" inject="PaymentMethodService";
	property name="CurrencyService" inject="CurrencyService";
	property name="cacheScope" type="String" default="Quotation.bean";

	public com.apirone.core.model.bean.Quotation function get( required String quotationId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.quotationId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.quotationId );
		cm.put( getCacheScope(), arguments.quotationId, bean );

		return bean;
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
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( quotationId = record.quotation_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String quotationId ){
		var outcome = super.bean( "Outcome" );
		var obj     = get( arguments.quotationId );

		outcome.setData( { quotationId = arguments.quotationId } );
		getDao().delete( arguments.quotationId );

		transaction {
			try {
				var cm = getCacheManager();

				getDao().delete( arguments.quotationId );

				cm.remove( getCacheScope(), arguments.quotationId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteQuotation" );
				outcome.setMessage( "Cannot delete quotation [#arguments.quotationId#]" );
			}
		}

		return outcome;
	}

	public String function create( required com.apirone.core.model.bean.Quotation quotation ){
		var newId = getDao().insert( arguments.quotation );

		transaction {
			for ( var text in arguments.quotation.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "quotation.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.quotation.getTexts() );
		}
		return newId;
	}


	public String function update( required com.apirone.core.model.bean.Quotation quotation ){
		getDao().update( arguments.quotation );

		var id = arguments.line.getId();

		for ( var text in arguments.quotation.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "quotation.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation.getId();
	}


	public String function clone(
		required com.apirone.core.model.bean.Quotation quotation,
		required String status
	){
		var originalQuotation = arguments.quotation;
		var clonedQuotation   = Duplicate( originalQuotation );
		originalQuotation.setActive( 0 );
		quotationSvc.update( originalQuotation );
		clonedQuotation.setId( LCase( CreateUUID() ) );
		clonedQuotation.setVersionNumber( originalQuotation.getVersionNumber() + 1 );
		var status = StatusService.get( status );
		clonedQuotation.setStatus( status );

		var newQuotationId = getDao().insert( clonedQuotation );
		var quotationItems = quotationItemSvc.list( quotationId = originalQuotation.getId() );
		for ( var quotationItem in quotationItems ) {
			var clonedItem = Duplicate( quotationItem );
			clonedItem.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedItem.setId( LCase( CreateUUID() ) );
			var newQuotationItemId = quotationItemSvc.create( clonedItem );

			// tutti i prodotti
			var quotationProductItems              = quotationItemProductSvc.list( quotationItemId = quotationItem.getId() );
			// solo i prodotti senza parent
			var quotationItemProductsWithoutParent = ArrayFilter( quotationProductItems, function( quotationItemProduct ){
				return IsNull( quotationItemProduct.getParent() );
			} )
			var quotationItemProductWithoutParentIdsMap = {};

			// ciclo sui prodotti senza parent
			for ( var quotationItemProduct in quotationItemProductsWithoutParent ) {
				var clonedQuotationItemProduct = Duplicate( quotationItemProduct );
				clonedQuotationItemProduct.setId( Javacast( "null", "" ) );
				clonedQuotationItemProduct.setQuotationItem( quotationItemSvc.get( newQuotationItemId ) );
				var newQuotationItemProductId                                           = quotationItemProductSvc.create( clonedQuotationItemProduct );
				clonedQuotationItemProduct                                              = quotationItemProductSvc.get( newQuotationItemProductId );
				// mappo l'id vecchio con l'id nuovo dei prodotti senza parent
				quotationItemProductWithoutParentIdsMap[ quotationItemProduct.getId() ] = newQuotationItemProductId;

				// tutti gli item del prodotto
				var quotationItemProductItems = quotationItemProductItemSvc.list(
					quotationItemProductId = quotationItemProduct.getId()
				);
				// solo gli item senza parent del prodotto
				var quotationItemProductItemsWithoutParent = ArrayFilter( quotationItemProductItems, function( quotationItemProductItem ){
					return IsNull( quotationItemProductItem.getParent() );
				} )
				var quotationItemProductItemsWithoutParentIdsMap = {};

				// ciclo sugli item senza parent del prodotto
				for ( var quotationItemProductItem in quotationItemProductItemsWithoutParent ) {
					var clonedQuotationItemProductItem = Duplicate( quotationItemProductItem );
					clonedQuotationItemProductItem.setId( Javacast( "null", "" ) );
					clonedQuotationItemProductItem.setQuotationItemProduct( clonedQuotationItemProduct );
					var newQuotationItemProductItemId = quotationItemProductItemSvc.create(
						clonedQuotationItemProductItem
					);
					clonedQuotationItemProductItem = quotationItemProductItemSvc.get(
						newQuotationItemProductItemId
					);
					// mappo l'id vecchio con l'id nuovo degli item senza parent
					quotationItemProductItemsWithoutParentIdsMap[ quotationItemProductItem.getId() ] = newQuotationItemProductItemId;
				}

				// solo gli item con parent del prodotto
				var quotationItemProductItemsWithParent = ArrayFilter( quotationItemProductItems, function( quotationItemProductItem ){
					return !IsNull( quotationItemProductItem.getParent() );
				} )

				// ciclo sugli item con parent del prodotto
				for ( var quotationItemProductItem in quotationItemProductItemsWithParent ) {
					var clonedQuotationItemProductItem = Duplicate( quotationItemProductItem );
					clonedQuotationItemProductItem.setId( Javacast( "null", "" ) );
					clonedQuotationItemProductItem.setQuotationItemProduct( clonedQuotationItemProduct );
					// recupero il nuovo id del parent dalla mappa
					var newParentId = quotationItemProductItemsWithoutParentIdsMap[
						quotationItemProductItem.getParent().getId()
					];
					clonedQuotationItemProductItem.setParent( quotationItemProductItemSvc.get( newParentId ) );
					var newQuotationItemProductItemId = quotationItemProductItemSvc.create(
						clonedQuotationItemProductItem
					);
					clonedQuotationItemProductItem = quotationItemProductItemSvc.get(
						newQuotationItemProductItemId
					);
				}
			}

			// solo i prodotti con parent
			var quotationItemProductsWithParent = ArrayFilter( quotationProductItems, function( quotationItemProduct ){
				return !IsNull( quotationItemProduct.getParent() );
			} )

			// ciclo sui prodotti con parent
			for ( var quotationItemProduct in quotationItemProductsWithParent ) {
				var clonedQuotationItemProduct = Duplicate( quotationItemProduct );
				clonedQuotationItemProduct.setId( Javacast( "null", "" ) );
				clonedQuotationItemProduct.setQuotationItem( quotationItemSvc.get( newQuotationItemId ) );
				// recupera il nuovo id del parent dalla mappa
				var newParentId = quotationItemProductWithoutParentIdsMap[ quotationItemProduct.getParent().getId() ];
				clonedQuotationItemProduct.setParent( quotationItemProductSvc.get( newParentId ) );
				var newQuotationItemProductId = quotationItemProductSvc.create( clonedQuotationItemProduct );
				clonedQuotationItemProduct    = quotationItemProductSvc.get( newQuotationItemProductId );

				// tutti gli item del prodotto
				var quotationItemProductItems = quotationItemProductItemSvc.list(
					quotationItemProductId = quotationItemProduct.getId()
				);
				// solo gli item senza parent del prodotto
				var quotationItemProductItemsWithoutParent = ArrayFilter( quotationItemProductItems, function( quotationItemProductItem ){
					return IsNull( quotationItemProductItem.getParent() );
				} )
				var quotationItemProductItemsWithoutParentIdsMap = {};

				// ciclo sugli item senza parent del prodotto
				for ( var quotationItemProductItem in quotationItemProductItemsWithoutParent ) {
					var clonedQuotationItemProductItem = Duplicate( quotationItemProductItem );
					clonedQuotationItemProductItem.setId( Javacast( "null", "" ) );
					clonedQuotationItemProductItem.setQuotationItemProduct( clonedQuotationItemProduct );
					var newQuotationItemProductItemId = quotationItemProductItemSvc.create(
						clonedQuotationItemProductItem
					);
					clonedQuotationItemProductItem = quotationItemProductItemSvc.get(
						newQuotationItemProductItemId
					);
					// mappo l'id vecchio con l'id nuovo degli item senza parent
					quotationItemProductItemsWithoutParentIdsMap[ quotationItemProductItem.getId() ] = newQuotationItemProductItemId;
				}

				// solo gli item con parent del prodotto
				var quotationItemProductItemsWithParent = ArrayFilter( quotationItemProductItems, function( quotationItemProductItem ){
					return !IsNull( quotationItemProductItem.getParent() );
				} )

				// ciclo sugli item con parent del prodotto
				for ( var quotationItemProductItem in quotationItemProductItemsWithParent ) {
					var clonedQuotationItemProductItem = Duplicate( quotationItemProductItem );
					clonedQuotationItemProductItem.setId( Javacast( "null", "" ) );
					clonedQuotationItemProductItem.setQuotationItemProduct( clonedQuotationItemProduct );
					// recupero il nuovo id del parent dalla mappa
					var newParentId = quotationItemProductItemsWithoutParentIdsMap[
						quotationItemProductItem.getParent().getId()
					];
					clonedQuotationItemProductItem.setParent( quotationItemProductItemSvc.get( newParentId ) );
					var newQuotationItemProductItemId = quotationItemProductItemSvc.create(
						clonedQuotationItemProductItem
					);
					clonedQuotationItemProductItem = quotationItemProductItemSvc.get(
						newQuotationItemProductItemId
					);
				}
			}

			// tutte le zone
			var quotationItemZones              = quotationItemZoneSvc.list( quotationItemId = quotationItem.getId() );
			// solo le zone senza parent
			var quotationItemZonesWithoutParent = ArrayFilter( quotationItemZones, function( quotationItemZone ){
				return IsNull( quotationItemZone.getParent() );
			} )
			var quotationZoneIdsMap = {};
			for ( var quotationItemZone in quotationItemZonesWithoutParent ) {
				var clonedQuotationItemZone = Duplicate( quotationItemZone );
				clonedQuotationItemZone.setId( Javacast( "null", "" ) );
				clonedQuotationItemZone.setQuotationItem( quotationItemSvc.get( newQuotationItemId ) );
				var newQuotationItemZoneId                       = quotationItemZoneSvc.create( clonedQuotationItemZone );
				clonedQuotationItemZone                          = quotationItemZoneSvc.get( newQuotationItemZoneId );
				// mappo l'id vecchio con l'id nuovo delle zone senza parent
				quotationZoneIdsMap[ quotationItemZone.getId() ] = newQuotationItemZoneId;

				// clona le positions
				var quotationItemPositions = quotationItemPositionSvc.list( zoneId = quotationItemZone.getId() );
				for ( quotationItemPosition in quotationItemPositions ) {
					var clonedQuotationItemPosition = Duplicate( quotationItemPosition );
					clonedQuotationItemPosition.setQuotationItemZone( clonedQuotationItemZone );
					quotationItemPositionSvc.create( clonedQuotationItemPosition );
				}
			}

			// solo le zone con parent
			var quotationItemZonesWithParent = ArrayFilter( quotationItemZones, function( quotationItemZone ){
				return !IsNull( quotationItemZone.getParent() );
			} )
			for ( var quotationItemZone in quotationItemZonesWithParent ) {
				var clonedQuotationItemZone = Duplicate( quotationItemZone );
				clonedQuotationItemZone.setId( Javacast( "null", "" ) );
				clonedQuotationItemZone.setQuotationItem( quotationItemSvc.get( newQuotationItemId ) );
				// recupera il nuovo id del parent dalla mappa
				var newParentId = quotationZoneIdsMap[ quotationItemZone.getParent().getId() ];
				clonedQuotationItemZone.setParent( quotationItemZoneSvc.get( newParentId ) );
				var newQuotationItemZoneId = quotationItemZoneSvc.create( clonedQuotationItemZone );
				clonedQuotationItemZone    = quotationItemZoneSvc.get( newQuotationItemZoneId );

				// clona le positions
				var quotationItemPositions = quotationItemPositionSvc.list( zoneId = quotationItemZone.getId() );
				for ( quotationItemPosition in quotationItemPositions ) {
					var clonedQuotationItemPosition = Duplicate( quotationItemPosition );
					clonedQuotationItemPosition.setQuotationItemZone( clonedQuotationItemZone );
					quotationItemPositionSvc.create( clonedQuotationItemPosition );
				}
			}
		}

		return newQuotationId;
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation;
	}


	/*
		private method
	*/

	private com.apirone.core.model.bean.Quotation function build( required String quotationId ){
		var record = getDao().read( arguments.quotationId );

		if ( record.recordCount ) {
			var bean = super.bean( "Quotation" );

			bean.setId( record.quotation_id );
			bean.setDescription( record.description );
			bean.setQuotationNumber( record.quotation_number );
			bean.setVersionNumber( record.version_number );
			bean.setQuotationDate( record.quotation_date );
			bean.setNotes( record.notes );
			bean.setValidityDate( record.validity_date );
			bean.setOpportunityName( record.opportunity_name );
			bean.setLeadName( record.lead_name );
			bean.setActive( record.active );
			bean.setCustomPaymentMethod( record.custom_payment_method );

			bean.setPricelist( getPricelistService().get( record.pricelist_id ) );
			bean.setPaymentMethod( getPaymentMethodService().get( record.payment_method_id ) );
			bean.setCurrency( getCurrencyService().get( record.currency_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setLang( getLangService().get( record.lang_id ) );
			bean.setBillingProfile( getProfileService().get( record.billing_profile_id ) );
			bean.setShippingProfile( getProfileService().get( record.shipping_profile_id ) );
			bean.setSalesAgentAccount( getAccountService().get( record.sales_agent_account_id ) );
			bean.setGraphicTechnicianAccount( getAccountService().get( record.graphic_technician_account_id ) );
			bean.setTexts( getTextService().list( quotationId = record.quotation_id ) );

			return bean;
		}

		return NullValue();
	}

}
