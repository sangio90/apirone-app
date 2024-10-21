<cfset colors = DESerializeJSON( FileRead( ExpandPath("/config/data/systemColors.json.cfm") ) )>

<cfset classes = "/* Don't change this file, automatically created by systemColors.json. Created at #now()# */">

<cfoutput>
<cfloop array="#colors#" index="color"> 
    <cfsavecontent variable="element">

/* #color.id# */
.#color.class# {
    background-color: #color.hex#;
}
    </cfsavecontent>
    <cfset classes = classes & element>
</cfloop>

<cfset FileWrite( ExpandPath("/assets/main/css/colors.css"), classes )>

<p>File created in #ExpandPath("/assets/main/css/colors.css")#</p>

<cfdump var="#classes#">

</cfoutput>
