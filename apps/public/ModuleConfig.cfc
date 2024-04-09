component{

    this.name = "public";
    this.entryPoint = "public";

    function configure(){

        conventions = {
            handlersLocation : "controllers",
        };

        layoutSettings = {
            defaultLayout = "public.cfm"
        };        

    }

}