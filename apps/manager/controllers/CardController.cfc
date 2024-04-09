component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        var user = arguments.event.getValue( "User" );
        var service = super.service("Card");

        prc.companies = super.service("Company").search();

        prc.list = service.search();

        event.setView('card/list');

    }
    
    function listSlots( event, rc, prc ){

        var user = arguments.event.getValue( "User" );
        var service = super.service("Card");

        prc.companies = super.service("Company").search();

        prc.list = DESerializeJSON( FileRead( '/config/data/fake-slot.json' ) );

        prc.title = "Slot delle tessere";

        event.setView('card/list-slots');

    }
    
    function printCardsBySlot( event, rc, prc ){

        var user = arguments.event.getValue( "User" );
        var service = super.service("Card");

        prc.companies = super.service("Company").search();

        prc.cards = DESerializeJSON( FileRead( '/config/data/fake-slot.json' ) );

        event.setView('card/print-card').noLayout();

    }
    
    function generate( event, rc, prc ){

        prc.companies = super.service("Company").search();

        event.setView('card/generate');

    }

    function detail( event, rc, prc ){
    }

    function generateAll( event, rc, prc ){

        var user = arguments.event.getValue( "User" );
        var cardSvc = super.service("Card");

        var card    = super.bean("Card");
        var account = super.bean("Account");
        var status  = super.bean("Status");
        var company = super.bean("Company");

        company.setId( rc.companyId );
        status.setId( "ACT" );

        card.setExpirationAt( DateAdd( 'yyyy', 1, now() ) );
        card.setEmissionAt( now() );
        card.setAmount( rc.amount );
        card.setStatus( status );
        card.setCompany( company );

        cfloop( from="1" to="#rc.quantity#" index="index" ) {
            cardSvc.create( card );
        }
        
        relocate( uri="/manager/cards?msg=ok", addToken=false, postProcessExempt=false );
        

    }    
    
}
