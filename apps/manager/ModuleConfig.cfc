component {

    this.name = "manager";
    this.entryPoint = "manager";

    this.applicationHelper = ['helpers/viewHelpers.cfm']

    function configure(){

        conventions = {
            handlersLocation : "controllers",
        };

        layoutSettings = {
            defaultLayout = "manager.cfm"
        };        

    }

}