{
	defaultIncludes = [ "id", "shortId", "entity", "action", "message" ],
	profiles = {
		list = {
			defaultIncludes = [
				"id",
				"account.id",
				"account.name",
				"account.shortId",
				"message",
				"severity",
				"entity",
				"action",
				"ipAddress",
				"createdAt"
			]
		},
		detail = {
			defaultIncludes = [
				"id",
				"account.id",
				"account.name",
				"account.shortId",
				"message",
				"severity",
				"entity",
				"action",
				"ipAddress",
				"createdAt",
				"userAgent",
				"payload"
			]
		}
	}
}