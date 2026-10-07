component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ErrorLogDAO";

	public void function log( required Struct data ){
		getDao().insert( arguments.data );
	}

	public Query function search( String str = "", Numeric limit = 50, Numeric offset = 0 ){
		return getDao().search( argumentCollection = arguments );
	}

	public Query function get( required Numeric id ){
		return getDao().read( arguments.id );
	}

}
