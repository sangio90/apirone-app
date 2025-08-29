component extends="testbox.system.BaseSpec" {

	public function getStringUtil(){
		return new com.iperchatbot.core.util.String();
	}

	public function getFactory(){
		return new com.iperchatbot.core.model.factory.Factory();
	}

	public function getMockup(){
		return new tests.utils.MockupData();
	}

	public function getContainer(){
		return new coldbox.system.ioc.Injector( "config.Wirebox" );
	}

	public function getHelperData(){
		return new tests.utils.HelperData();
	}

}
