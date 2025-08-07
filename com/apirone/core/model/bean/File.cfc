component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="model" type="Numeric";
	property name="width" type="Numeric";
	property name="height" type="Numeric";
	property name="alt" type="String";
	property name="extension" type="String";
	property name="description" type="String";
	property name="directory" type="String";
	property name="versions" type="Struct";
	property name="default" type="Boolean" default="false";

	property name="kind" type="com.apirone.core.model.bean.FileKind";
	property name="type" type="com.apirone.core.model.bean.FileType";

	public File function init(){
		return this;
	}

	public String function getPath( model = "_ori" ){
		var config      = new com.apirone.core.model.bean.Configuration();
		var imageConfig = config.get( "imagesConfig" )[ getKind().getId() ];

		var path = ExpandPath( "/../repository/public" ) & getRelativePath( arguments.model );

		return ExpandPath( path );
	}

	public String function getUri( model = "_ori" ){
		var settings = new config.Settings();
		var path     = getRelativePath( arguments.model );

		return "#settings.get( "site.repository" )##path#";
	}

	private String function getRelativePath( model = "_ori" ){
		var config = new com.apirone.core.model.bean.Configuration();

		var imageConfig = config.get( "imagesConfig" )[ getKind().getId() ];

		var path = "/media/#imageConfig.path#/#arguments.model#/#this.getDirectory()#/#this.getName()#";

		return path;
	}

}
