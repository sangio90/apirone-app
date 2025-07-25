<cfquery name="q" datasource="apirone">
    SELECT
        line_id::varchar, categories::varchar
    FROM
        lines
    WHERE 1=1
            AND categories @> ANY ('{[22],[7]}')
    ORDER BY
        line_id
</cfquery>

<cfdump var="#q#">