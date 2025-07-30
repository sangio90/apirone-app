component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationDAO";
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
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "quotation.id" } ]
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
		var obj = get( arguments.quotationId );
		
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


	/*
		private method
	*/

	private com.apirone.core.model.bean.Quotation function build(required String quotationId) {
		var record = getDao().read( arguments.quotationId );

		if (record.recordCount) {
			var bean = super.bean( "Quotation" );

			bean.setId( record.quotation_id );
			bean.setDescription( record.description );
			bean.setQuotationNumber( record.quotation_number );
			bean.setQuotationDate( record.quotation_date );
			bean.setNotes( record.notes );
			bean.setValidityDate( record.validity_date );
			bean.setOpportunityName( record.opportunity_name );
			bean.setLeadName( record.lead_name );
			bean.setCustomPaymentMethod( record.custom_payment_method );

			bean.setPricelist( 
				getPricelistService().get( record.pricelist_id ) 
			);
			bean.setPaymentMethod( 
				getPaymentMethodService().get( record.payment_method_id )
			);
			bean.setCurrency( 
				getCurrencyService().get( record.currency_id )
			);
			bean.setStatus(
				getStatusService().get( record.status_id )
			);
			bean.setLang(
				getLangService().get( record.lang_id )
			);
			bean.setBillingProfile(
				getProfileService().get( record.billing_profile_id )
			);
			bean.setShippingProfile(
				getProfileService().get( record.shipping_profile_id )
			);
			bean.setSalesAgentAccount(
				getAccountService().get( record.sales_agent_account_id )
			);
			bean.setGraphicTechnicianAccount(
				getAccountService().get( record.graphic_technician_account_id )
			);

			return bean;
		}

		return NullValue();
	}
}
