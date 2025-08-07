<cfcomponent>

	<cffunction name="cropSquare">

		<cfargument name="source" required="Yes">
		<cfargument name="destination" required="Yes">
		<cfargument name="quality" required="Yes" default="90">
		<cfargument name="imgPath" required="Yes" default="#arguments.source#">
		<cfargument name="newWidth" required="Yes">

		<cfset dimensioni = application.services.Image.getDimensions(imgPath="#arguments.imgPath#")>
		<cfset sourceForRemodel = "#destination#"> 

		<cfif dimensioni.width GTE dimensioni.height> 
			<!--- orizzontale --->
			<cfset var x = Int((dimensioni.width-dimensioni.height)\2)>
			<cf_magicktag inputtype="file" inputfile="#arguments.source#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#">
				<cf_magickaction action="crop" width="#dimensioni.height#" height="#dimensioni.height#" xoffset="#x#">
			</cf_magicktag>
			<cf_magicktag inputtype="file" inputfile="#arguments.destination#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#">
				<cf_magickaction action="quality" value="90">
				<cf_magickaction action="geometry" width="#arguments.newWidth#" height="#arguments.newWidth#">
			</cf_magicktag>
			<!--- <cfexecute name="/usr/bin/jhead" arguments="-purejpg #destination#" outputFile="/tmp/jhead_output.txt" timeout="1"></cfexecute> ---->
		<cfelse> 
			<!--- verticale --->
			<cfset var y = Int((dimensioni.height-dimensioni.width)\2)>
			<cf_magicktag inputtype="file" inputfile="#arguments.source#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#">
				<cf_magickaction action="crop" width="#dimensioni.width#" height="#dimensioni.width#" yoffset="#y#">
			</cf_magicktag>
			<cf_magicktag inputtype="file" inputfile="#destination#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#">
				<cf_magickaction action="quality" value="#arguments.quality#">
				<cf_magickaction action="geometry" width="#arguments.newWidth#" height="#arguments.newWidth#">
			</cf_magicktag>
			<!---- <cfexecute name="/usr/bin/jhead" arguments="-purejpg #arguments.destination#" outputFile="/tmp/jhead_output.txt" timeout="1"></cfexecute> ---->
		</cfif>

	</cffunction>

	<cffunction name="remodel">

		<cfargument name="source" required="Yes">
		<cfargument name="destination" required="Yes">
		<cfargument name="newWidth" required="Yes">

		<cf_magicktag inputtype="file" inputfile="#source#" timeout="100" action="convert" outputType="file" outputFile="#destination#">
			<cf_magickaction action="quality" value="90">
			<cf_magickaction action="geometry" width="#newWidth#">
		</cf_magicktag>

		<!---- <cfexecute name="/usr/bin/jhead" arguments="-purejpg #destination#" outputFile="/tmp/jhead_output.txt" timeout="1"></cfexecute> ---->
	
	</cffunction>

	<cffunction name="cropRectangle">
		<!--- per foto 800x600 --->
		<cfargument name="source" required="Yes">
		<cfargument name="destination" required="Yes">
		<cfargument name="quality" required="Yes" default="90">
		<cfargument name="imgPath" required="Yes" default="#source#">
		<cfargument name="newWidth" required="Yes">
		<cfargument name="newHeight" required="Yes">
		<cfargument name="debug" required="yes" default="No">
		<cfset dim = application.services.Image.getDimensions(imgPath="#arguments.source#")>
		<cfset rappImmagineTarget = newWidth/newHeight>
		<cfset rappImmagineCorrente = dim.width/dim.height>
		<cfif rappImmagineTarget GT rappImmagineCorrente>
			<cf_magicktag inputtype="file" inputfile="#arguments.source#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#" debug="#arguments.debug#">
				<cf_magickaction action="quality" value="#arguments.quality#">
				<cf_magickaction action="geometry" width="#arguments.newWidth#">
			</cf_magicktag>
			<cfset dimensioni = application.services.Image.getDimensions(imgPath="#arguments.destination#")>
			<cfset yoffset=Int((dimensioni.height-arguments.newHeight)\2)>
			<cf_magicktag inputtype="file" inputfile="#arguments.destination#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#" debug="#arguments.debug#">
				<cf_magickaction action="crop" height="#arguments.newHeight#" width="#arguments.newWidth#" yoffset="#yoffset#" debug="#arguments.debug#">
			</cf_magicktag>
		<cfelse>
			<cf_magicktag inputtype="file" inputfile="#arguments.source#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#" debug="#arguments.debug#">
				<cf_magickaction action="quality" value="#arguments.quality#">
				<cf_magickaction action="geometry" height="#arguments.newHeight#" width="1000">
			</cf_magicktag>
			<cfset dimensioni = application.services.Image.getDimensions(imgPath="#arguments.destination#")>
			<cfset xoffset=Int((dimensioni.width-arguments.newwidth)\2)>
			<cf_magicktag inputtype="file" inputfile="#arguments.destination#" timeout="100" action="convert" outputType="file" outputFile="#arguments.destination#" debug="#arguments.debug#">
				<cf_magickaction action="crop" height="#arguments.newHeight#" width="#arguments.newWidth#" xoffset="#xoffset#" debug="#arguments.debug#">
			</cf_magicktag>
		</cfif> 
		<cfset stripExifData(source="#arguments.destination#")>
	</cffunction>

	<cffunction name="stripExifData">
		<cfargument name="source" required="Yes">
		<cftry>
			<!---- <cfexecute name="/usr/bin/jhead" arguments="-purejpg #arguments.source#" outputFile="/tmp/jhead_output.txt" timeout="1"></cfexecute> ---->
			<cfcatch></cfcatch>
		</cftry>
	</cffunction>
	
</cfcomponent>
