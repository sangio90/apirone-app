{
    defaultIncludes = [ "id", "shortId", "price", "quantity", "image" ],
    profiles        = {
        edit = {
            defaultIncludes = [
                "id",
                "fruit.id",
                "fruit.finish",
                "fruit.model",
                "fruit.line",
                "items",
                "note",
                "positions",
                "createdAt",
            ]
        },
        editForPlace = {
            defaultIncludes = [
                "id",
                "fruit.id",
                "fruit.name",
                "fruit.code",
                "fruit.positionCount",
                "fruit.horizontalImage",
                "positions",
                "createdAt",
            ]
        }
    }
}
	