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
        "image",
    ],
    profiles = {
        edit = {
            defaultIncludes = [
                "id",
                "price",
                "quantity",
                "product.id",
                "product.category",
                "product.finish",
                "product.model",
                "product.line",
                "quotationZone",
                "items",
                "note",
                "createdAt",
            ]
        }
    }
}