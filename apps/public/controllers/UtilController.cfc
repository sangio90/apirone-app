component extends="com.apirone.core.controller.AbsController" {

    function notFound( event, rc, prc ){

        cfheader( statuscode="404" statustext="Not found");

        echo("<h2>Not found</h2>");
        abort;

    }

    function error( event, rc, prc ){

        dump(arguments);

        dump("MainController.error");
        abort;

    }

    function invalidMethod( event, rc, prc ){

        echo("<h2>Invalid method</h2>");
        abort;

    }

}
