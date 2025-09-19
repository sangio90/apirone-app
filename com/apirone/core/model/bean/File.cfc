component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name", "type", "uri", "size", "width", "height", "type" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"size",
					"width",
					"height",
					"directory",
					"type",
					"default",
					"uri",
					"shortId"
				]
			}
		}
	}

	property name="size" type="Numeric";
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

	public String function getPath( size = "_ori" ){
		var config      = super.getConfiguration();
		var imageConfig = config.get( "imagesConfig" )[ getKind().getId() ];

		var path = ExpandPath( "/../repository/public" ) & getRelativePath( arguments.size );

		return ExpandPath( path );
	}

	public String function getUri( size = "_ori" ){
		var settings = new config.Settings();
		var path     = getRelativePath( arguments.size );

		return "#settings.get( "site.repository" )##path#";
	}

	private String function getRelativePath( size = "_ori" ){
		var config = super.getConfiguration();

		var imageConfig = config.get( "imagesConfig" )[ getKind().getId() ];

		var path = "/media/#imageConfig.path#/#arguments.size#/#this.getDirectory()#/#this.getName()#";

		return path;
	}

}
