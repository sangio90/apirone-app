component extends="tests.utils.AbsSpec"{

    function setup(){

        variables.wirebox = new coldbox.system.ioc.Injector( "config.WireboxServices" );
        variables.svc = variables.wirebox.getInstance( "FinishService" );
        
        var cm = variables.wirebox.getInstance( "CacheManager" );
        
        cm.removeAll();

    }

    function teardown( currentMethod ) {

        StructDelete( variables, "wirebox" );

    }

    function delete_test(){

        var bean = new com.apirone.core.model.bean.Finish();

        var code = "FS" & RandRange( 10000, 99999  );
        var name = "Nuovo verde acido #code#";

        var data = {
            code = code,
            
            status = {
                id = "ACT"
            },
            texts = [
                {
                    name = name,
                    lang = {
                        id = "IT"
                    },
                    status = {
                        id = "ACT"
                    }
                }
            ],
            categories = [
                {
                    id: RandRange( 4, 21 )
                },
                {
                    id: RandRange( 4, 21 )
                }
            ]
        }

        bean.setMemento( data );

        var newId = variables.svc.create( bean );

        var thisBean = variables.svc.get( newId );


        var outcome = variables.svc.delete( newId );

        $assert.isTrue( outcome.getData().deletedCount == 1 ); 
                
    }    

    function create_test(){

        var bean = new com.apirone.core.model.bean.Finish();

        var code = "FS" & RandRange( 10000, 99999  );
        var name = "Nuovo verde acido #code#";

        var data = {
            code = code,
            
            status = {
                id = "ACT"
            },
            texts = [
                {
                    name = name,
                    lang = {
                        id = "IT"
                    },
                    status = {
                        id = "ACT"
                    }
                }
            ],
            categories = [
                {
                    id: RandRange( 4, 21 )
                },
                {
                    id: RandRange( 4, 21 )
                }
            ]
        }

        bean.setMemento( data );

        var newId = variables.svc.create( bean );

        var thisBean = variables.svc.get( newId );

        $assert.isTrue( thisBean.getCode() EQ data.code ); 
        $assert.isTrue( thisBean.getName() EQ name ); 

        variables.svc.delete( newId );
                
    }

   function listByLineId_test(){

        var lineId = "c0fb8f55-40e1-4eb2-8ae2-58f27ffb872f"; //PLACCA MOD. BAROCCA

        var list = variables.svc.list( lineId = lineId );

        $assert.isTrue( list.len() == 8 ); 
                
    }


    function get(){

        var account = new com.apirone.core.model.bean.Finish();

        var data = {
            'login' = 'roberto@marzialetti.com',
            'pwd' = 'Jaxo_8989a',
        }

        account.setLogin( data.login );
        account.setPwd( data.pwd );

        var id = variables.svc.create( account );

        var account = variables.svc.get( id );

        $assert.isTrue( account.getLogin() EQ data.login ); 
        $assert.isTrue( account.getId() EQ id ); 

        variables.svc.delete( id );
                
    }

}