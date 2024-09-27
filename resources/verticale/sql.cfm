<cfdbinfo name="k" type="foreignkeys" datasource="verticale">
    <cfdump var="#k#">

    <cfabort>
    

<cfquery name="k" datasource="verticale">
    SELECT *
    FROM
        azapi_artico a 
            LEFT JOIN azapi_codtip t 
                ON a.artipmat = t.codtip
    where ardesart like '%croma%'
</cfquery>
<cfdump var="#k#">

<cfabort>


<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_codvar AS codvar 
        INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod 
    WHERE 1=1 AND comvar.cbcodart = 'LAV-PL-FRUTTI' 
</cfquery>
<cfdump var="#k#">
<cfabort>

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_colori AS colori
            INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    WHERE colori.clcodice = 'LAV-PL-PULITURA'
    ORDER BY CLCODART
</cfquery>
<cfdump var="#j#">

<cfabort>


<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_colori
</cfquery>
<cfdump var="#k#">

<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_codvar 
    AS codvar
</cfquery>
<cfdump var="#k#">
<cfabort>
    

<cfquery name="a" datasource="verticale">
    SELECT *
    FROM
        azapi_codtip a 
</cfquery>
<cfdump var="#a#">
<cfabort>

<cfquery name="k" datasource="verticale">
    SELECT *
    FROM
        azapi_artico a 
            LEFT JOIN azapi_codtip t 
                ON a.artipmat = t.codtip
    --where codtip='LAV'
</cfquery>
<cfdump var="#k#">

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_colori AS colori
            INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    WHERE colori.clcodice = 'LAV-VERNICIATUR'
    ORDER BY CLCODART
</cfquery>
<cfdump var="#j#">

<cfabort>



<cfquery name="k" datasource="verticale">
    SELECT
      *
    FROM
    azapi_listin
    order by 1
</cfquery>
<cfdump var="#k#">
<!--- listino acquisto in dollari  ---->
<cfabort>

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_analin AS linee
</cfquery>
<cfdump var="#j#">
<cfabort>


<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_colori AS colori
            INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    ORDER BY CLCODART
</cfquery>
<cfdump var="#j#">



<cfquery name="k" datasource="verticale">
SELECT
  *
FROM
azapi_listin
order by 1
</cfquery>
<cfdump var="#k#">
<!--- listino acquisto in dollari  ---->
<cfabort>

<cfquery name="k" datasource="verticale">
SELECT varcod, COUNT(vrcodice) OVER() AS total FROM azapi_codvar AS codvar INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod WHERE 1=1 AND comvar.cbcodart = 'LAV-ASS' ORDER BY arcodart OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY;
</cfquery>
<cfdump var="#k#">
<cfabort>

<cfquery name="k" datasource="verticale">
SELECT
  *
FROM
  azapi_comvar
</cfquery>
<cfdump var="#k#">
<cfabort>

<cfquery name="k" datasource="verticale">
    SELECT
      *
    FROM
    AZAPI_COMCOL
</cfquery>
<cfdump var="#k#">
    
<!----
<cfquery name="k" datasource="verticale">
SELECT
  *
FROM
  SYSOBJECTS
WHERE
  xtype = 'U'
ORDER BY name
</cfquery>
<cfdump var="#k#">
--->
<cfabort>

<cfquery name="k" datasource="verticale">
    SELECT
        CLCODICE, CLDESCRI
    FROM
    azapi_colori
</cfquery>
<cfdump var="#k#">



<cfabort>

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

<cfquery name="j" datasource="verticale">
    SELECT
        *
    FROM
        azapi_codvar
    WHERE varcod = 'LEV-AVIO'
</cfquery>
<cfdump var="#j#">
