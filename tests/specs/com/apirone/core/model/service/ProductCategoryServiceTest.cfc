component extends="testbox.system.BaseSpec"{

    function setup(){

        variables.startStrings = [ "_F", "_D", "*H", "*K" ];

        variables.wirebox = new wirebox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "ProductCategoryService" );
        var cm = variables.wirebox.getInstance( "CacheManager" );
        variables.helpers = new tests.utils.Helpers();

        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }
    

    function get_test(){

        var data = variables.helpers.createProductCategory();

        variables.svc.create( data.obj );

        var cat = variables.svc.get( data.raw.id );

        $assert.isTrue( 
            ( cat.getId() EQ data.raw.id ) 
            AND ( cat.getName() EQ data.raw.name ) 
            AND ( cat.getStatus().getId() EQ data.raw.status.id ) 
        );

        variables.svc.delete( data.raw.id );
                
    }
    
    function create_test(){

        var data = variables.helpers.createProductCategory();
        
        variables.svc.create( data.obj );

        var cat = variables.svc.get( data.raw.id );

        $assert.isTrue( ( cat.getId() EQ data.raw.id ) AND ( cat.getName() EQ data.raw.name ) );

        variables.svc.delete( data.raw.id );
 
    }


    function update_test(){

        var data = variables.helpers.createProductCategory();

        variables.svc.create( data.obj );

        var cat = variables.svc.get( data.raw.id );

        $assert.isTrue( ( cat.getId() EQ data.raw.id ) AND ( cat.getName() EQ data.raw.name ) );

        variables.svc.delete( data.raw.id );
 
    }
        
    function nameExists_test(){

        var data = variables.helpers.createProductCategory();

        variables.svc.create( data.obj );

        var exists = variables.svc.nameExists( data.raw.name );
        
        $assert.isTrue( exists );

        variables.svc.delete( data.raw.id );
                
    }

    function search_test(){

        var rows = [];
        var start = variables.startStrings[ RandRange( 1, 4 ) ];
        var count = RandRange(1, 4);
        var index = "";

        cfloop( from=1, to=count, index="index" ) {

            var data = variables.helpers.createProductCategory( startWith=start );

            variables.svc.create( data.obj );

            rows.add( data );

        }

        /*
            aggiungendo un { limit = 1 } non funziona più
        */
        var result = variables.svc.search( str=start, limit=count, orderby = [ { field = 'category.status' } ] );

        echo( "#result.getCount()# EQ #count# AND #result.getData().len()# EQ #count#" );
        $assert.isTrue( result.getCount() == count AND result.getData().len() == count );

        cfloop( array=rows, index="index" ) {
            variables.svc.delete( index.raw.id );
        }
                
    }

    function list_test(){

        var rows = [];
        var start = variables.startStrings[ RandRange( 1, 4 ) ];
        var count = RandRange(1, 4);
        var index = "";

        cfloop( from=1, to=count, index="index" ) {

            var data = variables.helpers.createProductCategory( startWith=start );

            variables.svc.create( data.obj );

            rows.add( data );

        }

        /*
            aggiungendo un { limit = 1 } funziona ugualmente
        */
        var result = variables.svc.list( str = start, orderby = [ { field = 'category.status' } ], limit = 1 ).getData()

        cfloop( array=rows, index="index" ) {
            variables.svc.delete( index.raw.id );
        }
                
    }


}