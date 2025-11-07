<cfcomponent extends="com.apirone.core.model.dao.AbsDAO" accessors="true">
	<cffunction name="read" returntype="Query">
		<cfargument name="exportCodeId" type="Numeric" required="true">

		<cfquery name="local.q" datasource="apirone">
			SELECT
			    product_category_id,
				line_id::varchar,
				model_id::varchar,
				finish_id::varchar,
				product_id::varchar,
				*
			FROM
				export_codes
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeId#">
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="find" returntype="Query">
		<cfargument name="categoryId" type="Numeric">
		<cfargument name="lineId" type="String">
		<cfargument name="modelId" type="String">
		<cfargument name="finishId" type="String">
		<cfargument name="productId" type="String">
		<cfargument name="str" type="String">

		<cfargument name="orderby" required="true" type="String" default="product.product_id">
		<cfargument name="limit" required="true" type="Numeric" default="15">
		<cfargument name="offset" required="true" type="Numeric" default="0">

		<cfquery name="local.q" datasource="apirone" result="result">
			SELECT
				export_code_id,
				COUNT(export_code_id) OVER() AS total
			FROM
				export_codes

			WHERE 1=1

				<cfif !IsNull( arguments.str )>
					AND export_code ILIKE <cfqueryparam cfsqltype="varchar" value="%#arguments.str#%">
				</cfif>

				<cfif !IsNull( arguments.categoryId )>
					AND product_category_id = <cfqueryparam cfsqltype="Integer" value="#arguments.categoryId#">
				</cfif>

				<cfif !IsNull( arguments.lineId )>
					AND line_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.lineId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.modelId )>
					AND model_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.modelId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.finishId )>
					AND finish_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.finishId#">::uuid
				</cfif>

				<cfif !IsNull( arguments.productId )>
					AND product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
				</cfif>

			ORDER BY
				export_code ASC

			<cfif arguments.limit GTE 0>
				LIMIT
					<cfqueryparam cfsqltype="integer" value="#arguments.limit#">
				OFFSET
					<cfqueryparam cfsqltype="integer" value="#arguments.offset#">
			</cfif>
		</cfquery>

		<cfreturn local.q>
	</cffunction>

	<cffunction name="insert" returntype="String">
		<cfargument name="exportCode" type="com.apirone.core.model.bean.ExportCode" required="true">
			
		<cfquery name="local.q" datasource="apirone">
			INSERT INTO export_codes (
				export_code,
				product_category_id,
				line_id,
				model_id,
				finish_id,
				product_id
			)
			VALUES (
				<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getName()#">,
				<cfqueryparam cfsqltype="Integer" value="#arguments.exportCode.getCategory().getId()#">,
				<cfqueryparam cfsqltype="varchar" value="#arguments.exportCode.getLine().getId()#">::uuid,
				<cfif !IsNull( arguments.exportCode.getModel() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.getModel().getId()#">::uuid
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.exportCode.getFinish() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getFinish().getId()#">::uuid,
				<cfelse>
					NULL
				</cfif>
				,
				<cfif !IsNull( arguments.exportCode.getProduct() )>
					<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getProduct().getId()#">::uuid,
				<cfelse>
					NULL
				</cfif>
			) RETURNING export_code_id
		</cfquery>

		<cfreturn local.q.export_code_id>
	</cffunction>

	<cffunction name="update" returntype="String">
		<cfargument name="exportCode" type="com.apirone.core.model.bean.ExportCode" required="true">

		<cfquery name="local.q" datasource="apirone">
			UPDATE
				export_codes
			SET
				export_code = <cfqueryparam cfsqltype="Varchar" value="#Trim( arguments.exportCode.getName() )#">,
				product_category_id =
					<cfif !IsNull( arguments.exportCode.getCategory() )>
						<cfqueryparam cfsqltype="Numeric" value="#arguments.exportCode.getCategory().getId()#">
					<cfelse>
						NULL
					</cfif>
				,
				line_id =
					<cfif !IsNull( arguments.exportCode.getLine() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getLine().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				model_id =
					<cfif !IsNull( arguments.exportCode.getModel() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getModel().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				finish_id =
					<cfif !IsNull( arguments.exportCode.getFinish() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getFinish().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
				,
				product_id =
					<cfif !IsNull( arguments.exportCode.getProduct() )>
						<cfqueryparam cfsqltype="Varchar" value="#arguments.exportCode.getProduct().getId()#">::uuid
					<cfelse>
						NULL
					</cfif>
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCode.getId()#">
		</cfquery>

		<cfreturn arguments.exportCode.getId()>
	</cffunction>

	<cffunction name="delete" returntype="Boolean">
		<cfargument name="exportCodeId" type="Numeric">

		<cfquery name="local.q" datasource="apirone">
			DELETE
			FROM export_codes
			WHERE
				export_code_id = <cfqueryparam cfsqltype="Numeric" value="#arguments.exportCodeId#">
		</cfquery>

		<cfreturn true>
	</cffunction>
</cfcomponent>
