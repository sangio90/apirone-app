component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"code",
			"orientation",
			"cellOrientation",
			"status"
		],
		profiles = {
			detail = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"code",
					"orientation",
					"cellOrientation",
					"cells"
				]
			},
		}
	};

	property name="code" type="String";
	property name="orientation" type="com.apirone.core.model.bean.Orientation";
	property name="cellOrientation" type="com.apirone.core.model.bean.Orientation";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="cells" type="com.apirone.core.model.bean.FrameCell[]";

	public Frame function init(){
		return this;
	}

}
