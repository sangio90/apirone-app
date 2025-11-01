component accessors="true" extends="AbsBean" {

	property name="role" type="com.apirone.core.model.bean.Role";
	property name="account" type="com.apirone.core.model.bean.Account";

	public User function init(){
		setId( "ANONYMOUS" );

		return this;
	}

	public Boolean function isLogged(){
		return getId() != "ANONYMOUS";
	}

	public boolean function hasPermission( required string permissionId ){
		// 1. Blocco Esplicito (Permesso Fittizio):
		// Se il permesso richiesto è il marcatore di blocco, L'ADM DEVE essere trattato come un utente normale (e fallire).
		if ( arguments.permissionId == "DENY_BY_DEFAULT_ACCESS" ) {
			// Non permettere all'ADM di superare questo controllo fittizio.
			// Lo stato dell'ADM sarà gestito dal punto 2, ma questo DEVE fallire.
			return false;
		}

		// 2. Superpotere per l'Amministratore (Permessi Reali):
		if ( getRole().getId() == "ADM" ) {
			// L'ADM ha accesso a TUTTI i permessi reali (CREATE_PRODUCT, etc.)
			return true;
		}

		// 3. Logica per AUTHENTICATED e Permessi Standard (se non è ADM)
		if ( arguments.permissionId == "AUTHENTICATED" ) {
			return isLogged();
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
