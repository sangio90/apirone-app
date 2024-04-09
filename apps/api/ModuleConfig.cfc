component{

    this.name = "api";
    this.entryPoint = "/api";

    function configure(){

        conventions = {
            handlersLocation: "controllers",
        };

        layoutSettings = {
            defaultLayout = "api.cfm"
        };

        /*
        coldbox = {
            exceptionHandler = "MainController.error",
        }
        */

    }

}

