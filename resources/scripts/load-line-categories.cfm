-- remove cfabort
<cfabort>
<cfscript>
    model = server["wirebox-apirone"];
    svc = model.getInstance("ProductCategoryService");

    csvfile = FileRead( ExpandPath("/resources/data/categories.csv.cfm") );

    cfloop( index="line" list="#csvfile#" delimiters="#chr(10)##chr(13)#" ) {

        code = listFirst( line, ";" );
        name = listLast( line, ";" );

        category = new com.apirone.core.model.bean.ProductCategory();
    
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