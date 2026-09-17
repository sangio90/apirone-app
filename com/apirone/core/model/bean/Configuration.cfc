component output="true" accessors="true" {

	property name="keys" type="Struct";

	public Configuration function init(){
		var settings = new config.Settings();
		var gitRevision = getGitRevision();

		var keys = {
			"appName"    = settings.get( "app.name" ),
			"appVersion" = settings.get( "app.version" ),
			// Revisione git del deploy corrente (letta una volta sola qui, non ad ogni
			// richiesta: questo bean è un singleton WireBox). Serve a distinguere al volo,
			// nell'header, se un utente che segnala un bug sta vedendo l'ultima versione
			// rilasciata - senza dover impostare a mano una env var ad ogni deploy.
			"gitRevision"     = gitRevision.sha,
			"gitRevisionDate" = gitRevision.deployedAt,
			"owner"      = {
				"name"  = settings.get( "owner.name" ),
				"vat"   = settings.get( "owner.vat" ),
				"email" = settings.get( "owner.email" )
			},
			"font" = {
				"directory" = { "prefix" = settings.get( "font.prefix" ) }
			},
			"filesHost"    = "#settings.get( "files.host" )#",
			// griglia incisioni frutti: codici degli attributi "radice" dell'incisione, in ordine
			// di priorità risalendo l'albero (superiore, inferiore, logo)
			"engravingRootAttributeCodes" = [ "IS", "II", "IL" ],
			// attributi che portano il simbolo inciso (il valore che si posiziona sulla griglia)
			"engravingSymbolAttributeCodes" = [ "SM" ],
			// lato del riquadro del simbolo inciso, in mm: usato per disegnarlo in scala
			// sull'anteprima della placca e nelle stampe
			"engravingSymbolSizeMm" = 10,
			"imagesConfig" = {
				"productItem" = {
					"path"  = "product-items",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"product" = {
					"path"  = "products",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"combination" = {
					"path"  = "combinations",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"combinationItem" = {
					"path"  = "combination-items",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"attributeValue" = {
					"path"  = "attribute-values",
					"types" = {
						"horizontal" = { "sizes" = [ { "width" = "500" } ] },
						"vertical"   = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"quotationItem" = {
					"path"  = "quotation-items",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"quotationZone" = {
					"path"  = "quotation-zones",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
				"pictogram" = {
					"path"  = "pictograms",
					"types" = {
						"default" = { "sizes" = [] }
					}
				},
				"quotationStatusHistory" = {
					"path"  = "quotation-status-history",
					"types" = {
						"default" = { "sizes" = [ { "width" = "500" } ] }
					}
				},
			},
			"encryptKey" = settings.get( "db.encryptKey" )
		};

		setKeys( keys );

		return this;
	}

	public Any function get( required String path = "" ){
		if ( Len( arguments.path ) ) {
			var keys = getkeys();

			return StructGet( "keys.#arguments.path#" );
		}

		return getKeys();
	}

	/*
		Legge lo SHA corto e la data dell'ultimo aggiornamento del branch attualmente
		deployato, direttamente dai file di .git (niente cfexecute/git, niente env var da
		impostare ad ogni deploy: basta il "git pull" già fatto da deploy.sh/release.sh).
		deployedAt è il mtime del file ref (o di HEAD in stato detached): approssima
		l'istante dell'ultimo "git pull" in quella cartella, non la data del commit.
		Silenzioso su qualunque errore: è solo un'informazione diagnostica, non deve mai
		impedire l'avvio dell'app (es. deploy senza cartella .git, permessi, ecc.).
	*/
	private Struct function getGitRevision(){
		var result = { "sha" = "", "deployedAt" = "" };

		try {
			var gitDir = ExpandPath( "/.git" );
			if ( !DirectoryExists( gitDir ) ) {
				return result;
			}

			var headPath = gitDir & "/HEAD";
			if ( !FileExists( headPath ) ) {
				return result;
			}

			var head = Trim( FileRead( headPath ) );

			if ( Left( head, 5 ) == "ref: " ) {
				var refFile = gitDir & "/" & Trim( Mid( head, 6, Len( head ) ) );

				if ( FileExists( refFile ) ) {
					result.sha        = Left( Trim( FileRead( refFile ) ), 7 );
					result.deployedAt = DateTimeFormat( GetFileInfo( refFile ).lastmodified, "dd/mm/yyyy HH:nn" );
				} else {
					// Ref "impacchettato" da una git gc: niente file sciolto in refs/heads,
					// va cercato nella lista di packed-refs.
					var packedRefsPath = gitDir & "/packed-refs";
					var refName = Trim( Mid( head, 6, Len( head ) ) );

					if ( FileExists( packedRefsPath ) ) {
						for ( var line in ListToArray( FileRead( packedRefsPath ), Chr( 10 ) ) ) {
							line = Trim( line );
							if ( Len( line ) && Left( line, 1 ) != "##" && Left( line, 1 ) != "^" && Right( line, Len( refName ) ) == refName ) {
								result.sha        = Left( ListFirst( line, " " ), 7 );
								result.deployedAt = DateTimeFormat( GetFileInfo( packedRefsPath ).lastmodified, "dd/mm/yyyy HH:nn" );
								break;
							}
						}
					}
				}
			} else {
				// HEAD scollegato (detached): la SHA è scritta direttamente nel file HEAD.
				result.sha        = Left( head, 7 );
				result.deployedAt = DateTimeFormat( GetFileInfo( headPath ).lastmodified, "dd/mm/yyyy HH:nn" );
			}
		} catch ( any e ) {
			// niente: la versione resta vuota, non deve mai far fallire l'avvio
		}

		return result;
	}

}
