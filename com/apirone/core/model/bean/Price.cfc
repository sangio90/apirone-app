component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="value" type="Numeric";
    property name="variantId" type="String";
    property name="discount" type="Numeric";
    property name="discountType" type="String" hint='P || F';

    public Price function init(){

        return this;
    }

    public Numeric function getFinalPrice() {

        var value    = getValue();
        var discount = getDiscount();
        var type     = getDiscountType();

        if ( isNull( discount ) ) {

            return value;

        }

        switch( type ) {
            case 'P':
                return value - value * ( discount / 100 );
            default:
                return value - discount;
        }
    
    }

}
