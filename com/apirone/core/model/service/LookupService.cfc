component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	variables.config = {
		"color"        = { "bean" = "color", "file" = "colors.json.cfm" },
		"customerType" = {
			"bean" = "customerType",
			"file" = "customerTypes.json.cfm"
		},
		"fileType"     = { "bean" = "fileType", "file" = "fileTypes.json.cfm" },
		"fileKind"     = { "bean" = "fileKind", "file" = "fileKinds.json.cfm" },
		"priceType"    = { "bean" = "priceType", "file" = "priceTypes.json.cfm" },
		"role"         = { "bean" = "role", "file" = "roles.json.cfm" },
		"documentType" = {
			"bean" = "documentType",
			"file" = "documentTypes.json.cfm"
		},
		"thickness"      = { "bean" = "thickness", "file" = "thicknesses.json.cfm" },
		"processingType" = {
			"bean" = "processingType",
			"file" = "processingTypes.json.cfm"
		},
		"measurementUnit" = {
			"bean" = "measurementUnit",
			"file" = "measurementUnits.json.cfm"
		},
		"sizeType"    = { "bean" = "sizeType", "file" = "sizeTypes.json.cfm" },
		"profileType" = { "bean" = "profileType", "file" = "profileTypes.json.cfm" }
	}

	property name="data" type="Struct";

	public com.apirone.core.model.service.LookupService function init(){
		var data = {};

		for ( var item in variables.config ) {
			var ent = variables.config[ item ];

			if ( FileExists( ExpandPath( "/config/data/#ent.file#" ) ) ) {
				data[ item ] = createRowList( item );
			}
		}

		setData( data );

		return this;
	}

	public com.apirone.core.model.bean.AbsBean function get( required String entity, required String value ){
		var result = NullValue();

		var thisValue = arguments.value;

		list( arguments.entity ).each( function( item ){
			if ( item.getId() EQ thisValue ) {
				result = item;
			}
		} );

		getLogger().debug( "LookupService.get: value [#arguments.value#] for entity [#entity#] not found. Adding it to config?" );
		return result;
	}

	public Array function list( required String entity ){
		var result  = [];
		var factory = new com.apirone.core.model.factory.Factory();

		var list   = getData()[ arguments.entity ];
		var config = variables.config[ arguments.entity ];

		list.each( function( item ){
			result.add( factory.createInstance( config.bean, item ) )
		} );

		return result;
	}


	/*
        private
    */

	private Array function createRowList( required String entity ){
		var config = variables.config[ entity ];
		var list   = DeserializeJSON( FileRead( ExpandPath( "/config/data/#config.file#" ) ) );

		return list;
	}

}
