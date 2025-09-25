component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"row",
			"col",
			"type",
			"width",
			"height",
			"type",
			"orientation"
		]
	};

	property name="row" type="Numeric" default=0;
	property name="col" type="Numeric" default=0;
	property name="width" type="Numeric" default=0;
	property name="height" type="Numeric" default=0;
	property name="type" type="com.apirone.core.model.bean.FrameCellType";
	property name="orientation" type="com.apirone.core.model.bean.Orientation";

	property name="frameId" type="String";

	public FrameCell function init(){
		return this;
	}

}
