{
	defaultIncludes = [ "id", "shortId", "name", "code", "orderby", ],
	profiles        = {
		list = {
			defaultIncludes = [
				"id",
				"status",
				"origin",
				"attribute",
				"attributeValue",
				"nameItem",
				"componentCount",
				"level",
				"orderby",
				"productId",
				"spaces",
				"images",
				"horizontalImage",
				"verticalImage",
			]
		},
		tree = {
			defaultIncludes = [
				"id",
				"shortId",
				"status.id",
				"status.color.id",
				"status.color.hex",
				"origin.id",
				"level",
				"attribute",
				"attributeValue.id",
				"attributeValue.rawValue.id",
				"attributeValue.rawValue.name",
				"componentCount",
				"images",
				"orderby",
				"horizontalImage",
				"verticalImage",
			]
		},
		treelight = {
			defaultIncludes = [
				"id",
				"shortId",
				"origin.id",
				"level",
				"attribute.id",
				"attribute.name",
				"attributeValue.id",
				"attributeValue.horizontalImage",
				"attributeValue.verticalImage",
				"attributeValue.rawValue.name",
				"attributeValue.rawValue.id",
				"attributeValue.allowNote",
				"horizontalImage",
				"verticalImage",
				"important$boolean",
				"orderby",
				"horizontalImage",
				"verticalImage",
			]
		}
	}
}