component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="cardService" type="com.apirone.core.model.service.CardService";

    
    public com.apirone.core.model.bean.Wallet function get(
			required String employeeId
    	){

        var wallet = super.bean('Wallet');

        wallet.setCards( 
            getCardService()
                .list( employeeId = arguments.employeeId )
                .getData()
        );

        return wallet;

    }


}