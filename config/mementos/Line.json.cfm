{
	defaultIncludes = [ "id", "shortId", "name", "code" ],
	mappers         = {
		"descriptionItem" = function( value ){
			return value ?: {
				"id"   = "",
				"name" = "",
				"lang" = { "id" = "IT", "name" = "" }
			};
		}
	},
	profiles = {
		list = {
			defaultIncludes = [
				"id",
				"shortId",
				"name",
				"nameItem",
				"status",
				"descriptionItem",
				"createdAt",
				"code",
				"categories"
			]
		}
	}
}