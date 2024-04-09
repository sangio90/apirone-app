component output="true" accessors="true" {
			
	function get( required String prop, required String default='' ) {
		return server.system.properties[ arguments.prop ] 
			?: server.system.environment[ arguments.prop ] 
			?: arguments.default;
	}
	
}