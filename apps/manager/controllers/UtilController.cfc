component extends="com.apirone.core.controller.AbsController" {

    // method not found

    function notFound( event, rc, prc ){

        return "<h2>404</h2>"

    }
    
    function ping( event, rc, prc ){

        event.setView("util/ping").noLayout()

    }
    
}
