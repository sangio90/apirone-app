component extends="com.apirone.core.model.bean.AbsBean" accessors="true"{

    property name="code" type="String";
    property name="description" type="String";
    property name="expirationAt" type="Date";
    property name="price" type="Numeric";
    property name="minQuantity" type="Numeric" default="0";
    property name="fee" type="Numeric" default="10";
    
    property name="categories" type="com.apirone.core.model.bean.ProductCategory[]";
    property name="variants" type="com.apirone.core.model.bean.ProductVariant[]";
    property name="variantType" type="com.apirone.core.model.bean.VariantType";
    property name="status" type="com.apirone.core.model.bean.Status";   
    property name="company" type="com.apirone.core.model.bean.Company";   
    
    public Product function init(){

        return this;
        
    }

    public com.apirone.core.model.bean.ProductCategory function getMainCategory() {
    
        return new com.apirone.core.model.bean.ProductCategory();

    }

    public String function getPermalink() {
    
        return "/manager/catalogue/products/#getId()#"

    }

    public com.apirone.core.model.bean.File function getImage() {

        for( var variant in getVariants() ) {

            for( var image in variant.getImages() ) {

                if ( image.getDefault() ) {
                    return image;
                }

            }

        }

        return NullValue();
    
    }

}
