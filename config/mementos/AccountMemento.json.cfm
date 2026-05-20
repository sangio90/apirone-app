{
	defaultIncludes = [ "id", "shortId", "name", "email", "idUtenteVerticale", "idAgenteVerticale" ],
	neverIncludes   = [ "pwd", "apiKey" ],
	profiles        = {
		list = {
			defaultIncludes = [
				"id",
				"name",
				"email",
				"userCount",
				"serial",
				"status",
				"shortId",
				"createdAt",
				"idUtenteVerticale",
				"idAgenteVerticale"
			]
		}
	}
}
