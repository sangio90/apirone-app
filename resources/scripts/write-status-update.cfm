<cfoutput>

    <cfquery name="q" datasource="apirone">
        SELECT *
        FROM statuses
        ORDER BY status_id
    </cfquery>

    <cfloop query="q">
		UPDATE statuses SET status='#q.status#', entities='#q.entities#', orderby='#q.orderby#', color_id='#q.color_id#' WHERE status_id='#q.status_id#';<br>
    </cfloop>

</cfoutput>