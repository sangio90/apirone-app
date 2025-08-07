<mappers>

    <mapper id="State" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.State">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="ProductionTime" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.RawProductionTime">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="status" to="status" ref="Status" />
    </mapper>

    <mapper id="Finish" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.State">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="categories" to="categories" ref="ProductCategory" type="Array" />
        <map from="name" to="name" type="cf:String" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="status" to="status" ref="Status" />
        <map from="texts" to="texts" ref="Text" type="Array" />
    </mapper>

    <mapper id="Font" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Font">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="directory" to="directory" type="cf:String" />
        <map from="dimension" to="dimension" type="cf:Numeric" />
        <map from="mainText" to="mainText" ref="Text" />
    </mapper>

    <mapper id="Country" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Country">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="Attribute" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Attribute">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="values" to="values" ref="AttributeValue" type="Array" />
        <map from="categories" to="categories" ref="ProductCategory" type="Array" />
    </mapper>

    <mapper id="RawValue" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.RawValue">
        <map from="id" to="id" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="mainText" to="mainText" ref="Text" />
    </mapper>

    <mapper id="AttributeValue" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.AttributeValue">
        <map from="id" to="id" type="cf:String" />
        <map from="orderBy" to="orderBy" type="cf:Numeric" />
        <map from="componentCount" to="componentCount" type="cf:Numeric" />
        <map from="status" to="status" ref="Status" />
        <map from="rawValue" to="rawValue" ref="RawValue" />
        <map from="affectToImage" to="affectToImage" type="cf:Boolean" />
        <map from="allowNote" to="allowNote" type="cf:Boolean" />
    </mapper>

    <mapper id="AttributeValueTree" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.AttributeValue">
        <map from="id" to="id" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="mainText" to="mainText" ref="MainText" />
    </mapper>

    <mapper id="AttributeForProductItem" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Attribute">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="mainText" to="mainText" ref="Text" />
    </mapper>

    <mapper id="Profile" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Profile">
        <map from="id" to="id" type="cf:String" />
        <map from="firstName" to="firstName" type="cf:String" />
        <map from="lastName" to="lastName" type="cf:String" />
    </mapper>

    <mapper id="Quotation" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Quotation">
        <map from="id" to="id" type="cf:String" />
        <map from="description" to="description" type="cf:String" />
        <map from="quotationNumber" to="quotationNumber" type="cf:String" />
        <map from="versionNumber" to="versionNumber" type="cf:Numeric" />
        <map from="quotationDate" to="quotationDate" type="cf:Date" />
        <map from="notes" to="notes" type="cf:String" />
        <map from="validityDate" to="validityDate" type="cf:Date" />
        <map from="opportunityName" to="opportunityName" type="cf:String" />
        <map from="leadName" to="leadName" type="cf:String" />
        <map from="pricelist" to="pricelist" ref="Pricelist" />
        <map from="paymentMethod" to="paymentMethod" ref="PaymentMethod" />
        <map from="customPaymentMethod" to="customPaymentMethod" type="cf:String" />
        <map from="currency" to="currency" ref="Currency" />
        <map from="status" to="status" ref="Status" />
        <map from="lang" to="lang" ref="Lang" />
        <map from="billingProfile" to="billingProfile" ref="BillingProfile" />
        <map from="shippingProfile" to="shippingProfile" ref="ShippingProfile" />
        <map from="salesAgentAccount" to="salesAgentAccount" ref="Account" />
        <map from="graphicTechnicianAccount" to="graphicTechnicianAccount" ref="Account" />
    </mapper>

    <mapper id="QuotationItem" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.QuotationItem">
        <map from="id" to="id" type="cf:String" />
        <map from="price" to="price" type="cf:Numeric" />
        <map from="quantity" to="quantity" type="cf:Numeric" />
        <map from="quotation" to="quotation" ref="Quotation" />
        <map from="zone" to="zone" ref="QuotationItemZone" />
        <map from="position" to="position" ref="QuotationItemPosition" />
        <map from="product" to="product" ref="QuotationItemProduct" />
    </mapper>

    <mapper id="QuotationItemProduct" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.QuotationItemProduct">
        <map from="id" to="id" type="cf:String" />
        <map from="quotationItem" to="quotationItem" ref="QuotationItem" />
        <map from="product" to="product" ref="Product" />
        <map from="parent" to="parent" ref="QuotationItemProduct" />
    </mapper>    

    <mapper id="Pricelist" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Pricelist">
        <map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="PaymentMethod" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.PaymentMethod">
        <map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="BillingProfile" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.BillingProfile">
        <map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="ShippingProfile" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ShippingProfile">
        <map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="Currency" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Currency">
        <map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="ProductItem" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductItem">
        <map from="id" to="id" type="cf:String" />
        <map from="attributeValue" to="attributeValue" ref="AttributeValue" />
        <map from="attribute" to="Attribute" ref="AttributeForProductItem" />
        <map from="parent" to="parent" ref="ProductItem" />
        <!-- <map from="children" to="children" type="Array" ref="ProductItem" /> -->
        <map from="status" to="status" ref="Status" />
        <map from="orderby" to="orderby" type="cf:Numeric" />
        <map from="componentCount" to="componentCount" type="cf:Numeric" />
        <map from="level" to="level" type="cf:String" />
    </mapper>

    <mapper id="Product" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Product">
        <map from="id" to="id" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="name" to="name" type="cf:String" />
        <map from="positionCount" to="positionCount" type="cf:Numeric" />
    </mapper>

    <mapper id="Combination" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Combination">
		<map from="id" to="id" type="cf:String" />
		<map from="name" to="name" type="cf:String" />
		<map from="productId" to="productId" type="cf:String" />
		<map from="shortId" to="shortId" type="cf:String" />
        <map from="status" to="status" ref="Status" />
    </mapper>

    <mapper id="CombinationProductItem" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.CombinationProductItem">
		<map from="productItemId" to="productItemId" type="cf:String" />
		<map from="combinationId" to="combinationId" type="cf:String" />
		<map from="id" to="id" type="cf:String" />
    </mapper>

    <mapper id="ProductItemTree" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductItem">
        <map from="id" to="id" type="cf:String" />
        <map from="attributeValue" to="attributeValue" ref="AttributeValueTree" />
    </mapper>

    <mapper id="Text" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Text">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="lang" to="lang" ref="Lang" />
        <map from="status" to="status" ref="Status" />
    </mapper>

    <mapper id="MainText" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Text">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="lang" to="lang" ref="Lang" />
    </mapper>

    <mapper id="Lang" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Lang">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="Line" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Line">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="thickness" to="thickness" ref="Thickness" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="categories" to="categories" ref="ProductCategory" type="Array" />
        <map from="status" to="status" ref="Status" />
        <map from="createdAt" to="createdAt" type="cf:Date" />
    </mapper>

    <mapper id="Fruit" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Fruit">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="positionCount" to="positionCount" type="cf:Integer" />
        <map from="createdAt" to="createdAt" type="cf:Date" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="category" to="category" ref="ProductCategory" />
        <map from="lines" to="lines" ref="Line" type="Array" />
    </mapper>

    <mapper id="Product" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Product">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="positionCount" to="positionCount" type="cf:Integer" />
        <map from="createdAt" to="createdAt" type="cf:Date" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="category" to="category" ref="ProductCategory" />
    </mapper>

    <mapper id="Thickness" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Thickness">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="ProductCategoryType" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductCategoryType">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="orderBy" to="orderBy" type="cf:Integer" />
    </mapper>

    <mapper id="ProductCategoryMode" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductCategoryMode">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="ProductCategory" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductCategory">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="type" to="type" ref="ProductCategoryType" />
        <map from="mode" to="mode" ref="ProductCategoryMode" />
    </mapper>

    <mapper id="Account" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Account">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="email" to="email" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="serial" to="serial" type="cf:Numeric" />
        <map from="createdAt" to="createdAt" type="cf:String" />
        <map from="status" to="status" ref="Status" />
        <map from="role" to="role" ref="Role" />
        <map from="roles" to="roles" type="Array" ref="Role" />
        <map from="lang" to="lang" ref="Lang" />
    </mapper>

    <mapper id="Model" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Model">
        <map from="id" to="id" type="cf:String" />
        <map from="shortId" to="shortId" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="code" to="code" type="cf:String" />
        <map from="fruitsCount" to="fruitsCount" type="cf:Integer" />
        <map from="mainText" to="mainText" ref="Text" />
        <map from="status" to="status" ref="Status" />
        <map from="categories" to="categories" ref="ProductCategory" type="Array" />
        <map from="type" to="type" ref="ModelType" />
        <map from="createdAt" to="createdAt" type="cf:Date" />
    </mapper>

    <mapper id="ModelType" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ModelType">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="Status" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Status">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="color" to="color" ref="SystemColor" />
    </mapper>

    <mapper id="SystemColor" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.SystemColor">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="class" to="class" type="cf:String" />
        <map from="hex" to="hex" type="cf:String" />
    </mapper>

    <mapper id="File" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.File">
        <map from="id" to="id" type="cf:String" />
        <map from="versions" to="versions" type="cf:Struct" />
        <map from="directory" to="directory" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="Price" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Price">
        <map from="id" to="id" type="cf:String" />
        <map from="value" to="value" type="cf:Numeric" />
        <map from="discount" to="discount" type="cf:Numeric" />
        <map from="discountType" to="discountType" type="cf:String" />
    </mapper>

    <mapper id="VariantType" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VariantType">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="Report" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VariantType">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="exampleData" to="exampleData" type="cf:String" />
        <map from="exampleFile" to="exampleFile" type="cf:String" />
        <map from="fileName" to="fileName" type="cf:String" />
    </mapper>

    <mapper id="VatCode" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.VatCode">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
        <map from="value" to="value" type="cf:Numeric" />
    </mapper>

    <mapper id="Role" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.Role">
        <map from="id" to="id" type="cf:String" />
        <map from="name" to="name" type="cf:String" />
    </mapper>

    <mapper id="ProductComponent" source="Cf:Struct" target="Cfc:com.apirone.core.model.bean.ProductComponent">
        <map from="id" to="id" type="cf:String" />
    </mapper>

</mappers>
