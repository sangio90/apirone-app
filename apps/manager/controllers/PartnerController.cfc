component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = prc.user;

        prc.list = DESerializeJSON( FileRead( '/config/data/fake-partners.json' ) );

        event.setView('partner/list');

    }
    
    function new( event, rc, prc ){

        var user = prc.user;

        event.setView('partner/detail');

    }

    function save( event, rc, prc ){

        var service = super.service("Partner");
        var bean = super.bean("Partner");
        var user = prc.user;

        bean.name()

        if ( Len(rc.id) )  {

            service.update()
        } else {
            service.create();
        }


        //event.setView('partner/detail');
        flash.put("message", "Partner salvato con successo");
        relocate( uri="/manager/partners", addToken=false, postProcessExempt=false );
        

    }
    
}
