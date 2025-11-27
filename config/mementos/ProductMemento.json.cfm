{
	defaultIncludes = [
		"id",
	],
	mappers  = {},
	profiles = {
		list = {
			defaultIncludes = [
				"id",
				"shortId",
				"name",
				"code",
				"nameItem",
				"status",
				"positionCount",
				"createdAt",
				"categories",
				"category",
				"lines",
				"line",
				"model",
				"finish",
				"prices",
				"horizontalImage",
				"verticalImage",
				"items"
			]
		},
		menu = {
			defaultIncludes = [
				"id",
				"shortId",
				"name",
				"code",
				"nameItem",
				"status.id",
				"code",
				"line.id",
				"line.name",
				"model.id",
				"model.name",
				"finish.id",
				"finish.name",
			]
		},
		plate = {
			defaultIncludes = [
				"id",
				"code",
				"shortId",
				"status.id",
				"line.id",
				"line.name",
				"model.id",
				"model.name",
				"model.code",
				"finish.id",
				"finish.name",
				"horizontalImage",
				"verticalImage"
			]
		},
		detail = {
			defaultIncludes = [
				"id",
				"serial",
				"shortId",
				"status.id",
				"status.color",
				"minQuantity",
				"maxQuantity",
				"importantAttributes",
				"prices",
				"special$boolean",
			]
		},

	}
}