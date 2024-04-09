<!--------
    REPORT:
        - se si usa il CreateUUID() bisogna formattarlo nel modo opportuno in lettura
        - bisogna usare il .toString() nel servizio (non basta il cast ::text con lo stesso nome)
        - usare il cast ::text (o ::uuid) anche in lettura sul where o usare il tipo dato "other". vedi esempio)
        - vanno ricostruiti tutti gli id delle tabelle "geo"
        - nel dump UUID è una stringa
--------->

<!---- SQL
    CREATE TABLE public._test_uuid (
        field_uuid UUID DEFAULT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring),
        field VARCHAR(3)
    ) ;
---->

<cfquery datasource="zerobenefit">
    INSERT INTO _test_uuid (field)
    VALUES ( 'aut' )
</cfquery>

<cfquery datasource="zerobenefit" name="q">
    SELECT *, field_uuid::text AS field_uuid
    FROM _test_uuid
    LIMIT 1
</cfquery>

<cfdump var="#q.field_uuid#">
<cfabort>

<cfquery datasource="zerobenefit" result="d">
    UPDATE _test_uuid
    SET field = '#RandRange(100, 888)#'
    WHERE  
        field_uuid = <cfqueryparam cfsqltype="other" value="#q.field_uuid.toString()#">
        <!---
        funziona anche senza il toString()
            field_uuid = <cfqueryparam cfsqltype="varchar" value="#q.field_uuid#">::uuid
        funziona anche con l' [other] senza cast
            field_uuid = <cfqueryparam cfsqltype="other" value="#q.field_uuid#">
        ---->
</cfquery>

<cfdump var="#d#" label="Record update">
<cfdump var="#d.recordCount#" label="Record updated">

<cfabort>

<cfset cfUid = LCase( CreateUUID() )>

<!--- 
    quello di cf è da 35 e in maiuscolo, che nell'insert funziona ugualmente,
    ma non in lettura 
--->
<cfset uid = insert("-", cfUid, 23)>
<cfdump var="#uid#">

<!---- ##
    1. LETTURA 
## ---->

<cfquery datasource="zerobenefit" name="q">
    SELECT *, field_uuid::text AS field_u
    FROM _test_uuid
    LIMIT 1
</cfquery>

<!---
bisogna fare il toString()
oppure SELECT field_uuid::text AS f_uuid (nme diverso del campo)
---->
<cfdump var="#q.field_uuid.toString()#">
<cfdump var="#q.field_u#">


<!---- ##
    2. SCRITTURA CON CreateUUID()
## ---->

<!---  uuid in cf è maiuscolo, viene trasformato in minuscolo nell'insert --->
<cfquery datasource="zerobenefit">
    INSERT INTO _test_uuid (field_uuid)
    VALUES ( <cfqueryparam cfsqltype="other" value="#uid#"> )
</cfquery>


<!---- ##
    3. USANDO IL DEFAULT DEL CAMPO
## ---->

<cfquery datasource="zerobenefit" name="j">
    INSERT INTO _test_uuid (field)
    VALUES ( 'a' ) RETURNING field_uuid
</cfquery>
<cfdump var="#j.field_uuid.toString()#" label="Generato dal default del campo">


<!---- ##
    4. UPDATE
## ---->

<cfquery datasource="zerobenefit" result="d">
    UPDATE _test_uuid
    SET field = '#RandRange(100, 888)#'
    WHERE  
        field_uuid::text = <cfqueryparam cfsqltype="char" value="#uid#">
    
    <!---
        OR
            field_uuid = <cfqueryparam cfsqltype="other" value="#uid#">
        OR
            field_uuid = <cfqueryparam cfsqltype="char" value="#uid#">::uuid
    ---->
</cfquery>

<cfdump var="#d#" label="Record update">
<cfdump var="#d.recordCount#" label="Record updated">
