component extends="coldbox.system.ioc.config.Binder" {

    function configure() {

        var settings = new config.Settings();

        wireBox = {
            scopeRegistration = {
                enabled = true,
                scope   = "server",
                key     = settings.get("app.wirebox.key")
            },
        };


        mapDirectory(packagePath="com.apirone.core.model.dao")
            .asSingleton();

        mapDirectory(packagePath="com.apirone.core.model.service")
            .asSingleton();


        /*
            configuration
        */

        map("Configuration").to( "com.apirone.core.model.bean.Configuration" )
            .asSingleton()



        /*
            utils
        */
        map("AccessManager").to( "com.apirone.core.util.accessManager.AccessManager" )
            .asSingleton()
            .initArg(
                name="controllerPath",
                value="com.apirone.core.controller.accessManager"
            );

        map("CacheManager").to( "com.apirone.core.util.CacheManager" )
            .asSingleton()
            .initArg(
                name="scopes",
                value=DeserializeJSON( fileRead( expandPath( "/config/cacheScopes.json.cfm" ) ) )
            )

        map("DBUtil").to( "com.apirone.core.util.DBUtil" )
            .asSingleton()

        map("Logger").to( "com.apirone.core.util.Logger" )
            .asSingleton()
            .initArg(
                name="folder",
                value=ExpandPath("/../repository/private/logs/")
            );

        map("AuditLogger").to( "auditLogger.AuditLogger" )
            .asSingleton()
            .initArg(
                name="datasource",
                value="apirone"
            )
            .initArg(
                name="config",
                value=DeserializeJSON( fileRead( expandPath( "/config/auditConfig.json.cfm" ) ) )
            );            

        map("Security").to( "com.apirone.core.util.Security" )
            .asSingleton()
            .property( name = "key", value = "f3QqI43t/UGnoVRPsdpczw==")
            .property( name = "algorithm", value = "BLOWFISH")
            .property( name = "algorithmEncoding", value = "HEX");

        map("DataMapper").to( "dataMapper.DataMapper" )
            .asSingleton()
            .initArg(
                name="configFullPath",
                value=ExpandPath( "/config/DataMapper.xml.cfm" )
            );

    }

}
