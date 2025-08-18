component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="texts" type="com.apirone.core.model.bean.Text[]";

	public Struct function getTextItem( langId = "IT", kindId = "NAME" ){
		if ( IsNull( arguments.langId ) ) {
			var langId = getCurrentLang().getId();
		} else {
			var langId = arguments.langId;
		}

		if ( !IsNull( getTexts() ) ) {
			for ( var text in getTexts() ) {
				if ( text.getLang().getId() == langId AND text.getKind().getId() == kindId ) {
					return text;
				}
			}
		}

		return NullValue();
	}

	public String function getName( String langId = NullValue() ){
		return getTextItem( arguments.langId, "NAME" )?.getName() ?: "** Not found";
	}

	public String function getDescription( String langId = NullValue() ){
		return getTextItem( arguments.langId, "DESC" )?.getName() ?: "** Not found";
	}

	public Struct function getNameItem( String langId = NullValue() ){
		return getTextItem( arguments.langId, "NAME" );
	}

	public Struct function getDescriptionItem( String langId = NullValue() ){
		return getTextItem( arguments.langId, "DESC" );
	}


	/*
	public com.apirone.core.model.bean.Text function OnMissingMethod( String method, Array args ){
		if ( arguments.method == "getNameItem" ) {
			return getTextItem( NullValue(), "NAME" );
		}

		if ( arguments.method == "getDescriptionItem" ) {
			return getTextItem( NullValue(), "DESC" );
		}

		Throw( "I'm custom OnMissingTemplate: component [#GetFileFromPath( GetCurrentTemplatePath() )#] has no function with name [#arguments.method#]." );
	}
	*/

}
