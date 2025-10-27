component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="User.bean";

	private com.apirone.core.model.bean.User function build( required String userId ){
		var record = getDao().read( userId = arguments.userId );

		var user = NullValue();

		if ( record.RecordCount ) {
			var user = super.bean( "User" );
			var roles   = [];

			user.setId( record.user_id );
			user.setRole( record.email );
			//user.setuser( record.user );

		}

		return user;
	}

}
