<cfquery name="j" datasource="apirone">
    SELECT country_id, code
    FROM countries
    ORDER BY country
</cfquery>

<cfoutput query="j">
    UPDATE countries SET code='#j.code#' WHERE country_id='#j.country_id#';<br>
</cfoutput>


<!----
<cfloop file="#ExpandPath('/resources/data/country-codes.csv.cfm')#" item="item">

    <cfset name=ListFirst( item, "," )>
    <cfset code=ListLast( item, "," )>

    <cfquery name="j" datasource="apirone">
        SELECT country_id
        FROM countries
        WHERE UPPER( country ) = '#UCase( name )#'
    </cfquery>

    <cfif j.recordcount>

        <cfquery name="u" datasource="apirone">
            UPDATE countries
            SET code = '#UCase( code )#'
            WHERE country_id = '#j.country_id#'
        </cfquery>

    </cfif>

</cfloop>
---->