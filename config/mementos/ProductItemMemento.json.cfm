{
	defaultIncludes = [ "id", "shortId", "name", "code" ],
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
				"orderBy",
				"productId",
				"spaces"
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
				"prices",
				"childrenCount"
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
				"horizontalImage",
				"verticalImage",
				"important$boolean"
			]
		}
	}
}