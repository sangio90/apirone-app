component extends="wirebox.system.ioc.config.Binder" {

    function configure() {

        var settings = new config.Settings();

        wireBox = {
            scopeRegistration = {
                enabled = true,
                scope   = "server", // server, cluster, session, application
                key     = settings.get('app.wirebox.key')
            }
        };

        /*=========
            services
        =========*/

        map("AbsService").to( "com.apirone.core.model.service.AbsService" )
            .asSingleton()
            .property( name = "Configuration", ref = "Configuration")
            .property( name = "CacheManager", ref = "CacheManager" )
            .property( name = "Logger", ref = "Logger" )
            .property( name = "Factory", ref = "Factory" );
        
        map('ProductCategoryService').to( "com.apirone.core.model.service.ProductCategoryService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductCategoryDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");

        map('i18nService').to( "com.apirone.core.model.service.i18nService" )
            .asSingleton()
            .parent("AbsService");

        map('ProductService').to( "com.apirone.core.model.service.ProductService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "VariantTypeService", ref = "VariantTypeService" )
            .property( name = "ProductVariantService", ref = "ProductVariantService" )
            .property( name = "ProductCategoryService", ref = "ProductCategoryService" )
            .property( name = "CompanyService", ref = "CompanyService" )
            .parent("AbsService");

        map('ProductVariantService').to( "com.apirone.core.model.service.ProductVariantService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductVariantDAO" )
            .property( name = "FileService", ref = "FileService" )
            .property( name = "PriceService", ref = "PriceService" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");
    
        map('DocumentService').to( "com.apirone.core.model.service.DocumentService" )
            .asSingleton()
            .property( name = "dao", ref = "DocumentDAO" )
            .property( name = "LookupService", ref = "LookupService" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "DocumentItemService", ref = "DocumentItemService" )
            .property( name = "EmployeeService", ref = "EmployeeService" )
            .parent("AbsService");
    
        map('DocumentItemService').to( "com.apirone.core.model.service.DocumentItemService" )
            .asSingleton()
            .property( name = "dao", ref = "DocumentItemDAO" )
            .property( name = "LookupService", ref = "LookupService" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "productVariantService", ref = "productVariantService" )
            .property( name = "productService", ref = "productService" )
            .parent("AbsService");
    
        map('AccountService').to( "com.apirone.core.model.service.AccountService" )
            .asSingleton()
            .property( name = "dao", ref = "AccountDAO" )
            .property( name = "statusService", ref = "StatusService" )
            .property( name = "lookupService", ref = "LookupService" )
            .parent("AbsService");

        map('APIService').to( "com.apirone.core.model.service.APIService" )
            .asSingleton()
            .property( name = "AccountService", ref = "AccountService" )
            .parent("AbsService");

        map('EmployeeService').to( "com.apirone.core.model.service.EmployeeService" )
            .asSingleton()
            .property( name = "dao", ref = "EmployeeDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "WalletService", ref = "WalletService" )
            .property( name = "AccountService", ref = "AccountService" )
            .property( name = "LocationService", ref = "LocationService" )
            .parent("AbsService");

        map('LookupService').to( "com.apirone.core.model.service.LookupService" )
            .asSingleton()
            .parent("AbsService");

        map('WalletService').to( "com.apirone.core.model.service.WalletService" )
            .asSingleton()
            .property( name = "CardService", ref = "CardService" )
            .parent("AbsService");

        map('VariantTypeService').to( "com.apirone.core.model.service.VariantTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "VariantTypeDAO" )
            .parent("AbsService");

        map('CompanyService').to( "com.apirone.core.model.service.CompanyService" )
            .asSingleton()
            .property( name = "dao", ref = "CompanyDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "AccountService", ref = "AccountService" )
            .property( name = "CompanyTypeService", ref = "CompanyTypeService" )
            .property( name = "LocationService", ref = "LocationService" )
            .parent("AbsService");
                        
        map('PriceService').to( "com.apirone.core.model.service.PriceService" )
            .asSingleton()
            .property( name = "dao", ref = "PriceDAO" )
            .parent("AbsService");
            
        map('CardService').to( "com.apirone.core.model.service.CardService" )
            .asSingleton()
            .property( name = "dao", ref = "CardDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "CompanyService", ref = "CompanyService" )
            .parent("AbsService");

        map('CompanyTypeService').to( "com.apirone.core.model.service.CompanyTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "CompanyTypeDAO" )
            .parent("AbsService");

        map('GeoService').to( "com.apirone.core.model.service.GeoService" )
            .asSingleton()
            .property( name = "cityDao", ref = "CityDAO" )
            .property( name = "countyDao", ref = "CountyDAO" )
            .property( name = "stateDao", ref = "StateDAO" )
            .property( name = "countryDao", ref = "CountryDAO" )
            .parent("AbsService");
           
        map('AuthService').to( "com.apirone.core.model.service.AuthService" )
            .asSingleton()
            .property( name = "AccountService", ref = "AccountService" )
            .parent("AbsService");

        map('LocationService').to( "com.apirone.core.model.service.LocationService" )
            .asSingleton()
            .property( name = "dao", ref = "LocationDAO")
            .property( name = "GeoService", ref = "GeoService" )
            .parent("AbsService");
    
        map('FileService').to( "com.apirone.core.model.service.FileService" )
            .asSingleton()
            .property( name = "dao", ref = "FileDAO" )
            .property( name = "MediaService", ref = "MediaService" )
            .parent("AbsService");
                    
        map('MediaService').to( "com.apirone.core.model.service.MediaService" )
            .asSingleton()
            .parent("AbsService");

        map('AccountService').to( "com.apirone.core.model.service.AccountService" )
            .asSingleton()
            .property( name = "AccountDAO", ref = "AccountDAO" )
            .parent("AbsService");
            
        map('StatusService').to( "com.apirone.core.model.service.StatusService" )
            .asSingleton()
            .property( name = "dao", ref = "StatusDAO" )
            .parent("AbsService");
            
        
            /*=========
            dao
        =========*/

        map("AbsDAO").to( "com.apirone.core.model.dao.AbsDAO" )
            .asSingleton();
         
        map("PriceDAO").to( "com.apirone.core.model.dao.PriceDAO" )
            .asSingleton();

        map("DocumentItemDAO").to( "com.apirone.core.model.dao.DocumentItemDAO" )
            .asSingleton();

        map("DocumentDAO").to( "com.apirone.core.model.dao.DocumentDAO" )
            .asSingleton();

        map("AccountDAO").to( "com.apirone.core.model.dao.AccountDAO" )
            .property( name = "Configuration", ref = "Configuration" )
            .asSingleton();

        map("ProductCategoryDAO").to( "com.apirone.core.model.dao.ProductCategoryDAO" )
            .asSingleton();
            
        map("ProductVariantDAO").to( "com.apirone.core.model.dao.ProductVariantDAO" )
        .asSingleton();

        map("EmployeeDAO").to( "com.apirone.core.model.dao.EmployeeDAO" )
            .asSingleton();

        map("ProductDAO").to( "com.apirone.core.model.dao.ProductDAO" )
            .asSingleton();

        map("StatusDAO").to( "com.apirone.core.model.dao.StatusDAO" )
            .asSingleton();

        map("StateDAO").to( "com.apirone.core.model.dao.StateDAO" )
            .asSingleton();

        map("FileDAO").to( "com.apirone.core.model.dao.FileDAO" )
            .asSingleton();
           
        map("CityDAO").to( "com.apirone.core.model.dao.CityDAO" )
            .asSingleton();
           
        map("CountyDAO").to( "com.apirone.core.model.dao.CountyDAO" )
            .asSingleton();
                   
        map("VariantTypeDAO").to( "com.apirone.core.model.dao.VariantTypeDAO" )
            .asSingleton();
                   
        map("CardDAO").to( "com.apirone.core.model.dao.CardDAO" )
            .asSingleton();

        map("AccountDAO").to( "com.apirone.core.model.dao.AccountDAO" )
            .asSingleton();
             
        map("CountryDAO").to( "com.apirone.core.model.dao.CountryDAO" )
            .asSingleton();

        map("CompanyDAO").to( "com.apirone.core.model.dao.CompanyDAO" )
            .asSingleton();
               
        map("CompanyTypeDAO").to( "com.apirone.core.model.dao.CompanyTypeDAO" )
            .asSingleton();

        map("LocationDAO").to( "com.apirone.core.model.dao.LocationDAO" )
            .asSingleton();
        /*=========
            factory
        =========*/

        map("factory").to( "com.apirone.core.model.factory.factory" )
            .asSingleton()


        /*=========
            facades
        =========*/

        map("ServiceFacade").to( "com.apirone.core.facade.ServiceFacade" )
            .parent( "AbsService" )
            .asSingleton()
            .property( name = "factory", ref = "factory")
            .property( name = "RoleService", ref = "RoleService")

        
        /*=========
            configuration
        =========*/

        map("Configuration").to( "com.apirone.core.model.bean.Configuration" )
            .asSingleton()

        
        /*=========
            utils
        =========*/

        /*
        map("UtilString").to( "com.apirone.core.util.String" )
            .asSingleton()
        */

        map("AccessManager").to( "com.apirone.core.util.accessManager.AccessManager" )
            .asSingleton()
            .initArg( 
                name="controllerPath", 
                value="com.apirone.core.controller.accessManager"
            );

        map("CacheManager").to( "com.apirone.core.util.CacheManager" )
            .asSingleton()

        map("Logger").to( "com.apirone.core.util.Logger" )
            .asSingleton()
            .initArg(
                name="filePath", 
                value=ExpandPath("/") & "../repository/private/logs/application.log" 
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
                value=ExpandPath("/config/DataMapper.xml.cfm") 
            );
    }

}
