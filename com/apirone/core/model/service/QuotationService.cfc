component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationDAO";
	property name="quotationSvc" inject="QuotationService";
	property name="quotationItemSvc" inject="QuotationItemService";
	property name="quotationItemProductSvc" inject="QuotationItemProductService";
	property name="quotationItemProductItemSvc" inject="QuotationItemProductItemService";
	property name="quotationZoneSvc" inject="QuotationZoneService";
	property name="quotationItemPositionSvc" inject="QuotationItemPositionService";
	property name="quotationItemSignageRowSvc" inject="QuotationItemSignageRowService";
	property name="AccountService" inject="AccountService";
	property name="ProfileService" inject="ProfileService";
	property name="LangService" inject="LangService";
	property name="StatusService" inject="StatusService";
	property name="PricelistService" inject="PricelistService";
	property name="PaymentMethodService" inject="PaymentMethodService";
	property name="CurrencyService" inject="CurrencyService";
	property name="CustomerService" inject="CustomerService";
	property name="OpportunityService" inject="OpportunityService";
	property name="LeadService" inject="LeadService";
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

		return newId;
	}


	public String function update( required com.apirone.core.model.bean.Quotation quotation ){
		getDao().update( arguments.quotation );
		super.getCacheManager().remove( getCacheScope(), arguments.quotation.getId() );

		return arguments.quotation.getId();
	}


	public String function export( required com.apirone.core.model.bean.QuotationItem[] quotationItems ){
		var success = false;
		if (arguments.quotationItems.len() > 0) {
			for ( var quotationItem in arguments.quotationItems ) {
				var code = "";
				var product = quotationItem.getProduct()
				if (IsNull(product) || IsNull(product.getCategory())) {
					return false;
				}
				var categoryCode = Trim( product.getCategory().getCode() );
				code &= categoryCode;
				if (IsInstanceOf( product, "com.apirone.core.model.bean.ProductComplex" )) {
					if (isNull(product.getLine())) {
						return false;
					}
					var line = product.getLine();
					var lineCode = Trim( line.getCode() );

					code &= lineCode;
					
					if (isNull(product.getModel())) {
						return false;
					}
					var model = product.getModel();
					code &= Trim(model.getCode());
					
					if (isNull(product.getFinish())){ 
						return false;
					}
					var finishCode = Trim( product.getFinish().getCode() );
					code &= finishCode;

					var description = "#product.getLine().getName()# #product.getModel().getName()# (#model.getCode()#) #product.getFinish().getName()#"
					description = description.subString(0, 35);
					var data = {
						'AR_CHIAVE': code,
						'ARCODART': code,
						'ARDESART': description,
						'ARDATCAR': Now(),
						'ARUNMIS1': 'PZ'
					}
					success = getDao().export( data );
				}
				if (IsInstanceOf( product, "com.apirone.core.model.bean.ProductBase" )) {
					var data = {
						'AR_CHIAVE': product.getCode(),
						'ARCODART': product.getCode(),
						'ARDESART': product.getName(),
						'ARDATCAR': Now(),
						'ARUNMIS1': 'PZ'
					}
					success = getDao().export( data );
				}
				// var newId = getDao().export( arguments.quotationItems );
			}
		}

		return success;
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
		clonedQuotation.setActive( 1 );
		var status = StatusService.get( status );
		clonedQuotation.setStatus( status );

		var newQuotationId = getDao().insert( clonedQuotation );

		var quotationZoneIdsMap         = {};
		var quotationZones              = quotationZoneSvc.list( quotationId = originalQuotation.getId() );
		var quotationZonesWithoutParent = ArrayFilter( quotationZones, function( quotationZone ){
			return IsNull( quotationZone.getOrigin() );
		} )
		for ( var quotationZone in quotationZonesWithoutParent ) {
			var clonedZone = Duplicate( quotationZone );
			clonedZone.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedZone.setId( LCase( CreateUUID() ) );
			var newQuotationZoneId                       = quotationZoneSvc.create( clonedZone );
			quotationZoneIdsMap[ quotationZone.getId() ] = newQuotationZoneId;
		}

		var quotationZonesWithParent = ArrayFilter( quotationZones, function( quotationZone ){
			return !IsNull( quotationZone.getOrigin() );
		} )
		for ( var quotationZone in quotationZonesWithParent ) {
			var clonedZone = Duplicate( quotationZone );
			clonedZone.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedZone.setId( LCase( CreateUUID() ) );
			var newOriginId = quotationZoneIdsMap[ quotationZone.getOrigin().getId() ];
			clonedZone.setOrigin( quotationZoneSvc.get( newOriginId ) );
			var newQuotationZoneId                       = quotationZoneSvc.create( clonedZone );
			quotationZoneIdsMap[ quotationZone.getId() ] = newQuotationZoneId;
		}

		var quotationItems = quotationItemSvc.list( quotationId = originalQuotation.getId() );
		for ( var quotationItem in quotationItems ) {
			var clonedItem = Duplicate( quotationItem );
			clonedItem.setQuotation( quotationSvc.get( newQuotationId ) );
			clonedItem.setQuotationZone(
				quotationZoneSvc.get( quotationZoneIdsMap[ quotationItem.getQuotationZone().getId() ] )
			);
			clonedItem.setId( LCase( CreateUUID() ) );
			var newQuotationItemId = quotationItemSvc.create( clonedItem );

			var quotationItemSignageRows = quotationItemSignageRowSvc.list(
				quotationItemId = quotationItem.getId()
			);
			for ( quotationItemSignageRow in quotationItemSignageRows ) {
				var clonedQuotationItemSignageRow = Duplicate( quotationItemSignageRow );
				clonedQuotationItemSignageRow.setQuotationItemId( newQuotationItemId );
				quotationItemSignageRowSvc.create( clonedQuotationItemSignageRow );
			}

			var quotationItemPositions = quotationItemPositionSvc.list( quotationItemId = quotationItem.getId() );
			for ( quotationItemPosition in quotationItemPositions ) {
				var clonedQuotationItemPosition = Duplicate( quotationItemPosition );
				clonedQuotationItemPosition.setQuotationItem( clonedItem );
				clonedQuotationItemPosition.setQuotationZone(
					quotationZoneSvc.get( quotationZoneIdsMap[ quotationItem.getQuotationZone().getId() ] )
				);
				quotationItemPositionSvc.create( clonedQuotationItemPosition );
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
			bean.setName( record.quotation );
			bean.setQuotationNumber( record.quotation_number );
			bean.setVersionNumber( record.version_number );
			bean.setQuotationDate( record.quotation_date );
			bean.setNotes( record.notes );
			bean.setValidityDate( record.validity_date );
			if (!isNull(record.opportunity_id)) {
				bean.setOpportunity( getOpportunityService().get( record.opportunity_id ) );
			}
			if (!isNull(record.lead_id)) {
				bean.setLead( getLeadService().get( record.lead_id ) );
			}
			if (!isNull(record.customer_id)) {
				bean.setCustomer( getCustomerService().get( record.customer_id ) );
			}
			if (!isNull(record.customer_address_id)) {
				bean.setCustomerAddressId( record.customer_address_id );
			}
			bean.setActive( record.active );
			bean.setCustomPaymentMethod( record.custom_payment_method );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setLang( getLangService().get( record.lang_id ) );

			// bean.setPricelist( getPricelistService().get( record.pricelist_id ) );
			// bean.setPaymentMethod( getPaymentMethodService().get( record.payment_method_id ) );
			// bean.setCurrency( getCurrencyService().get( record.currency_id ) );
			// bean.setBillingProfile( getProfileService().get( record.billing_profile_id ) );
			// bean.setShippingProfile( getProfileService().get( record.shipping_profile_id ) );
			// bean.setSalesAgentAccount( getAccountService().get( record.sales_agent_account_id ) );
			// bean.setGraphicTechnicianAccount( getAccountService().get( record.graphic_technician_account_id ) );

			return bean;
		}

		return NullValue();
	}

}
