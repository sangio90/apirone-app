component extends="com.apirone.core.model.service.AbsMapper" accessors="true" {

	property name="statusService" inject="StatusService";

	/**
	 * Mappa dati cliente CRM su bean Customer interno
	 */
	public com.apirone.core.model.bean.Customer function mapCrmCustomerToBean(required struct crmData) {
		var customer = new com.apirone.core.model.bean.Customer();

		// Mapping campi diretti
		customer.setName(crmData.name ?: "");
		customer.setEmail(crmData.email ?: "");
		customer.setPhone(crmData.phone ?: "");

		// Mapping indirizzo (assumi che CRM abbia un oggetto address)
		if (structKeyExists(crmData, "address")) {
			var address = crmData.address;
			customer.setStreet(address.street ?: "");
			customer.setCity(address.city ?: "");
			customer.setZipCode(address.zip ?: "");
			customer.setCountry(address.country ?: "IT"); // Default Italia
		}

		// Validazione e sanitizzazione
		if (!isValid("email", customer.getEmail())) {
			throw(type="ValidationError", message="Email CRM non valida: #customer.getEmail()#");
		}

		if (len(customer.getName()) == 0) {
			customer.setName("Cliente CRM #crmData.id#"); // Fallback
		}

		// Altri campi...
		customer.setCrmId(crmData.id); // Salva ID CRM per riferimento
		customer.setStatus(statusService.get("ACT")); // Assumi status attivo di default

		return customer;
	}

}