component extends="testbox.system.BaseSpec"{

    public Struct function createCompany( required startWith="**" ) {

        var raw = {};
    
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.RandomData();

        //raw.id = "*" & UCase( util.createRandomCode( 4 ) );
        raw.name = "test_Nome di prova";
        raw.vat = UCase( util.createRandomCode( 8 ) );
        raw.contact = UCase( util.createRandomCode( 4 ) );
        raw.phone = UCase( util.createRandomCode( 8 ) );
        raw.code = UCase( util.createRandomCode( 4, '' ) );
        raw.status.id = "ACT";
        raw.location.address = "test_via prova";
        raw.location.postalCode = "1242342";
        raw.location.city.id = random.getCities(limit=1).city_id.toString();
        raw.postalCode = UCase( util.createRandomCode( 4 ) );
        raw.account.login = 'test_account@prova.com';
        raw.account.pwd = UCase( util.createRandomCode( 8 ) );
        //raw.types = [''];
    
        raw.types = [
            {
                id: 'P'
            },
            {
                id: 'C'
            }
        ]
    
    
        var bean = factory.createInstance( "Company", raw );
    
        return  {
            "obj" = bean,
            "raw" = raw
        }
    
    }

    public Struct function createEmployee( required startWith="**" ) {

        var raw = {};

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.RandomData();

        raw.name = "test_Nome di prova";
        raw.surname = "test_Nome di prova";
        raw.fiscalCode = UCase( util.createRandomCode( 16 ) );
        raw.phone = UCase( util.createRandomCode( 8 ) );
        raw.status.id = "ACT";
        raw.location.address = "test_via prova";
        raw.location.postalCode = "1242342";
        raw.location.city.id = random.getCities(limit=1).city_id.toString();
        raw.account.login = 'test_accountEmployee@prova.com';
        raw.account.pwd = UCase( util.createRandomCode( 8 ) );

        var bean = factory.createInstance( "Employee", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }

    }

    public Struct function createProfile( required startWith="**" ) {
        
        var mock = getMockData();
        
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var lookupService = new com.apirone.core.model.service.LookupService();
        var profileTypes = lookupService.list( "profileType" );
        var randomIndex = randRange(1, arrayLen(profileTypes));
        var randomProfileType = profileTypes[randomIndex];
        
        var raw = mock.mock(
            $returnType = "struct",
            firstName = "fname",
            lastName = "lname",
            company = "name",
            vatNumber = "string-number:11",
            email = "email",
            phone = "tel",
            state = "words:1",
            city = "words:1",
            postalCode = "string-number:5",
            street = function(param) {
                return mock.lastName() & ' street, ' & mock.num(1, 100);
            },
            createdAt = "datetime"
        );
        
        raw.country = { id = random.getCountries(limit=1).country_id.toString() };
        raw.type = { id = randomProfileType.getId() };
        
        var bean = factory.createInstance( "Profile", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }

    public Struct function createQuotation( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        
        var raw = mock.mock(
            $returnType = "struct",
            description = "words:4",
            quotationNumber = "string-number:5",
            quotationDate = "date",
            notes = "words:10",
            validityDate = "date",
            opportunityName = function(param) {
                return mock.firstName() & ' ' & mock.lastName();
            },
            leadName = function() {
                return mock.firstName() & ' ' & mock.lastName();
            },
            customPaymentMethod = "words:2",
            createdAt = "datetime"
        );

        raw.pricelist = { id = random.getRandomByTableName(limit=1, tableName='pricelists').pricelist_id.toString() };
        raw.paymentMethod = { id = random.getRandomByTableName(limit=1, tableName='payment_methods').payment_method_id.toString() };
        raw.currency = { id = random.getRandomByTableName(limit=1, tableName='currencies').currency_id.toString() };
        raw.status = { id = random.getStatuses(limit=1, entity='QUOTATIONS').status_id.toString() };
        raw.lang = { id = random.getRandomByTableName(limit=1, tableName='langs').lang_id.toString() };
        raw.billingProfile = { id = random.getRandomProfilesByType(limit=1, type='B').profile_id.toString() };
        raw.shippingProfile = { id = random.getRandomProfilesByType(limit=1, type='S').profile_id.toString() };
        raw.salesAgentAccount = { id = random.getRandomByTableName(limit=1, tableName='accounts').account_id.toString() };
        raw.graphicTechnicianAccount = { id = random.getRandomByTableName(limit=1, tableName='accounts').account_id.toString() };

        var bean = factory.createInstance( "Quotation", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }

    public Struct function createQuotationItem( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationId = structKeyExists(arguments, "quotationId") ? arguments.quotationId : null;

        var raw = mock.mock(
            $returnType = "struct",
            price = function(param) {
                return val(randRange(1, 20) & '.' & randRange(0, 10));
            },
            quantity = "num:15",
            createdAt = "datetime"
        );

        if (IsNull(quotationId)) {
            raw.quotation = { id = random.getRandomByTableName(limit=1, tableName='quotations').quotation_id.toString() };
        }   else {
            raw.quotation = { id = quotationId };
        }

        var bean = factory.createInstance( "QuotationItem", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemProductParent( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationItemId = structKeyExists(arguments, "quotationItemId") ? arguments.quotationItemId : null;

        var raw = mock.mock(
            $returnType = "struct",
            createdAt = "datetime"
        );

        if (IsNull(quotationItemId)) {
            raw.quotationItem = { id = random.getRandomByTableName(limit=1, tableName='quotation_items').quotation_item_id.toString() };
        }   else {
            raw.quotationItem = { id = quotationItemId };
        }
        raw.product = { id = random.getRandomByTableName(limit=1, tableName='products').product_id.toString() };

        var bean = factory.createInstance( "QuotationItemProduct", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemProduct( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationItemId = structKeyExists(arguments, "quotationItemId") ? arguments.quotationItemId : null;
        var quotationItemProductParentId = structKeyExists(arguments, "quotationItemProductParentId") ? arguments.quotationItemProductParentId : null;
        var prodottoEscluso = structKeyExists(arguments, "prodottoEscluso") ? arguments.prodottoEscluso : null;

        var raw = mock.mock(
            $returnType = "struct",
            createdAt = "datetime"
        );
        if (IsNull(quotationItemId)) {
            raw.quotationItem = { id = random.getRandomByTableName(limit=1, tableName='quotation_items').quotation_item_id.toString() };
        }   else {
            raw.quotationItem = { id = quotationItemId };
        }
        var productId = random.getRandomByTableName(limit=1, tableName='products', primaryKey='product_id', escluso=prodottoEscluso).product_id.toString();
        raw.product = { id = productId };
        raw.parent = { id = quotationItemProductParentId };

        var bean = factory.createInstance( "QuotationItemProduct", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemZoneParent( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationItemId = structKeyExists(arguments, "quotationItemId") ? arguments.quotationItemId : null;

        var raw = mock.mock(
            $returnType = "struct",
            name = "words:1",
            createdAt = "datetime"
        );

        if (IsNull(quotationItemId)) {
            raw.quotationItem = { id = random.getRandomByTableName(limit=1, tableName='quotation_items').quotation_item_id.toString() };
        }   else {
            raw.quotationItem = { id = quotationItemId };
        }

        var bean = factory.createInstance( "QuotationItemZone", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemZone( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationItemId = structKeyExists(arguments, "quotationItemId") ? arguments.quotationItemId : null;
        var quotationItemZoneParentId = structKeyExists(arguments, "quotationItemZoneParentId") ? arguments.quotationItemZoneParentId : null;

        var raw = mock.mock(
            $returnType = "struct",
            name = "words:1",
            createdAt = "datetime"
        );
        if (IsNull(quotationItemId)) {
            raw.quotationItem = { id = random.getRandomByTableName(limit=1, tableName='quotation_items').quotation_item_id.toString() };
        }   else {
            raw.quotationItem = { id = quotationItemId };
        }
        raw.parent = { id = quotationItemZoneParentId };

        var bean = factory.createInstance( "QuotationItemZone", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemPosition( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var quotationItemZoneId = structKeyExists(arguments, "quotationItemZoneId") ? arguments.quotationItemZoneId : null;

        var raw = mock.mock(
            $returnType = "struct",
            positionCoordinateX = function(param) {
                return randRange(0, 99) & '.' & randRange(0, 99999);
            },
            positionCoordinateY = function(param) {
                return randRange(0, 99) & '.' & randRange(0, 99999);
            },
            createdAt = "datetime"
        );
        raw.quotationItemZone = { id = quotationItemZoneId };

        var bean = factory.createInstance( "QuotationItemPosition", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }
    
    public Struct function createQuotationItemProductItemParent( required startWith="**" ) {
        var mock = new modules.cbMockData.models.MockData();
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var random = new tests.utils.DBRandomData();
        var quotationItemProductId = structKeyExists(arguments, "quotationItemProductId") ? arguments.quotationItemProductId : null;

        var raw = mock.mock(
            $returnType = "struct",
            createdAt = "datetime"
        );

        if (IsNull(quotationItemProductId)) {
            raw.quotationItemProduct = { id = random.getRandomByTableName(limit=1, tableName='quotation_item_products').quotation_item_product_id.toString() };
        }   else {
            raw.quotationItemProduct = { id = quotationItemProductId };
        }
        raw.productItem = { id = random.getRandomByTableName(limit=1, tableName='product_items').product_item_id.toString() };

        var bean = factory.createInstance( "QuotationItemProductItem", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }
    }

    public Struct function createCard(  ) {

        var raw = {};

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();

        raw.emissionAt =  now();
        raw.fiscalCode = UCase( util.createRandomCode( 16 ) );
        raw.status.id = "ACT";
        raw.amount = randRange(10, 100);
        raw.email = 'test_allahakbar@gmail.com';
        raw.phone = "test_2434243"

        var bean = factory.createInstance( "Card", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }

    }

    public Struct function createFile(  ) {

        var raw = {};

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();

        raw.type =  'M';
        raw.size = randRange(10, 100);
        raw.width = randRange(10, 100);
        raw.height = randRange(10, 100);
        raw.alt = UCase( util.createRandomCode( 16 ) );
        raw.extension = "jpg";
        raw.description = 'test_description';
        raw.directory   = 'privato/nontoccare/robaporno'

        var bean = factory.createInstance( "File", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }

    }

    public Struct function createProduct() {

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();
        var company = createCompany();

        var raw = {};
        var variants = [];
        var var1 = {};
        var var2 = {};

        var1.name = 'test_#util.createRandomCode( 4 )#';
        var2.name = 'test_#util.createRandomCode( 4 )#';
        var1.status.id = 'ACT';
        var2.status.id = 'DEA';

        var1.price.value = randRange(1,20);
        var2.price.value = randRange(1,20);
        
        var1.price.value = randRange(1,20);
        var2.price.value = randRange(1,20);

        var1.price.discount = randRange(1,100);
        var2.price.discount = randRange(1,100);

        var1.price.discountType = 'P';
        var2.price.discountType = 'F';

        variants.push(var1);
        variants.push(var2);

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();

        raw.name = 'Prodotto-#UCase( util.createRandomCode( 4 ) )#';
        raw.description = 'PRODOTTO-DESCRIZIONE-#UCase( util.createRandomCode( 4 ) )#';
        raw.code =  UCase( util.createRandomCode( 4 ) );
        raw.description = 'test_description';
        raw.status.id = "ACT";
        raw.expirationAt = now();
        raw.variants = variants;
        //raw.company = company.raw;

        var bean = factory.createInstance( "RawProduct", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }

    }


    public Struct function createVariantType(  ) {

        var raw = {};
    
        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();

        raw.name = 'Tipo-Variante-#UCase( util.createRandomCode( 4 ) )#';

        var bean = factory.createInstance( "VariantType", raw );

        return  {
            "obj" = bean,
            "raw" = raw
        }

    }
    
    Struct function createProductCategory( required startWith="**" ) {

        var raw = {};
        var result = {};

        var util = new com.apirone.core.util.String();
        var factory = new com.apirone.core.model.factory.Factory();

        raw.id = "*" & UCase( util.createRandomCode( 4 ) );
        raw.name = "#arguments.startWith# test category";
        raw.status.id = "ACT";

        var bean = factory.createInstance( "ProductCategory", raw );

        return result = {
            "obj" = bean,
            "raw" = raw
        }

    }

    /*
        private
    */

    private Struct function getMockData() {

        return new modules.cbMockData.models.MockData();
    
    }
    
}