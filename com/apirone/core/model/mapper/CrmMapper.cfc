component extends="com.apirone.core.model.mapper.AbsMapper" accessors="true" {

	property name="statusService" inject="StatusService";
	property name="countryService" inject="CountryService";
	property name="lookupService" inject="LookupService";

	/**
	 * Mappa dati cliente CRM su bean Customer interno
	 */
	public com.apirone.core.model.bean.Customer function mapCustomer( required struct data ){
		var customer = super.bean("Customer");
		var accountCustom = data.custom;

		customer.setId( data.id );
		customer.setName( data.name ?: "" );
		customer.setDescription( data.description ?: "" );

		var country = null;

		if (Len(accountCustom)) {
			customer.setCompany( accountCustom.ragione_sociale_c ?: "" );
			customer.setVatNumber( accountCustom.partita_iva_c ?: "" );
			customer.setSDI( accountCustom.sdi_c ?: "" );
			customer.setPhone( accountCustom.phone_cell_c ?: "" );
			country = accountCustom.assignablecountry_c;
			customer.setLingua( accountCustom.lingua_c ?: "" );
		}

		customer.setRagioneSociale( data.ragione_sociale_c ?: customer.getCompany() ?: "" );

		customer.setPhone( data.phone_office ?: data.phone_alternate ?: "" );
		customer.setStreet( data.billing_address_street ?: "" );
		customer.setPostalCode( data.billing_address_postalcode ?: "" );
		customer.setCity( data.billing_address_city ?: "" );
		customer.setState( data.billing_address_state ?: "" );

		if ( !IsNull( country ) && Len( Trim(country) ) ) {
			country = getCountryService().get( Trim(country) );
			customer.setCountry( country );
		}

		var accountAddresses = data.indirizzi_spedizione;

		if (Len( accountAddresses ) ) {

			var addressesList = [];

			for( var thisAddress in accountAddresses ) {
				var address = mapAddress( thisAddress );
				addressesList.add( address );
			}

			customer.setShippingProfiles( addressesList );
		}

		customer.setContactPersonName(data.referente_nome ?: "");
		customer.setContactPersonEmail(data.referente_email ?: "");
		customer.setAccountType( data.account_type ?: "" );
		customer.setIndustry( data.industry ?: "" );

		return customer;
	}

	public com.apirone.core.model.bean.Opportunity function mapOpportunity( required struct data ){
		var opportunity = super.bean("Opportunity");

		opportunity.setId( data.id );
		opportunity.setName( data.name ?: "" );
		opportunity.setDescription( data.description ?: "" );

		return opportunity;
	}

	public com.apirone.core.model.bean.Lead function mapLead( required struct data ){
		var lead = super.bean("Lead");

		lead.setId( data.id );
		lead.setFirstName( data.first_name ?: "" );
		lead.setLastName( data.last_name ?: "" );
		lead.setDescription( data.description ?: "" );

		return lead;
	}

	public com.apirone.core.model.bean.ShippingProfile function mapAddress( required struct data ){
		var type = super.bean("ProfileType");
		var bean = super.bean("ShippingProfile");

		/*
  			7 keys:
			id, name, via, citta, provincia, cap, paese
		*/

		var country = getCountryService().get( Trim( data.paese ) );

		if( IsNull( country ) ) {
			getLogger().error( "CrmMapping. Country code [#data.paese#] not found for address id [#data.id#]." );
		}

		bean.setId( data.id );
		bean.setCompany( data.name );  //"name" is shorthand
		bean.setFirstName( "" );
		bean.setLastName( "" );
		bean.setVatNumber( "" );
		bean.setEmail( "" );
		bean.setPhone( "" );
		if ( !IsNull( country ) ) {
			bean.setCountry( country );
		}
		bean.setState( data.provincia ?: "" );
		bean.setCity( data.citta ?: "" );
		bean.setPostalCode( data.cap ?: "" );
		bean.setStreet( data.via ?: "" );
		//bean.setType( getLookupService().get( "profileType", "S" ) );

		return bean;
	}

}
