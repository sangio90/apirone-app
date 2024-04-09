<cfparam name="attributes.type" default="js">
<cfparam name="attributes.destination" default="">
<cfparam name="attributes.files" default="#ArrayNew(1)#">
<cfparam name="attributes.name" default="assets">
<cfparam name="attributes.salt" default="a1">

<cfset key = Hash( attributes.destination & SerializeJson(attributes.files) & attributes.salt)>

<cfset fileName = attributes.name & attributes.type & '_' & key & '.' & attributes.type>

<cfif !FileExists( attributes.destination & "/" & fileName )>

	<cfset sep = "">
	<cfset cr = Chr(13) & Chr(10)>

	<cfset output = "/* buildDate:#now()# */" & cr>

	<cfif attributes.type IS "js">
		<cfset sep = ";">
	</cfif>
	
	<cfloop array="#attributes.files#" index="myFile">
		
		<cffile action="read" file="#ExpandPath(myfile.file)#" variable="thisFile">
		
		<cfset output = output & '/* ' & 'fileName:' & myFile.file & ' */' & cr>
		
		<cfif structKeyExists(myFile, "replacements")>
			
			<cfloop array="#myFile.replacements#" index="replacement">
				
				<cfset thisFile = Replace(thisFile, replacement.find, replacement.replace, "ALL") & sep & cr>
			
			</cfloop>
		
		</cfif>
		
		<cfset output = output & thisFile & sep & cr>
	
	</cfloop>

	<cfset filePath = ExpandPath(attributes.destination) & '/' & fileName >

	<cfif !DirectoryExists( ExpandPath( attributes.destination ) )>
		<cfset DirectoryCreate( ExpandPath( attributes.destination ) )>
	</cfif>

	<cfif !FileExists( filePath ) >
	    <cffile action="write" file="#filePath#" output="#output#">
	</cfif>

</cfif>

<cfoutput>
	<cfif attributes.type IS "js">
		<script src="#attributes.destination#/#fileName#"></script>
	<cfelse>
		<link rel="stylesheet" href="#attributes.destination#/#fileName#" type="text/css" />
	</cfif>
</cfoutput>

