component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="productService" inject="ProductService";
	property name="productItemService" inject="ProductItemService";
	property name="ComponentService" inject="ComponentService";
	property name="priceTypeService" inject="PriceTypeService";

	variables.logConfig = {}; 
	variables.costs = []; 

	public Struct function calculate( required String productId, Array producItemtIds ){
		
		var total = 0;
		var cost = 0;
		var costs = [];

		var itemsComponents = {};

		var productSvc   = getProductService();
		var componentSvc = getComponentService();

		var productId = arguments.productId;
		var productItemIds = arguments.producItemtIds;

		var product = productSvc.get( productId );

		addLogLine( 
			message="Start calculate price.",
			productName="#product.getLine().getCode()# / #product.getModel().getCode()# / #product.getFinish().getName()#"
		);


		/*
			cost bundle
		*/

		var bundleComponents = componentSvc.list( 
			lineId=product.getLine().getId(),
			modelId=product.getModel().getId(),
			includeBaseAttributeComponents = true
		);
		
		var bundleCost = calculateComponentsTotal( bundleComponents );
		
		addCost( "Costo componenti linea / modello", bundleCost );

		
		/*
			cost base priduct
		*/

		var productComponents = componentSvc.list( 
			productId = productId,
			includeBaseAttributeComponents = true
		);

		var productCost = calculateComponentsTotal( productComponents );

		addCost( "Costo prodotto", productCost );

		
		/*
			cost items
		*/
		
		for( var itemId in productItemIds  ) {
			var itemComponents = componentSvc.list( 
				productItemId = itemId,
				includeBaseAttributeComponents = true
			);

			cffile( action = "APPEND", file = "#ExpandPath( "/debug.log" )#", output = "itemComponents: #itemComponents.len()#");
			
			var itemCost = calculateComponentsTotal( itemComponents );
			addCost( "Costo item #itemId#", itemCost );
		}

		/*
			final price
		*/

		var markup = product.getPrice("PRICE")?.getAmount() ?: 0;

		cost = calculateTotalCost();

		addLogLine( message="Final cost: #cost#" );

		addLogLine( message="Apply markup: #cost# * #markup#" );

		price = cost * markup;

		addLogLine( message="Final price: #price#" );

		var output = { "price" = price, "logFile" = variables.logConfig.filePath };

		return output;
	}

	/*
		private methods
	*/

	private Numeric function calculateComponentsTotal( Array components, Struct price ) {

		var total = 0;
		var log = "";

		if( !Len( components ) ) {
			return 0
		}

		var name = ListLast( Replace( getComponentMetadata( components[1] ).name, "Component", ""), "." );

		dump(getComponentMetadata( components[1] ).name)

		addLogLine( "Start the calculation of the components for #name#" );
		
		for( var component in components ) {

			if ( !component.isDeleted() ) {

				var amount = component.getCost().getAmount();
				var quantity = component.getTotalQuantity(); //with override
				var rowTotal = 0;

				var rowTotal = amount * quantity;

				total = total + rowTotal;

				addLogLine( "Component: #component.getId()# rawProduct: #component.getRawProduct().getId()# variant: #component.getVariant().getId()# color: #component.getColor().getId()# quantity: #quantity#; cost: #amount#; rowTotal: #rowTotal#" );

			} else {
				
				addLogLine( "Variant: #component.getVariant().getId()#; quantity: #quantity#; cost: #amount#; rowTotal: #rowTotal# - DELETED" );

			}

		}

		addLogLine( "End the calculation of the components for #name#. Total: #total#" );	

		return total;

	}

    private Void function addCost( required String label, required Numeric amount ) {

		variables.costs.add( { "label": label, "amount": amount } );
        
    }		

    private Void function addLogLine( required String message, String productName ) {

		if( ListLen( message, "," ) GT 2 ) {
			throw( 
				type="apirone.error.PriceCalculator.messageHasTooManyFields", 
				message="The log message can only have 2 fields (separated by ';')"
			)
		}
        
		if ( StructIsEmpty( variables.logConfig ) ) {

			if( IsNull( productName ) ) {
				throw( 
					type="apirone.error.PriceCalculator.productNameRequired", 
					message="ProductName is required on the first invocation of addLogLine()"
				)
			}

			startLog( productName );
        }

		var thisDate = DateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss");

		var line = "#thisDate#;#variables.logConfig.productName#;#message##chr(10)#";

		FileAppend( variables.logConfig.filePath, line, "utf-8" );
    }		

	private Struct function startLog( required String productName ) {

		var util = new com.apirone.core.util.Udf();
		var name = util.prettyString( productName );		
        
		var logsDir = ExpandPath( "/../repository/private/logs/prices" );
        
		if ( NOT DirectoryExists( logsDir ) ) {
            directoryCreate( logsDir, true );
        }

		var fileName = "product_" 
			& DateTimeFormat(now(), "yyyy-mm-dd_HH-nn-ss" ) 
			& "_" & name;


		if( request.isDev() ) {
			fileName = "product_price_DEV_" & DateFormat(now(), "yyyy-mm-dd")
		}

		var fname = fileName & ".log";

        var filePath = logsDir & "/" & fname;

        // crea file vuoto (o puoi usare fileAppend con stringa vuota)
        FileWrite( filePath, "" );

		variables.logConfig = {
			filePath = filePath,
			productName = productName
		}

        return logConfig;
    }

	private Numeric function calculateTotalCost() {

		var total = 0;

		for( var item in variables.costs ) {
			total  = total + item.amount
		}

        return total;
    }


}
