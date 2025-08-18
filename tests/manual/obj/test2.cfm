<cfset model = server["wirebox-apirone"]>

<cfset obj = model.getInstance("com.apirone.core.model.bean.Line")>

<cfdump var="#obj.exposeMixin()#">