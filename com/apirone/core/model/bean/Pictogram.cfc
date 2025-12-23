component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="image" type="File";
	property name="code" type="String";
	property name="name" type="String";
	property name="FontFamilyId" type="Numeric"; //aggiunto per evitare lo stack overflow nel build di PictogramService

	public Pictogram function init(){
		return this;
	}

}
