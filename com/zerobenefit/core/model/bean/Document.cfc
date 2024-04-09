component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{
    
    property name="date" type="Date";
    property name="code" type="Numeric";
    property name="type" type="com.apirone.core.model.bean.DocumentType";
    property name="employee" type="com.apirone.core.model.bean.Employee";
    property name="items" type="com.apirone.core.model.bean.DocumentItem[]";
    property name="status" type="com.apirone.core.model.bean.Status";

    public Document function init(){

        return this;
    }

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