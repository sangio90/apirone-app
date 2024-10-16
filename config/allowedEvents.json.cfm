{
    forUnlogged = [
        "manager:AuthController.resetPwd",
        "manager:AuthController.doResetPwd",
        "manager:AuthController.login",
        "manager:AuthController.doLogin",
        "manager:AuthController.recovery",
        "manager:AuthController.doRecovery",
        "manager:AuthController.logout",
        "manager:AuthController.disconnected"
    ],
    forCustomer = [
        "manager:MainController.dashboard",

        "manager:LookupController.datajs",

        "manager:EstimateController.new",

        "manager:ShipmentController.new",
        "manager:ShipmentController.list",
        "manager:ShipmentController.edit",
        
        "manager:ShipmentAjaxController.list",
        "manager:ShipmentAjaxController.listLocations",
        "manager:ShipmentAjaxController.saveLocation",
        "manager:ShipmentAjaxController.searchLabel",
        "manager:ShipmentAjaxController.listLabels",
        "manager:ShipmentAjaxController.saveLabel",
        "manager:ShipmentAjaxController.listProfiles",
        "manager:ShipmentAjaxController.saveProfile",
        "manager:ShipmentAjaxController.calculate",
        "manager:ShipmentAjaxController.save",
        "manager:ShipmentAjaxController.listDocuments",
        "manager:ShipmentAjaxController.saveNumber",
        "manager:ShipmentAjaxController.changeTracking",
        "manager:ShipmentAjaxController.search",
        "manager:ShipmentAjaxController.upload",
        
        "manager:LocationController.list",
        "manager:LocationController.save",
        "manager:LocationController.print",

        "manager:LocationAjaxController.list",
        "manager:LocationAjaxController.save",
        "manager:LocationAjaxController.get",

        "manager:ProfileController.list",
        "manager:ProfileController.save",

        "manager:ProfileAjaxController.list",
        "manager:ProfileAjaxController.save",
        "manager:ProfileAjaxController.get",

        "manager:PaymentAjaxController.save",
        "manager:PaymentAjaxController.list",

        "manager:CurrentUserController.get",
        "manager:CurrentUserController.listEstimates",
        "manager:CurrentUserController.listPayments",
        "manager:CurrentUserController.listShipments",
        "manager:CurrentUserAjaxController.listShipments",
        "manager:CurrentUserAjaxController.listPayments",

        "manager:EstimateAjaxController.list",
        
        "manager:UtilController.download",
        "manager:UtilController.downloadOrderReference",

    ]
}
