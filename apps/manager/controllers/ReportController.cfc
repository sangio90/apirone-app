component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.title = "Lista dei report";

        //prc.list = super.fire( "report.list" );

        prc.jsScripts.add( "app-report" );

        event.setView("report/list");

    }
    
    function get( event, rc, prc ){

        var report = super.fire( "report.get", [ rc.id ] );
        
        prc.title = "Report < #report.getName()# >";

        prc.jsScripts.add( "app-report" );

        //var document = DESerializeJSON( FileRead( '/assets/main/examples/example-#report.getId()#.json.cfm' ) );
        var document = DESerializeJSON( "/assets/main/examples/data/report-1.json.cfm" );
       
        var example = {
            "meta" = {
                "file": "#report.getFilename()#",
                "fileName": "file_name_of_generated_report.pdf",
                "title": "#report.getName()#",
                "date": "#DateFormat( now(), 'yyyy-mm-dd HH:nn:ss')#"
            }, 
            "document": document
        }

        report.setExampleData( SerializeJSON( example ) );

        prc.report = report;

        /*
        switch ( rc.id ) {
            case 1:


                
                break;
            default:

                abort showerror="Ciao";
        }
        */

        event.setView("report/detail");

    }
    
}
