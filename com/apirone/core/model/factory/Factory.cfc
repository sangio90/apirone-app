component output="false" accessors="true" {

	public Any function createInstance( required String type, Struct values={} ){

        var obj = CreateObject( "component", 'com.apirone.core.model.bean.#arguments.type#' );

        if ( !StructIsEmpty( arguments.values ) ){

            obj.setMemento( arguments.values );
        
        }

		return obj;
	}

}
