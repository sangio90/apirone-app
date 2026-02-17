{
    defaultIncludes = [
        "id",
        "shortId",
        "price",
        "quantity",
        "product.finish.code",
        "product.finish.name",
        "product.model.code",
        "product.model.name",
        "product.line.code",
        "product.line.name",
        "position.code",
        "article.code",
        "article.name",
        "image",
    ],
    profiles = {
        editPlate = {
            defaultIncludes = [
                "id",
                "price",
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
                "position.id",
                "position.code",
                "status",
                "frame"
            ]
        },
        edit = {
            defaultIncludes = [
                "id",
                "price",
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
                "position.id",
                "position.code",
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
                "status"
            ]
        }
    },
}
	