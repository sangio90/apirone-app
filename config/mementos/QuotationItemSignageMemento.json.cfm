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
        "position",
        "note",
    ],
    profiles = {
        edit = {
            defaultIncludes = [
                "id",
                "price",
                "quantity",
                "product.finish",
                "quotationZone",
                "signageRows",
                "signageConfigItem",
                "special",
                "status",
                "note",
                "position",
            ]
        }
    }
}