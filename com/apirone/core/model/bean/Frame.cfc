component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"frame",
			"code",
			"orientationId",
			"cellOrientationId"
		],
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"frame",
					"code",
					"orientationId",
					"cellOrientationId"
				]
			},
			detail = {
				defaultIncludes = [
					"id",
					"frame",
					"code",
					"orientationId",
					"cellOrientationId",
					"cells"
				]
			}
		}
	};

	property name="code" type="String";
	property name="orientation" type="com.apirone.core.model.bean.Orientation";
	property name="cellOrientation" type="com.apirone.core.model.bean.Orientation";
	property name="cells" type="com.apirone.core.model.bean.FrameCell[]";

	public Frame function init(){
		return this;
	}

}
