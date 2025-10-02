/*
	var api = new AbsRestApi().init(
		baseUrl = "https://api.example.com",
		authToken = "my-secret-token"
	);

	// URL risultante: https://api.example.com/users?authToken=my-secret-token
	var users = api.get("/users");


	var api = new AbsRestApi().init(
		baseUrl = "https://api.example.com",
		apiKey = "my-key",
		defaultHeaders = { "User-Agent": "MyApp" }
	);

	// GET con params
	var users = api.get("/users", { limit: 10 });

	// POST con data
	var newUser = api.post("/users", { name: "Mario", email: "mario@example.com" });
*/

component extends="AbsRestApi" accessors="true" {

	/**
	 * Inizializza con URL CRM e token
	 */
	public CrmApiService function init(){
		super.init(
			baseUrl        = "http://api.test-crm.apirone.cc/api",
			authToken      = getAuthToken(),
			defaultHeaders = { "Accept" = "application/json" }
		);
		return this;
	}

	/**
	 * Recupera dati cliente dal CRM via API
	 */
	public struct function getCustomer( required string customerId ){
		return get( "/accounts/#customerId#" );
	}

	/**
	 * Cerca clienti nel CRM
	 */
	public array function searchCustomers( required string str ){
		return get( "/accounts", { search = str } );
	}

	/**
	 * Metodo privato per ottenere il token auth
	 */
	private string function getAuthToken(){
		return "c39bbed0-f211-46e7-8644-6d290dd00cd1";
	}

}
