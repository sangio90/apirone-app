component{

	public Bootstrapper function init() {
		
		var wirebox = new coldbox.system.ioc.Injector("config.WireboxServices");

		return this;
	
	}

}
