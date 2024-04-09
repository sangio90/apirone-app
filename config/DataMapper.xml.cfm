<!DOCTYPE dataMapper PUBLIC "-//DATAMAPPER//DTD DATAMAPPER//EN"
        "http://mm-projects.s3.amazonaws.com/dtd/dataMapper.dtd">

<mappers>

    <mapper id="State" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.State">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
    </mapper>   

    <mapper id="Country" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Country">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
    </mapper>

    <mapper id="Status" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Status">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
    </mapper>

    <mapper id="Product" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Product">
        <map from="id" to="id" type="cf:String"  />
        <map from="code" to="code" type="cf:String"  />
        <map from="description" to="description" type="cf:String"  />
        <map from="companyId" to="companyId" type="cf:String"  />
        <map from="status" to="status" ref="Status"  />
        <map from="variantType" to="variantType" ref="VariantType"  />
        <map from="variants" to="variants"  type="Array" ref="ProductVariant"  />

    </mapper>

    <mapper id="ProductVariant" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductVariant">
        <map from="id" to="id" type="cf:String"  />
        <map from="description" to="description" type="cf:String"  />
        <map from="status" to="status" ref="Status"  />
        <map from="price" to="price" ref="Price"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="images" to="images"  type="Array" ref="File"  />
    </mapper>

    <mapper id="File" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.File">
        <map from="id" to="id" type="cf:String"  />
        <map from="versions" to="versions" type="cf:Struct"  />
        <map from="directory" to="directory" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
     
    </mapper>
    
    <mapper id="Price" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Price">
        <map from="id" to="id" type="cf:String"  />
        <map from="value" to="value" type="cf:Numeric"  />
        <map from="discount" to="discount" type="cf:Numeric"  />
        <map from="discountType" to="discountType" type="cf:String"  />
    </mapper>
    
    <mapper id="VariantType" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VariantType">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
    </mapper>

</mappers>
