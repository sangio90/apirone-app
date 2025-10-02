component output="false" accessors="true" {

	public com.apirone.core.model.bean.AbsBean function bean( required String type, Struct values = {} ){
		var bean = CreateObject( "com.apirone.core.model.bean.#arguments.type#" ).init();
		return bean;
	}

	private Struct function getConfiguration(){
		var config = new com.apirone.core.model.bean.Configuration();

		return config;
	}

	private Struct function service( required String service ){
		var bean = getContainer().getInstance( "#service#Service" );

		return bean;
	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
