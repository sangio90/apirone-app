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

    <mapper id="Attribute" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Attribute">
        <map from="id" to="id" type="cf:String"  />
        <map from="mainText" to="mainText" type="cf:String"  />
        <map from="status" to="status" ref="Status"  />
        <map from="values" to="values" ref="AttributeValue" type="Array" />
    </mapper>

    <mapper id="AttributeValue" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.AttributeValue">
        <map from="id" to="id" type="cf:String"  />
        <map from="orderBy" to="orderBy" type="cf:Numeric"  />
        <map from="status" to="status" ref="Status"  />
        <map from="mainText" to="mainText" type="cf:String"  />
    </mapper>

    <mapper id="Text" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Text">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="lang" to="lang" ref="Lang" />
        <map from="status" to="status" ref="Status" />
    </mapper>

    <mapper id="Lang" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Lang">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
    </mapper>

    <mapper id="Line" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Line">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="createdAt" to="createdAt" type="cf:Date"  />
    </mapper>

    <mapper id="Size" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Size">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="createdAt" to="createdAt" type="cf:Date"  />
    </mapper>

    <mapper id="Status" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Status">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="color" to="color" ref="SystemColor"  />
    </mapper>

    <mapper id="SystemColor" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.SystemColor">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="class" to="class" type="cf:String"  />
        <map from="hex" to="hex" type="cf:String"  />
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

    <mapper id="Report" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VariantType">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="exampleData" to="exampleData" type="cf:String"  />
        <map from="exampleFile" to="exampleFile" type="cf:String"  />
        <map from="fileName" to="fileName" type="cf:String"  />
    </mapper>

    <mapper id="VatCode" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VatCode">
        <map from="id" to="id" type="cf:String"  />
        <map from="name" to="name" type="cf:String"  />
        <map from="value" to="value" type="cf:Numeric"  />
    </mapper>

</mappers>
