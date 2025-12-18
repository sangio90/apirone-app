component extends="com.apirone.core.util.helper.AbsHelper" {

	/**
	 * Transform a list of ProductItem entities
	 * 
	 * @list   The array of ProductItem objects to transform
	 * @config Configuration struct containing profile and includes
	 */
	public Array function convertList( required Array list, required String profile ){
		var result  = [];

		for ( var item in arguments.list ) {
			result.append( convert( profile = arguments.profile, bean = item ) );
		}

		return result;
	}

	public Struct function convert( required String profile, required Struct bean ){

        var data = {};

        switch( profile ){

            case "tree":
                data = tree( bean = arguments.bean );
                break;

            default:
                throw( type="ProductItemTransformer.InvalidArgument", message="Unknown transform profile [#arguments.profile#]." );

        }

		return data;

	}


    /*
        private
    */

	private Struct function tree( required Struct bean  ){

        var row = {
            "id"                = bean.getId(),
            "shortId"           = bean.getShortId(),
            "status"            = {
                "id" = bean.getStatus().getId(),
                "color" = {
                    "id"  = bean.getStatus().getColor().getId(),
                    "hex" = bean.getStatus().getColor().getHex()
                }
            },
            "origin"            = {
                "id" = bean.getOrigin()?.getId()
            },
            "level"             = bean.getLevel(),
            "attribute"         = {
                "id" = bean.getAttribute().getId(),
                "name" = bean.getAttribute().getName()
            },
            "attributeValue"    = {
                "id" = bean.getAttributeValue().getId(),
                "rawValue" = {
                    "id" = bean.getAttributeValue().getRawValue().getId(),
                    "name" = bean.getAttributeValue().getRawValue().getName()
                }
            },
            "componentCount" = bean.getComponentCount(),
            "prices" = bean.getPrices()
        };

		return row;

	}

}
