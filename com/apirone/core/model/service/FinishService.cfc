component extends="com.apirone.core.model.service.AttributeValueService" accessors="true" {

    public com.apirone.core.model.bean.Finish function get(
    		required String finishId
        ){

		var bean = super.get( finishId );
		var finish = super.bean( "Finish" );

		var memento = bean.getMemento();
		finish.setMemento( memento );
        
		return finish;

	}

}
