<cfset art="CRPOLDO000VERNI">   <!--- senza varianti --->
<cfset art="LAV-ASSEMBLBINS">   <!--- con colore senza variante --->
<cfset art="LAV-PL-GRAFICA">    <!--- senza colore con varianti --->
<cfset art="LAV-INCISIONE1">    <!--- con varianti e colori  --->

LAV-VERNPOLVLIS

<cfquery name="i" datasource="verticaleExport">
    SELECT * FROM INFORMATION_SCHEMA.TABLES;
</cfquery>

<cfdump var="#i#">
<cfabort>

<cfquery name="i" datasource="verticale">
    SELECT TOP 10 *
    FROM azapi_listin
</cfquery>

<cfdump var="#i#">
<cfabort>


<cfquery name="i" datasource="verticale">
    SELECT lisart, liscvr, liscol, lispre
    FROM azapi_listin
    WHERE lisart='LAV-VERNPOLVMET'
    ORDER BY lisart, liscvr, liscol
</cfquery>

<cfdump var="#i#">
<cfabort>


<cfset dao = new com.apirone.core.model.dao.ColorDAO()>

<cfquery name="i" datasource="verticale">
    SELECT *
    FROM azapi_artico
    WHERE 1=1 
        AND arcodart = 'MATACOFELDIAM18' 
    --ORDER BY arcodart 
</cfquery>

<cfdump var="#i#">
<cfabort>
<cfquery name="i" datasource="verticale">
    SELECT *
    FROM azapi_codvar AS codvar 
        INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod 
    WHERE 1=1 
        AND comvar.cbcodart = 'MATLASOTTGREZZO' 
    --ORDER BY arcodart 
</cfquery>

<cfdump var="#i#">

<cfquery name="j" datasource="verticale">
    SELECT *
    FROM azapi_codvar AS codvar 
        INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod 
    WHERE 1=1 
        AND comvar.cbcodart = 'MATLASOTTGREZZO' 
    --ORDER BY arcodart 
</cfquery>

<cfdump var="#j#">

<cfabort>

<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_colori AS colori
        INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    WHERE 1=1
        AND comcol.clcodart = 'MATTPZMOQCARREL' 
</cfquery>

<cfdump var="#k#">

<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_cvrcom AS cc
        --INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    WHERE 1=1
        AND cc.clcodart = 'MATTPZMOQCARREL' 
</cfquery>

<cfdump var="#k#">

<cfabort>

<cfquery name="k" datasource="verticale">
    SELECT TOP 20
      *
    FROM
    azapi_listin
    order by 1
</cfquery>

<cfquery name="j" datasource="verticale">
    SELECT TOP 20
      *
    FROM
    azapi_deflis
    order by 1
</cfquery>

<cfdump var="#j#">
<cfdump var="#k#">
<!--- listino acquisto in dollari  ---->
<cfabort>


<cfset art = "MATLASOTTGREZZO,MATLASOTTCRUDO,MATLASFENIX,MATLASPLAPOLIST,LAV-PULSATINA">

        <cfquery name="n" datasource="verticale" result="result">
            SELECT DISTINCT arunmis1
            FROM
                azapi_artico
            WHERE 1=1
                --AND trim(arunmis1) = '1'
            ORDER BY 1
        </cfquery>

        <cfdump var="#n#">


<cfoutput>
    <cfloop list="#art#" item="item">

        <h3>Articolo #item#</h3>
        <cfquery name="n" datasource="verticale" result="result">
            SELECT
                TOP 5
                arcodart,
                arsemlav,
                artipmat,
                arcodart,
                ardesart,
                artipmat,
                *
            FROM
                azapi_artico a
            WHERE 1=1
                AND arcodart = '#item#'
        </cfquery>

        <cfdump var="#n#">
        <cfdump var="#result#">

        <h3>Varianti</h3>
        <cfquery name="j" datasource="verticale">
            SELECT *
            FROM azapi_codvar AS codvar 
                INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod 
            WHERE 1=1 
                AND comvar.cbcodart = '#item#' 
            --ORDER BY arcodart 
        </cfquery>

        <cfdump var="#j#">

        <h3>Colori</h3>
        <cfquery name="k" datasource="verticale">
            SELECT *
            FROM azapi_colori AS colori
                INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
            WHERE 1=1
                AND comcol.clcodart = '#item#' 
        </cfquery>
        <cfdump var="#k#">

    </cfloop>
</cfoutput>


<cfabort>

<cfquery name="n" datasource="verticale" result="result">
<!------
    SELECT *
    FROM
        azapi_artico a 
    where arcodart = '#art#'
---->
    SELECT
        arcodart,
        arsemlav,
        artipmat,
        arcodart,
        ardesart,
        artipmat,
        IIF (artipmat = 'LAV', 'LV', 'MP') AS processiong_type_id
    FROM
        azapi_artico a
    WHERE 1=1
        AND arcodart = '#art#'
        --AND ardesart LIKE '%#art#%'
</cfquery>

<cfdump var="#n#">
<cfdump var="#result#">


<h3>Varianti</h3>
<cfquery name="j" datasource="verticale">
    SELECT *
    FROM azapi_codvar AS codvar 
        INNER JOIN azapi_comvar AS comvar ON comvar.cbcodvar = codvar.varcod 
    WHERE 1=1 
        AND comvar.cbcodart = '#art#' 
    --ORDER BY arcodart 
</cfquery>

<cfdump var="#j#">

<h3>Colori</h3>
<cfquery name="k" datasource="verticale">
    SELECT *
    FROM azapi_colori AS colori
        INNER JOIN azapi_comcol AS comcol ON comcol.clcodcol = colori.clcodice
    WHERE 1=1
        AND comcol.clcodart = '#art#' 
</cfquery>

<cfdump var="#k#">

<cfabort>

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
