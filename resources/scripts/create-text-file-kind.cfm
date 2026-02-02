cfabort
<cfabort>
<cfscript>
    model = server["wirebox-apirone"];
    svc = model.getInstance("TextService");

    rows = [
        {
            id: "horizontal",
            text: "Orizzontale"
        },
        {
            id: "vertical",
            text: "Verticale"
        },
        {
            id: "default",
            text: "Predefinita"
        }
    ];

    for( item in rows  ) {

        bean = new com.apirone.core.model.bean.Text();
        lang = new com.apirone.core.model.bean.Lang();
        entity = new com.apirone.core.model.bean.Entity();

        //bean.setId( item.id );
        bean.setName( item.text );

        entity.setKey( "fileKind.id" );
        entity.setValue( item.id );
        
        bean.setEntity( entity );
        bean.setLang( lang.setId( "IT" ) );
        
        svc.bulkCreate( [ bean ] );
    
    }
</cfscript>