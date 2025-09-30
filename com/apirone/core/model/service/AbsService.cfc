/**
 * AbsService class
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 19/02/2024
 */

component output="false" accessors="true" {

	// property name="logger" inject="Logger";
	// property name="DBUtil" type="com.apirone.core.model.util.DBUtil";

	public com.apirone.core.model.bean.AbsBean function bean( required String type, Struct values = {} ){
		var bean = CreateObject( "com.apirone.core.model.bean.#arguments.type#" ).init();
		return bean;
	}

	public Any function getDataMapper(){
		return getContainer().getInstance( "DataMapper" );
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
					type    = "apirone.error.AbsService.SortValueNotValid"
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

	public Boolean function backupTable( required String fromTable ){

		var dbUtil  = new com.apirone.core.util.DBUtil();

		dbUtil.backupTable(
			datasource = "apirone", //FIXME: make it configurable
			fromTable  = arguments.fromTable,
			toTable    = "backup.#arguments.fromTable#_#DateFormat( Now(), "yyyymmdd" )#_#TimeFormat( Now(), "HHmmss" )#"
		);

		return true;
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

	private Array function getEntitiesBeanByIds( required String entities ){
		// [2,3,4,5]

		var result   = [];
		var entities = DeserializeJSON( arguments.entities );

		if ( !IsNull( entities ) AND Len( entities ) ) {
			for ( var thisEnt in entities ) {
				// var beanEntity = this.service( "ProductCategory" ).get( thisEnt );
				var beanEntity = this.service( "Lookup" ).get( "entity", thisEnt );

				if ( !IsNull( beanEntity ) ) {
					result.add( beanEntity );
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
		return getContainer().getInstance( "CacheManager" );
	}

	private Struct function getConfiguration(){
		var config = new com.apirone.core.model.bean.Configuration();

		return config;
	}

	private Struct function service( required String service ){
		var bean = getContainer().getInstance( "#service#Service" );

		return bean;
	}

	private Struct function logEvent(){
		var helper = getContainer().getInstance( "AuditHelper" );
		helper.logEvent( argumentCollection = arguments );
	}

	private Struct function getLogger(){
		var bean = getContainer().getInstance( "Logger" );

		return bean;
	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
