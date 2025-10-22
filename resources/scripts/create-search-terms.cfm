<!--- https://cfscript.me/ ---->

<cfsetting requestTimeOut="99999999999999">

<cfset containter = server["wirebox-apirone"]>
<cfset svc = containter.getInstance("ProductService")>

<cfquery name="q" datasource="apirone">
    SELECT 
		products.product_id::varchar 
    FROM products
	ORDER BY products.created_at DESC
    --LIMIT 1000
</cfquery>

<cfdump var="#q.recordCount#">

<cfoutput query="q">

    <cfset product = svc.get( q.product_id )>

    <cfset term = "">

    #product.getId()#<br>

    <cfif !IsNull( product.getCategory() )>
        <cfset term = term & product.getCategory().getName() & " ">
    </cfif>

    <cfif !IsNull( product.getLine() )>
        <cfset term = term & product.getLine().getName() & " ">
    </cfif>

    <cfif !IsNull( product.getModel() )>
        <cfset term = term & product.getModel().getName() & " ">
    </cfif>

    <cfif !IsNull( product.getFinish() )>
        <cfset term = term & product.getFinish().getName()>
    </cfif>

    <cfquery name="j" datasource="apirone">
        INSERT INTO utils.search_terms (
            search_term,
            product_id,
            lang_id
        )
        VALUES (
            '#term#',
            '#product.getId()#'::uuid,
            'IT'
        );
    </cfquery>

</cfoutput>


<!---
<cfquery name="q" datasource="apirone">
    SELECT 
		products.product_id::varchar, 
		
        text_line.line_id::varchar, 
		text_finish.finish_id::varchar, 
		text_model.model_id::varchar, 
		text_category.product_category_id,
        
        text_line.text AS text_line,
        text_model.text AS text_model,
        text_category.text AS text_category,
        text_finish.text AS text_finish
    FROM products
    	INNER JOIN catalog_bundles USING (catalog_bundle_id)
    		INNER JOIN lines ON catalog_bundles.line_id = lines.line_id
                INNER JOIN texts text_line ON text_line.line_id = lines.line_id AND text_line.lang_id = 'IT'
    		
            INNER JOIN models ON catalog_bundles.model_id = models.model_id
                INNER JOIN texts text_model ON text_model.model_id = models.model_id AND text_model.lang_id = 'IT'

    		INNER JOIN product_categories ON product_categories.product_category_id = catalog_bundles.product_category_id
                INNER JOIN texts text_category ON text_category.product_category_id = text_category.product_category_id AND text_category.lang_id = 'IT'
    	
        INNER JOIN finishes ON products.finish_id = finishes.finish_id
	        INNER JOIN texts text_finish ON text_finish.finish_id = text_finish.finish_id AND text_finish.lang_id = 'IT'

	ORDER BY products.created_at desc
	LIMIT 5
</cfquery>
---->