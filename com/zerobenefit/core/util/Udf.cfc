<cfcomponent>
    <cffunction name="prettyString" access="public" returntype="string" hint="Replaces all evil characters from a string with pretty ones. Usefull for SEO Url." output="No">
        <cfargument name="str" type="string" required="yes">
        <cfset arguments.str = REReplaceNoCase(arguments.str,"<[^>]*>", "","ALL")>
        <cfset arguments.str = LCase(arguments.str)>
        <cfset arguments.str = RTrim(arguments.str)>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(224)#,#chr(225)#,#chr(226)#,#chr(227)#,#chr(228)#,#chr(229)#,#chr(193)#,#chr(194)#,#chr(195)#,#chr(196)#,#chr(197)#,#chr(192)#", "a,a,a,a,a,a,a,a,a,a,a,a")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(128)#,#chr(200)#,#chr(201)#,#chr(202)#,#chr(203)#,#chr(232)#,#chr(233)#,#chr(234)#,#chr(235)#", "e,e,e,e,e,e,e,e,e")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(204)#,#chr(205)#,#chr(206)#,#chr(207)#,#chr(236)#,#chr(237)#,#chr(238)#,#chr(239)#", "i,i,i,i,i,i,i,i")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(210)#,#chr(211)#,#chr(212)#,#chr(213)#,#chr(214)#,#chr(215)#,#chr(216)#,#chr(240)#,#chr(241)#,#chr(242)#,#chr(243)#,#chr(244)#,#chr(245)#,#chr(246)#", "o,o,o,o,o,o,o,o,o,o,o,o,o")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(181)#,#chr(217)#,#chr(218)#,#chr(219)#,#chr(220)#,#chr(249)#,#chr(250)#,#chr(251)#,#chr(252)#", "u,u,u,u,u,u,u,u,u")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(131)#", "f")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(138)#,#chr(154)#", "s,s")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(142)#,#chr(158)#", "z,z")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(159)#,#chr(165)#,#chr(153)#,#chr(155)#,#chr(221)#,#chr(253)#,#chr(255)#", "y,y,y,y,y,y,y")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(162)#,#chr(199)#,#chr(231)#", "c,c,c")>
        <cfset arguments.str = ReplaceList(arguments.str, "#chr(209)#,#chr(241)#", "n,n")>
        <cfset arguments.str = REReplace(arguments.str, "[^A-Za-z0-9\-\s]", "", "ALL")>
        <cfset arguments.str = Trim(arguments.str)>
        <cfset arguments.str = REReplace(arguments.str, "\s+", " ", "ALL")>
        <cfset arguments.str = Replace(arguments.str, " ", "-", "ALL")>
        <cfset arguments.str = REReplace(arguments.str, "-{1,4}", "-", "ALL")>
        <cfreturn arguments.str>
    </cffunction>


    <cfscript>
        String function pad(string, count, char ) {
        
            var strLen = Len(arguments.string);
            var padLen = arguments.count - strLen;
            
            if ( padLen LTE 0 ) {

                return arguments.string;

            } else {

                return RepeatString(arguments.char, padLen) & arguments.string;

            }
        
        }
    </cfscript>


    <cffunction name="getUniqueID" returntype="numeric">
        
		<cfquery name="q" datasource="zerobenefit">
			SELECT nextval('uniqueid_seq') AS unique_id
		</cfquery>

		<cfreturn q.unique_id>
	</cffunction>

</cfcomponent>
