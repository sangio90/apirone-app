component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

	this.memento = {
		defaultIncludes = ["id"],
		defaultExcludes = [],
		neverInclude    = [],
		defaults        = {},
		mappers         = {},
		profiles        = {
			list   = { defaultIncludes = [ "id", "shortId", "name", "nameItem", "descriptionItem", "thickness", "status" ] },
		},
		// Auto cast boolean strings to Java boolean
		autoCastBooleans = true
	}

    public Thickness function init(){

        return this;
    }

}
