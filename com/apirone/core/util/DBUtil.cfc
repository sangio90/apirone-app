/**
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 18/10/2024
 */

component output="false" accessors="true" {

	public Struct function getDBField( required String field ){
		// Effettua il parse della config statica dei campi DB una sola volta per richiesta HTTP
		// (request scope) invece di FileRead + DeserializeJSON a ogni chiamata.
		if ( !StructKeyExists( request, "_dbFieldsCache" ) ) {
			request[ "_dbFieldsCache" ] = DeserializeJSON( FileRead( ExpandPath( "/config/DBFields.json.cfm" ) ) );
		}

		var fields = request[ "_dbFieldsCache" ];

		if ( !StructKeyExists( fields, arguments.field ) ) {
			Throw(
				message = "Field [#arguments.field#] not found in available values.",
				type    = "apirone.error.AbsService.DBFieldNotFound"
			);
		}

		return fields[ arguments.field ];
	}


	public String function getCompleteSQL( required String sql, required Array params = [] ){
		var result = arguments.sql;

		var i = 1;
		for ( var item in arguments.params ) {
			result = Replace( result, "?", "'#item#'", i );
			i++;
		}

		return result;
	}

	public Numeric function backupTable( required String datasource, required String fromTable, required String toTable ){

		var sql = "CREATE TABLE #arguments.toTable# AS SELECT * FROM #arguments.fromTable#";

		var q = QueryExecute(
			sql = sql,
			options = { datasource = arguments.datasource }
		);

		return q.recordCount;
	}

}

