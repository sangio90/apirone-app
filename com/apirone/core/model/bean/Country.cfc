component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "code", "isoCode" ]
	}

	property name="code" type="String";
	property name="isoCode" type="String";
	property name="name" type="String";

    public Country function init(){
        return this;
    }

}
