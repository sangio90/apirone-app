component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="types" type="com.apirone.core.model.bean.CompanyType[]";
    property name="vat" type="String";
    property name="contact" type="String";
    property name="phone" type="String";
    property name="code" type="String";
    property name="status" type="com.apirone.core.model.bean.Status";
    property name="location" type="com.apirone.core.model.bean.Location";
    property name="account" type="com.apirone.core.model.bean.Account";
    property name="commissions" type="com.apirone.core.model.bean.Commission[]";

    public Company function init(){

        return this;
    }

    public Array function getTypesAsArray() {

        var types = getTypes();

        if ( isNull(types ) ) {

            return typeIds;
            
        }

        var typeIds = getTypes()
                        .map( function(type) {
                            return type.getId();
                        });
 
        return typeIds;
    }

}
