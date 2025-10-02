component extends="com.apirone.core.model.mapper.AbsMapper" accessors="true" {

	property name="statusService" inject="StatusService";

	/**
	 * Mappa dati cliente CRM su bean Customer interno
	 */
	public com.apirone.core.model.bean.Customer function mapCustomer( required struct data ){
		var customer = new com.apirone.core.model.bean.Customer();
		var accountCustom = data.custom;
		customer.setName( data.name ?: "" );
		customer.setDescription( data.description ?: "" );
		if (Len(accountCustom)) {
			customer.setCompany( accountCustom.ragione_sociale_c ?: "" );
			customer.setVatNumber( accountCustom.partita_iva_c ?: "" );
			customer.setSDI( accountCustom.sdi_c ?: "" );
			customer.setPhoneCell( accountCustom.phone_cell_c ?: "" );
		}
		customer.setPhone( data.phone_office ?: data.phone_alternate ?: "" );
		customer.setStreet( data.billing_address_street ?: "" );
		customer.setPostalCode( data.billing_address_postalcode ?: "" );
		customer.setCity( data.billing_address_city ?: "" );
		customer.setState( data.billing_address_state ?: "" );
		customer.setCountry( data.billing_address_country ?: "" );

		return customer;
	}

}
