<cfcomponent extends="com.apirone.core.controller.AbsController">

    <cffunction name="sendMessage" returntype="Struct">

        <cfif ( (form.add1 + form.add2) EQ form.result ) AND !Len( form.company )>

            <cfset var data = { "response" = "success" }>
            <cfset var message = "MESSAGE_SENT;#SerializeJSON(form)#">

            <cfmail from="#form.email#" to="info@apirone.it" bcc="roberto.marzialetti@gmail.com" subject="[apirone.it] contatto del sito" type="HTML">

                <cfdump var="#form#">
                <br>
                ip: #cgi.remote_addr#
                <br>
                #now()#
    
            </cfmail>
    
        <cfelse>

            <cfset var data = { "response" = "error" }>
            <cfset var message = "SPAMMER [#form.add1#+#form.add2#=#form.result#];#SerializeJSON(form)#">

        </cfif>

        <cfset path = ExpandPath('/') & "../repository/logs/">
    
        <cfif !DirectoryExists( path )>
            <cfset DirectoryCreate( path )>
        </cfif>

        <cffile file="#path#/email.log" action="append" output="#cgi.remote_addr#;#now()#;#message#">

        <cfset event.setValue( "result", data )>

    </cffunction>

</cfcomponent>
