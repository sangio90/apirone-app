component accessors="true" extends="AbsBean" {

	property name="role" type="com.apirone.core.model.bean.Role";
	property name="account" type="com.apirone.core.model.bean.Account";

	public User function init(){
		setId( "ANONYMOUS" );

		return this;
	}

	public Booleans function isLogged(){
		return getId() != "ANONYMOUS";
	}

	public Booleans function hasPermission( required String permissionId ){
		// 1. Blocco Esplicito (Permesso Fittizio):
		// Se il permesso richiesto è il marcatore di blocco, L'ADM DEVE essere trattato come un utente normale (e fallire).
		// Viene impostato "DENY_ALL" se la rotta non esiste.
		if ( arguments.permissionId == "DENY_ALL" ) {
			return false;
		}

		// 2. Logica per AUTHENTICATED e Permessi Standard (se non è ADM)
		if ( arguments.permissionId == "AUTHENTICATED" ) {
			return isLogged(); // Ritorna true o false per tutti gli utenti
		}

		// 1. Superpotere per l'Amministratore (Permessi Reali):
		// Nota: L'ADM è già stato gestito per DENY_ALL e AUTHENTICATED
		if ( getRole().getId() == "ADM" ) {
			return true;
		}

		var rolePermissions = getRole().getPermissions();

		for ( var rolePermission in rolePermissions ) {
			if ( rolePermission.getPermission().getId() == permissionId ) {
				return true;
			}
		}

		return false;
	}

}
