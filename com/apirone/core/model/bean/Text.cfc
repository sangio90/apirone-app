component output="true"  extends="com.apirone.core.model.bean.AbsBean"  accessors="true" {		
	
    //property name="text" type="String";
	property name="lang" type="com.apirone.core.model.bean.Lang";
	property name="status" type="com.apirone.core.model.bean.Status";

	public Text function init(){

		return this;

	}

}
