component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = [ "id", "name" ],
	}

	property name="entity" type="Entity";

    public Role function init(){

        return this;
    }

}
