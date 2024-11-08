component extends="coldbox.system.ioc.config.Binder" {

    function configure() {

        var settings = new config.Settings();

        wireBox = {
            scopeRegistration = {
                enabled = true,
                scope   = "server", // server, cluster, session, application
                key     = settings.get('app.wirebox.key'),
                //scanLocations = ["com.apirone.model"],
            }
        };

        /*
            services
        */
        map("AbsService").to( "com.apirone.core.model.service.AbsService" )
            .asSingleton()
            .property( name = "Logger", ref = "Logger" )
            .property( name = "Factory", ref = "Factory" )
            .property( name = "DBUtil", ref = "DBUtil" )
            .property( name = "CacheManager", ref = "CacheManager" )
            .property( name = "Configuration", ref = "Configuration");
        
        map("ProductCategoryService").to( "com.apirone.core.model.service.ProductCategoryService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductCategoryDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");

        map("ProductionTimeService").to( "com.apirone.core.model.service.ProductionTimeService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductionTimeDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");

        map("VatCodeService").to( "com.apirone.core.model.service.VatCodeService" )
            .asSingleton()
            .property( name = "dao", ref = "VatCodeDAO" )
            .parent("AbsService");

        map("i18nService").to( "com.apirone.core.model.service.i18nService" )
            .asSingleton()
            .parent("AbsService");

        map("ProductService").to( "com.apirone.core.model.service.ProductService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "VariantTypeService", ref = "VariantTypeService" )
            .property( name = "ProductVariantService", ref = "ProductVariantService" )
            .property( name = "ProductCategoryService", ref = "ProductCategoryService" )
            .property( name = "ProductTypeService", ref = "ProductTypeService" )
            .property( name = "CompanyService", ref = "CompanyService" )
            .parent("AbsService");

        map("ProductVariantService").to( "com.apirone.core.model.service.ProductVariantService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductVariantDAO" )
            .property( name = "FileService", ref = "FileService" )
            .property( name = "PriceService", ref = "PriceService" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");
    
        map("AccountService").to( "com.apirone.core.model.service.AccountService" )
            .asSingleton()
            .property( name = "dao", ref = "AccountDAO" )
            .property( name = "statusService", ref = "StatusService" )
            .property( name = "lookupService", ref = "LookupService" )
            .property( name = "langService", ref = "LangService" )
            .parent("AbsService");

        map("APIService").to( "com.apirone.core.model.service.APIService" )
            .asSingleton()
            .property( name = "AccountService", ref = "AccountService" )
            .parent("AbsService");

        map("LookupService").to( "com.apirone.core.model.service.LookupService" )
            .asSingleton()
            .parent("AbsService");

        map("VariantTypeService").to( "com.apirone.core.model.service.VariantTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "VariantTypeDAO" )
            .parent("AbsService");

        map("CompanyService").to( "com.apirone.core.model.service.CompanyService" )
            .asSingleton()
            .property( name = "dao", ref = "CompanyDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "AccountService", ref = "AccountService" )
            .property( name = "CompanyTypeService", ref = "CompanyTypeService" )
            .property( name = "LocationService", ref = "LocationService" )
            .parent("AbsService");
                        
        map("PriceService").to( "com.apirone.core.model.service.PriceService" )
            .asSingleton()
            .property( name = "dao", ref = "PriceDAO" )
            .parent("AbsService");
            
        map("CompanyTypeService").to( "com.apirone.core.model.service.CompanyTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "CompanyTypeDAO" )
            .parent("AbsService");

        map("GeoService").to( "com.apirone.core.model.service.GeoService" )
            .asSingleton()
            .property( name = "cityDao", ref = "CityDAO" )
            .property( name = "countyDao", ref = "CountyDAO" )
            .property( name = "stateDao", ref = "StateDAO" )
            .property( name = "countryDao", ref = "CountryDAO" )
            .parent("AbsService");
           
        map("AuthService").to( "com.apirone.core.model.service.AuthService" )
            .asSingleton()
            .property( name = "AccountService", ref = "AccountService" )
            .parent("AbsService");

        map("LocationService").to( "com.apirone.core.model.service.LocationService" )
            .asSingleton()
            .property( name = "dao", ref = "LocationDAO")
            .property( name = "GeoService", ref = "GeoService" )
            .parent("AbsService");
    
        map("FileService").to( "com.apirone.core.model.service.FileService" )
            .asSingleton()
            .property( name = "dao", ref = "FileDAO" )
            .property( name = "MediaService", ref = "MediaService" )
            .parent("AbsService");
                    
        map("MediaService").to( "com.apirone.core.model.service.MediaService" )
            .asSingleton()
            .parent("AbsService");

        map("AccountService").to( "com.apirone.core.model.service.AccountService" )
            .asSingleton()
            .property( name = "dao", ref = "AccountDAO" )
            .parent("AbsService");
            
        map("StatusService").to( "com.apirone.core.model.service.StatusService" )
            .asSingleton()
            .property( name = "dao", ref = "StatusDAO" )
            .property( name = "systemColorService", ref = "systemColorService" )
            .parent("AbsService");
            
        map("systemColorService").to( "com.apirone.core.model.service.systemColorService" )
            .asSingleton()
            .parent("AbsService");
            
        map("ProductTypeService").to( "com.apirone.core.model.service.ProductTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "ProductTypeDAO" )
            .parent("AbsService");
            
        map("ComponentTypeService").to( "com.apirone.core.model.service.ComponentTypeService" )
            .asSingleton()
            .property( name = "dao", ref = "ComponentTypeDAO" )
            .parent("AbsService");
            
        map("ComponentService").to( "com.apirone.core.model.service.ComponentService" )
            .asSingleton()
            .property( name = "dao", ref = "ComponentDAO" )
            .property( name = "ComponentTypeService", ref = "ComponentTypeService" )
            .property( name = "VariantService", ref = "VariantService" )
            .property( name = "ColorService", ref = "ColorService" )
            .parent("AbsService");

        map("LineService").to( "com.apirone.core.model.service.LineService" )
            .asSingleton()
            .property( name = "dao", ref = "LineDAO" )
            .property( name = "statusService", ref = "StatusService" )
            .property( name = "lookupService", ref = "lookupService" )
            .parent("AbsService");

        map("CombinationService").to( "com.apirone.core.model.service.CombinationService" )
            .asSingleton()
            .property( name = "dao", ref = "CombinationDAO" )
            .property( name = "SizeService", ref = "SizeService" )
            .property( name = "LineService", ref = "LineService" )
            .property( name = "FinishService", ref = "FinishService" )
            .parent("AbsService");

        map("LangService").to( "com.apirone.core.model.service.LangService" )
            .asSingleton()
            .property( name = "dao", ref = "LangDAO" )
            .parent("AbsService");

        map("TextService").to( "com.apirone.core.model.service.TextService" )
            .asSingleton()
            .property( name = "dao", ref = "TextDAO" )
            .property( name = "LangService", ref = "LangService" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");

        map("VariantService").to( "com.apirone.core.model.service.VariantService" )
            .asSingleton()
            .property( name = "ColorService", ref = "ColorService" )
            .property( name = "dao", ref = "VariantDAO" )
            .parent("AbsService");

        map("ColorService").to( "com.apirone.core.model.service.ColorService" )
            .asSingleton()
            .property( name = "dao", ref = "ColorDAO" )
            .parent("AbsService");
            
        map("SizeService").to( "com.apirone.core.model.service.SizeService" )
            .asSingleton()
            .property( name = "dao", ref = "SizeDAO" )
            .parent("AbsService");
            
        map("AttributeService").to( "com.apirone.core.model.service.AttributeService" )
            .asSingleton()
            .property( name = "dao", ref = "AttributeDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "TextService", ref = "TextService" )
            .property( name = "AttributeValueService", ref = "AttributeValueService" )
            .property( name = "LangService", ref = "LangService" )
            .parent("AbsService");
            
        map("AttributeValueService").to( "com.apirone.core.model.service.AttributeValueService" )
            .asSingleton()
            .property( name = "dao", ref = "AttributeValueDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .property( name = "TextService", ref = "TextService" )
            .property( name = "LangService", ref = "LangService" )
            .parent("AbsService");
            
        map("ReportService").to( "com.apirone.core.model.service.ReportService" )
            .asSingleton()
            .property( name = "dao", ref = "ReportDAO" )
            .property( name = "StatusService", ref = "StatusService" )
            .parent("AbsService");

        map("FinishService").to( "com.apirone.core.model.service.FinishService" )
            .asSingleton()
            .parent("AttributeValueService");
            
        
        /*
            dao
        */
        map("AbsDAO").to( "com.apirone.core.model.dao.AbsDAO" )
            .asSingleton();
         
        map("SizeDAO").to( "com.apirone.core.model.dao.SizeDAO" )
            .asSingleton();
         
        map("CombinationDAO").to( "com.apirone.core.model.dao.CombinationDAO" )
            .asSingleton();
         
        map("ReportDAO").to( "com.apirone.core.model.dao.ReportDAO" )
            .asSingleton();
         
        map("AttributeDAO").to( "com.apirone.core.model.dao.AttributeDAO" )
            .asSingleton();
         
        map("AttributeValueDAO").to( "com.apirone.core.model.dao.AttributeValueDAO" )
            .asSingleton();
         
        map("ComponentDAO").to( "com.apirone.core.model.dao.ComponentDAO" )
            .asSingleton();
         
        map("VariantDAO").to( "com.apirone.core.model.dao.VariantDAO" )
            .asSingleton();
         
        map("ColorDAO").to( "com.apirone.core.model.dao.ColorDAO" )
            .asSingleton();

        map("PriceDAO").to( "com.apirone.core.model.dao.PriceDAO" )
            .asSingleton();            
         
        map("ComponentTypeDAO").to( "com.apirone.core.model.dao.ComponentTypeDAO" )
            .asSingleton();
        
        map("ProductionTimeDAO").to( "com.apirone.core.model.dao.ProductionTimeDAO" )
            .asSingleton();

        map("ProductTypeDAO").to( "com.apirone.core.model.dao.ProductTypeDAO" )
            .asSingleton();

        map("VatCodeDAO").to( "com.apirone.core.model.dao.VatCodeDAO" )
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

        map("LineDAO").to( "com.apirone.core.model.dao.LineDAO" )
            .asSingleton();

        map("LangDAO").to( "com.apirone.core.model.dao.LangDAO" )
            .asSingleton();

        map("TextDAO").to( "com.apirone.core.model.dao.TextDAO" )
            .asSingleton();


        /*
            factory
        */

        map("factory").to( "com.apirone.core.model.factory.factory" )
            .asSingleton()


        /*
            configuration
        */

        map("Configuration").to( "com.apirone.core.model.bean.Configuration" )
            .asSingleton()

        
        /*
            utils
        /*

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

        map("DBUtil").to( "com.apirone.core.util.DBUtil" )
            .asSingleton()

        map("Logger").to( "com.apirone.core.util.Logger" )
            .asSingleton()
            .initArg(
                name="folder", 
                value=ExpandPath("/../repository/private/logs/")
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
