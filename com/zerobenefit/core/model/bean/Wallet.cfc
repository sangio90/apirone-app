component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="cards" type="com.apirone.core.model.bean.Card[]";

    public Account function init(){

        return this;
    }

    public Numeric function getTotalAmount() {

        var sum = 0;

        getCards().each(function(card) {
            sum += card.getAmountLeft() 
        });

        return sum;
    }

}
