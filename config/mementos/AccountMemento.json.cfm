{
	defaultIncludes = [ "id", "shortId", "name", "email" ],
	neverIncludes   = [ "pwd", "apiKey" ],
	profiles        = {
		list = {
			defaultIncludes = [
				"id",
				"name",
				"email",
				"serial",
				"status",
				"shortId",
				"createdAt",
			]
		}
	}
}
