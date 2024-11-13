--
<cfabort>
<cfscript>
    model = server["wirebox-apirone"];
    svc = model.getInstance("LineCategoryService");

    csvfile = FileRead( ExpandPath("/resources/data/categories.csv.cfm") );

    cfloop( index="line" list="#csvfile#" delimiters="#chr(10)##chr(13)#" ) {

        code = listFirst( line, ";" );
        name = listLast( line, ";" );

        category = new com.apirone.core.model.bean.LineCategory();
        /*
        status = new com.apirone.core.model.bean.Status();
        text = new com.apirone.core.model.bean.Text();
        lang = new com.apirone.core.model.bean.Lang();
        */
    
        row = {
            code: code,
            status: {
                id: "ACT"
            },
            texts: [
                {
                    lang: {
                        id: "IT"
                    },
                    name: name
                }
            ]
        }
    
        category.setMemento( row );
        
        svc.create( category );        

    }
</cfscript>