// models/MenuService.cfc
component accessors=true {

	property name="router" inject="router@coldbox";
	property name="event" inject="coldbox:requestContext";

	/**
	 * Estrae le rotte reali e i permessi ESCLUSIVAMENTE dal modulo 'manager',
	 * ricostruendo l'URL completo (es. /manager/dashboard) per il matching con il menu.
	 * @return struct Una mappa { URL completo: [permesso1, permesso2], ... }
	 */
	private struct function getRoutePermissionMap(){
		var routeMap = {};

		// Accediamo solo alle rotte del modulo 'manager'
		var routes = StructKeyExists( router.getmoduleRoutingTable(), "manager" )
		 ? router.getmoduleRoutingTable()[ "manager" ]
		 : [];

		// Definiamo il prefisso del modulo da anteporre
		var modulePrefix = "/manager";

		if ( ArrayLen( routes ) ) {
			for ( var route in routes ) {
				var permissions = StructKeyExists( route.prc, "permissions" )
				 ? ListToArray( route.prc.permissions ) : []; // "viewRead,viewDashboard" as array
				var routePattern = route.pattern;
				var fullURL      = routePattern;

				// Se il pattern non inizia con /, assumiamo che sia relativo al modulo
				if ( !Len( routePattern ) || Left( routePattern, 1 ) != "/" ) {
					// Unisci il prefisso con il pattern. Rimuovi lo / iniziale se c'è
					fullURL = modulePrefix & "/" & routePattern;
				}
				// Pulizia finale (es. /manager//dashboard -> /manager/dashboard)
				fullURL = Replace( fullURL, "//", "/", "all" );
				fullURL = ReReplace( fullURL, "/+$", "", "all" ); // tolgo "/" alla fine della stringa

				// Mappa l'URL COMPLETO ai suoi permessi richiesti
				routeMap[ fullURL ] = permissions;
			}
		}
		return routeMap;
	}

	/**
	 * Funzione principale per costruire il menu gerarchico.
	 */
	public array function getMenuStructure(){
		var prc                = event.getPrivateCollection();
		var userPermissions    = prc.userPermissions ?: [];
		// Carica la struttura gerarchica dal file (Assumendo menu.json.cfm)
		var menuData           = DeserializeJSON( FileRead( ExpandPath( "/config/data/menu.json.cfm" ) ) );
		var routePermissionMap = getRoutePermissionMap();

		// Chiama la funzione di filtraggio ricorsiva
		return filterMenu(
			menuItems          = menuData,
			userPermissions    = userPermissions,
			routePermissionMap = routePermissionMap
		);
	}

	/**
	 * Filtra ricorsivamente gli elementi del menu in base ai permessi.
	 */
	private array function filterMenu(
		required array menuItems,
		required array userPermissions,
		required struct routePermissionMap
	){
		var filteredItems = [];

		for ( var row in arguments.menuItems ) {
			var itemIsPermitted     = false;
			var requiredPermissions = [];
			var hasSubmenu          = StructKeyExists( row, "items" ) AND ArrayLen( row.items ) GT 0;

			// 1. DETERMINAZIONE DEI PERMESSI RICHIESTI
			if ( StructKeyExists( routePermissionMap, row.href ) ) {
				// È una rotta ColdBox reale: usa i permessi dal Router.
				requiredPermissions = routePermissionMap[ row.href ];
			}

			if ( ArrayLen( requiredPermissions ) > 0 ) {
				// Gestione del permesso speciale "all"
				if ( ArrayFind( requiredPermissions, "all" ) ) {
					itemIsPermitted = true;
				} else {
					// Controlla la logica OR: l'utente ha almeno uno dei permessi richiesti.
					for ( var requiredPerm in requiredPermissions ) {
						if ( ArrayFind( arguments.userPermissions, requiredPerm ) ) {
							itemIsPermitted = true;
							break;
						}
					}
				}
			}

			// 3. GESTIONE RICORSIVA DEI SOTTOMENU (Il cuore del contenitore)
			if ( hasSubmenu ) {
				var filteredSubmenu = filterMenu(
					menuItems          = row.items,
					userPermissions    = arguments.userPermissions,
					routePermissionMap = arguments.routePermissionMap
				);

				// SOSTITUISCI il sottomenu originale con quello filtrato
				row.items = filteredSubmenu;

				// Un contenitore è permesso se ha dei figli validi (anche se non aveva permessi diretti)
				if ( ArrayLen( row.items ) > 0 ) {
					itemIsPermitted = true;
				}
			}

			// 4. AGGIUNGI L'ITEM FILTRATO
			if ( itemIsPermitted ) {
				ArrayAppend( filteredItems, row );
			}
		}

		return filteredItems;
	}

}
