{
	defaultIncludes = [ "id", "shortId", "name", "email" ],
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
			]
		}
	}
}
