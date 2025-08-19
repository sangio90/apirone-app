<cfset model = server["wireBox-apirone"]>
<cfset data = []>

<cfset lineSvc = model.getInstance("LineService")>
<cfset cacheMgr = model.getInstance("CacheManager")>
<cfset productSvc = model.getInstance("ProductService")>
<cfset componentSvc = model.getInstance("ComponentService")>
<cfset productItemSvc = model.getInstance("ProductItemService")>

<cfset categoryId = 22>

<!--- barocca --->
<cfset fromLine = "c0fb8f55-40e1-4eb2-8ae2-58f27ffb872f">

<!--- bevel --->
<cfset toLine = "e0408944-aa83-47c3-bbc8-568ab7885c40">

<cfset line = lineSvc.get( fromLine )>

<cfset products = productSvc.list( lineId = fromLine, categoryId = categoryId )>

<cfquery name="q" datasource="apirone">
	DELETE FROM products
	WHERE line_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#toLine#">::uuid 
		AND product_category_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#categoryId#">
</cfquery>

<cfloop array="#products#" item="product">

	<cfset item = Duplicate( product )>
	<cfset item.getLine().setId( toLine )>

	<cfset newId = productSvc.create( item )>

	<cfset productItems = productItemSvc.getTree( productId = product.getId() )>

	<cfloop array="#productItems#" item="productItem">
		<cfset createProductItem( productItem = productItem, level = 1, productId = newId )>
	</cfloop>

</cfloop>

<cffunction name="createProductItem" access="public" returntype="void">

	<cfargument name="productId" type="String" required="true">
	<cfargument name="productItem" type="Struct" required="true">
	<cfargument name="level" type="Numeric" required="true" default="1">

	<cfset arguments.productItem.setProductId( arguments.productId )>

	<cfset components = productItemSvc.getComponentService().list( productItemId = productItem.getId() )>

	<cfset var newProductItemId = productItemSvc.create( arguments.productItem )>

	<cfoutput>
		#level# #arguments.productItem.getId()# #arguments.productItem.getAttribute().getName()#:
				#arguments.productItem.getAttributeValue().getRawValue().getName()#
		comp: #( components.len() GT 0 ? "--#components.len()#--" : 0 )#
	</cfoutput><br>

	<cfset var productItem = productItemSvc.get( newProductItemId )>

	<cfloop array="#components#" item="component">

		<cfset newComponent = Duplicate( component )>
		<cfset newComponent.setId("")>
		<cfset newComponent.getProductItem().setId( newProductItemId )>
		
		<cfset componentSvc.create( newComponent )>
	</cfloop>

	<cfif arguments.productItem.getChildren().len()>
		
		<cfloop array="#arguments.productItem.getChildren()#" item="child">

			<cfset child.getOrigin().setId( newProductItemId )>

			<cfset createProductItem( productItem = child, level = arguments.level + 1, productId = arguments.productId )>
		
		</cfloop>
	
	</cfif>

</cffunction>

<cfset cacheMgr.removeAll()>

