component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="items" type="com.apirone.core.model.bean.CartItem[]";

    public Cart function init(){

        setItems( [] );

        return this;
    
    }

    /*
    public Numeric function getTotal() {

        return getAmount() - getAmountSpent();

    }
    */

    public Numeric function getTotal(){

        var total = 0;
        var items = getItems();

        if ( !IsNull( items ) ) {

            for( var item in items ) {

                total = total + ( Val( item.getPrice() ) * Val( item.getQuantity() ) );
    
            }

        }

        return total;

    }

}
