/**
 * AbsService class
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 19/02/2020
 */

component output="false" accessors="true" {

	property name="logger" inject="Logger";
	// property name="factory" type="com.apirone.core.model.factory.Factory";
	// ROB: removed because it generates errors when business logic is reloaded.
	// property name="cacheManager" type="com.apirone.core.util.CacheManager";
	// property name="configuration" type="com.apirone.core.model.bean.Configuration" ;
	property name="DBUtil" type="com.apirone.core.model.util.DBUtil";

	/**
	 * @param type - il nome del bean
	 * @param scope - la cartella
	 * @param values - dati inuna struttura
	 */

	public Struct function bean( required String type, Struct values = {} ){
		var factory = new com.apirone.core.model.factory.Factory();

		return factory.createInstance( argumentCollection = arguments );
	}

	public Any function getDataMapper(){
		return model().getInstance( "DataMapper" );
	}

	public com.apirone.core.model.bean.Error function getError(){
		var bean = new com.apirone.core.model.bean.Error();
		return bean;
	}

	public com.apirone.core.model.bean.Result function getResult(){
		var bean = new com.apirone.core.model.bean.Result();

		return bean;
	}

	public String function createOrderBy( required Array fields = [] ){
		var result = "";
		var n      = 1;

		for ( var i in arguments.fields ) {
			if ( !StructKeyExists( i, "dir" ) ) {
				i.dir = "ASC";
			}

			if ( !ListFindNoCase( "ASC,DESC", i.dir ) ) {
				Throw(
					message = "Direction [#i.dir#] not valid for field [#i.field#]. Only accepted values are ASC or DESC",
					type    = "apirone.errors.AbsService.SortValueNotValid"
				);
			}

			result = result & "#getDBField( i.field ).name# #i.dir#"; // not "sort"!

			result = arguments.fields.len() EQ n ? result : result & ", ";

			n++;
		}

		return result;
	}


	public Query function trimQueryFields( required Query records ){
		var columns = records.columnList();

		var index = 1;

		for ( var record in records ) {
			for ( var column in columns ) {
				// records.setCell( column_name="#column#", value="#Replace( Trim( record[ column ]), ",", "$" )#", row_number=index );
				records.setCell(
					column_name = "#column#",
					value       = "#Trim( record[ column ] )#",
					row_number  = index
				);
			}

			index++;
		}

		return records;
	}

	private String function prettyString( required String str ){
		var util = new com.apirone.core.util.Udf();

		return util.prettyString( arguments.str );
	}

	private Array function getCategoriesBeanByIds( required String categories ){
		// [2,3,4,5]

		var result     = [];
		var categories = DeserializeJSON( arguments.categories );

		if ( !IsNull( categories ) AND Len( categories ) ) {
			for ( var thisCategory in categories ) {
				var beanCategory = this.service( "ProductCategory" ).get( thisCategory );

				if ( !IsNull( beanCategory ) ) {
					result.add( beanCategory );
				}
			}
		}

		return result.len() ? result : NullValue();
	}

	private Array function getLinesBeanByIds( required String lines ){
		var result = [];
		var lines  = DeserializeJSON( arguments.lines );

		if ( !IsNull( lines ) AND Len( lines ) ) {
			for ( var thisLine in lines ) {
				var beanLine = this.service( "Line" ).get( thisLine );

				if ( !IsNull( beanLine ) ) {
					result.add( beanLine );
				}
			}
		}

		return result.len() ? result : NullValue();
	}

	private Struct function getDBField( required String field ){
		var DBUtil = new com.apirone.core.util.DBUtil();

		return DBUtil.getDBField( arguments.field );
	}

	private Struct function getCacheManager(){
		return model().getInstance( "CacheManager" );
	}

	private Struct function getConfiguration(){
		var config = new com.apirone.core.model.bean.Configuration();

		return config;
	}

	private Struct function service( required String service ){
		var bean = model().getInstance( "#service#Service" );

		return bean;
	}

	private Struct function model(){
		return server[ "wireBox-apirone" ];
	}

}
