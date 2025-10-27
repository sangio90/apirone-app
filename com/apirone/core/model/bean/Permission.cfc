component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = [ "id", "name" ],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"entity"
				]
			}
		}
	}

	property name="entity" type="Entity";

    public Permission function init(){

        return this;
    }

}
