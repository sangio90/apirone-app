component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.title = "Ordini";

        var data = super.service("DocumentItem").search();

        prc.list = prepare( data );

        event.setView('sale/list');

    }
    
    function print( event, rc, prc ){

        //cfcontent( type="application/pdf" );
        //cfheader( name="Content-Disposition", value="attachment;filename=example.pdf" );

        var data = super.service("DocumentItem").search();

        prc.printParams.title = 'Lista dei movimenti';

        prc.list = prepare( data );

        event.setView( "sale/table-rows" ).setLayout( "print" );

    }
    
    private function prepare( required Struct data ){

        var ret = {}

        for ( var item in arguments.data.getData() ) {

            var companyId = item.getProduct().getCompany().getId();

            if ( StructKeyExists( ret, companyId ) ){

                ret[ companyId ].add( item );
            
            } else {
                
                ret.insert( companyId, [ item ] );
            
            }

        }       
        
        return ret;

    }

}
