{
    defaultIncludes = [ "id", "shortId", "price", "quantity", "image" ],
    profiles        = {
        edit = {
            defaultIncludes = [
                "id",
                "price",
                "price.total",
                "quantity",
                "product.id",
                "product.finish",
                "product.model",
                "product.line",
                "product.horizontalImage",
                "product.verticalImage",
                "quotationZone",
                "items",
                "note",
                "createdAt",
                "special",
                "position",
                "status",
            ]
        },
        editArticle = {
            defaultIncludes = [
                "id",
                "price",
                "price.total",
                "quantity",
                "product.id",
                "product.finish",
                "product.model",
                "product.line",
                "quotationZone",
                "article",
                "items",
                "note",
                "createdAt",
                "special",
                "position",
                "status",
            ]
        }
    }
}
	