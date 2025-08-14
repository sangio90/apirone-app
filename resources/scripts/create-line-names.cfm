-- remove cfabort
<cfabort>

<!---
    move name  to translations
--->

<cfscript>
    model = server["wirebox-apirone"];
    svc = model.getInstance("LineService");

    ```
    <cfquery datasource="apirone" name="q">
        SELECT * FROM lines oRDER BY code;
    </cfquery>
    ```

    for( record in q ) {

        obj = svc.get( record.line_id.toString() );

        text = new com.apirone.core.model.bean.Text();
        status = new com.apirone.core.model.bean.Status();
        lang = new com.apirone.core.model.bean.Lang();

        text.setLang( lang.setId( "IT" ) );
        text.setStatus( status.setId( "ACT" ) );

        //text.setId( json.nameItem.id );
        text.setName( record.line );

        obj.setTexts( [ text ] );

        svc.update( obj );

        echo( "Ho aggiornato: #record.code#<br>" );

    }
</cfscript>