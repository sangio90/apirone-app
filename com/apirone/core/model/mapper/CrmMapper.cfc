component extends="com.apirone.core.model.service.AbsMapper" accessors="true" {

	property name="statusService" inject="StatusService";

	/**
	 * Mappa dati cliente CRM su bean Customer interno
	 */
	public com.apirone.core.model.bean.Customer function mapCustomer( required struct data ){
		var customer = new com.apirone.core.model.bean.Customer();

		// Mapping campi diretti
		customer.setName( data.name ?: "" );
		customer.setEmail( data.email ?: "" );
		customer.setPhone( data.phone ?: "" );

		// Mapping indirizzo (assumi che CRM abbia un oggetto address)
		if ( StructKeyExists( data, "address" ) ) {
			var address = data.address;
			customer.setStreet( address.street ?: "" );
			customer.setCity( address.city ?: "" );
			customer.setZipCode( address.zip ?: "" );
			customer.setCountry( address.country ?: "IT" ); // Default Italia
		}

		// Validazione e sanitizzazione
		if ( !IsValid( "email", customer.getEmail() ) ) {
			Throw( type = "ValidationError", message = "Email CRM non valida: #customer.getEmail()#" );
		}

		if ( Len( customer.getName() ) == 0 ) {
			customer.setName( "Cliente CRM #data.id#" ); // Fallback
		}

		// Altri campi...
		customer.setCrmId( data.id ); // Salva ID CRM per riferimento
		customer.setStatus( statusService.get( "ACT" ) ); // Assumi status attivo di default

		return customer;
	}

}
