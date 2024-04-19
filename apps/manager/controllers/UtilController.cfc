component extends="com.apirone.core.controller.AbsController" {

    function notFound( event, rc, prc ){

        return "<h2>404. Not found</h2>"

    }
    
    function invalidMethod( event, rc, prc ){

        return "<h2>Invalid method</h2>"

    }
    
}
