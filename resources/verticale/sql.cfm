<cfquery name="q" datasource="verticale">
    SELECT
        *
    FROM
    azapi_codtip
</cfquery>
<cfdump var="#q#">

<cfquery name="q" datasource="verticale">
    SELECT
        *
    FROM
        anasta
</cfquery>
<cfdump var="#q#">

<cfquery name="k" datasource="verticale">
    SELECT TOP 5
        *
    FROM
        azapi_artico a 
            LEFT JOIN azapi_codtip t 
                ON a.artipmat = t.codtip
    where arsemlav='A'
</cfquery>
<cfdump var="#k#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_codtip 
</cfquery>
<cfdump var="#j#">

<cfquery name="x" datasource="verticale">
    SELECT
    *
    FROM
    SYSOBJECTS
    WHERE
    xtype = 'U'
        AND name not like 'xxx_%'
    order by 1
</cfquery>
<cfdump var="#x#">


<cfquery name="v" datasource="verticale">
    SELECT
        *
    FROM
        azapi_codvar
</cfquery>
<cfdump var="#v#">


<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_proiva
</cfquery>
<cfdump var="#j#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        codiva
</cfquery>
<cfdump var="#j#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        codpag
</cfquery>
<cfdump var="#j#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        trcpag
</cfquery>
<cfdump var="#j#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_colori
</cfquery>
<cfdump var="#j#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_codvar
    WHERE varcod = 'LEV-AVIO'
</cfquery>
<cfdump var="#j#">
