component extends="com.apirone.core.controller.AbsController" {

    function check( event, rc, prc ){

        event.setView( "employee/check" );

    }
    
    function subscribe( event, rc, prc ){

        //event.setValue( "fiscalCodeExists", false );

        //flash.put( "showFiscalCodeForm", true );

        event.setView( "employee/subscribe" );

    }
    
    function checkFiscalCode( event, rc, prc ){

        var exists = super.service("Employee").fiscalCodeExists( rc.fiscalCode );

        if ( exists ) {

            var employee = super.service("Employee").getByFiscalCode( rc.fiscalCode );

            //relocate( uri="/public/employee/subscribe", addToken=false, postProcessExempt=false );

            relocate( uri="/public/employee/card-assign/:#employee.getId()#", addToken=false, postProcessExempt=false );


        } else {

            relocate( uri="/public/employee/subscribe", addToken=false, postProcessExempt=false );

        }

    }
    
    function card( event, rc, prc ){

        event.setView("employee/card")
    }
    
    function create( event, rc, prc ){

        var accountObj = super.bean("Account");
        var employeeObj = super.bean("Employee");

        var accountSvc = super.service("Account");
        var employeeSvc = super.service("Employee");

        accountObj.setLogin( rc.email ); // TODO: check if exists
        accountObj.setPwd( rc.pwd );

        var accountId = accountSvc.create( accountObj ); 
        var accountObj = accountSvc.get( accountId );

        employeeObj.setName( rc.name );
        employeeObj.setSurname( rc.surname );
        employeeObj.setPhone( rc.phone ); // TODO: check if exists
        employeeObj.setFiscalCode( rc.fiscalCode ); // TODO: check if exists
        employeeObj.setAccount( accountObj ); 

        var obj = employeeSvc.create( employeeObj );

        relocate( "/public/employee/card-assign/#obj.getId()#", addToken=false, postProcessExempt=false );

    }
    

}
