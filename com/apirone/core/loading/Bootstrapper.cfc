component{

	public Bootstrapper function init() {
		
		//var wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
		var wirebox = new coldbox.system.ioc.Injector("config.WireboxServices");

		return this;
	
	}

}
