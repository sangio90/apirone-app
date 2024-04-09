component{

    this.name = "public";
    this.entryPoint = "public";

    function configure(){

        /*
        coldbox = {
            invalidEventHandler: "MainController.notFound",
            invalidEventHandler: "MainController.error",
        }
        */

        conventions = {
            handlersLocation : "controllers",
        };

        layoutSettings = {
            defaultLayout = "public.cfm"
        };        

    }

}