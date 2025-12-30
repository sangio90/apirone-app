{
	defaultIncludes = [ "id", "shortId", "entity", "action", "message" ],
	profiles = {
		list = {
			defaultIncludes = [
				"id",
				"user.id",
				"user.name",
				"user.shortId",
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
				"user.id",
				"user.name",
				"user.shortId",
				"user.account.email",
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