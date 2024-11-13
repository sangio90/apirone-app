component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

    property name="texts" type="com.apirone.core.model.bean.Text[]";

    public Struct function getMainText( langId ){

        if( IsNull( arguments.langId ) ) {

            var langId = getCurrentLang().getId();
        
        } else {
            
            var langId = arguments.langId;
        
        }

        for( var text in getTexts() ) {

            if ( text.getLang().getId() == langId ) {
                return text
            }

        }

        return NullValue();
        
    }

    public String function getMainName( String langId=NullValue() ){

        return getMainText( arguments.langId ).getName();
    
    }

}
