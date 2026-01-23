<cfscript>

	setting requesttimeout=9999999;

	model = server["wirebox-apirone"];
	request.loadFromVerticale = true;

	fontSvc        = model.getInstance("FontService");
	productSvc     = model.getInstance("ProductService");
	componentSvc   = model.getInstance("ComponentService");
	productItemSvc = model.getInstance("ProductItemService");
	signageSvc     = model.getInstance("SignageConfigService");

	newFontId = 101;
	
	//lettering big, lettering small
	refCatalogBundleIds = ["b52f5f60-e901-4b68-af46-80b0b8213e36","7a74d187-6c17-4e49-ade8-ba3eae142094"]; 

	newFont  = fontSvc.get( newFontId );

	newFontFamilyId = newFont.getFontFamily().getId();

	for( refCatalogBundleId in refCatalogBundleIds ){

		// prendo tutte le configurazioni signage del bundle di riferimento
		signageConfigs = signageSvc.list( catalogBundleId = refCatalogBundleId );

		dump("Configurazioni trovate per bundle #refCatalogBundleId#: #ArrayLen(signageConfigs)#");

		for( thisSignageConfig in signageConfigs ){ //bean: SignageConfig

			// creo la copia della configurazione
			signageConfig = Duplicate( thisSignageConfig );

			// ... con il font corretto
			fontFamilyId = signageConfig.getFont().getFontFamily().getId();
			signageConfig.getFont().setId( newFont.getId() );
			
			for( item in signageConfig.getItems() ){

				// cerco il valore corretto della size per nome e font family
				sizeId = getSizeId( item.getSize().getName(), newFontFamilyId );
				item.getSize().setId( sizeId );

				item.setId( "" );

			}

			// creo la nuova configurazione
			createdId = signageSvc.create( signageConfig );


			// ********

			// ridammi la configurazione appena creata
			currentSignageConfig = signageSvc.get( createdId );

			// devo inserire i componenti per il nuovo signageConfigItem associandolo 
			// all'albero dell'articolo recuperandoli dalla configurazione di riferimento

			bundleId = currentSignageConfig.getCatalogBundle().getId();
			products = productSvc.list( catalogBundleId = bundleId );

			//fontRefId = getSizeId( 100, 100 ).font_family_size_id;

			products = productSvc.list( catalogBundleId = bundleId );

			dump("Prodotti trovati: #ArrayLen(products)#");

			y = 1
			for( itemRef in thisSignageConfig.getItems() ) {

				dump("#y# ******************************  / #itemRef.getSize().getName()# ");
				dump("Current size: #itemRef.getSize().getName()# ");

				n = 1
				for( product in products ) {

					dump("#n# ************");
					dump("Prodotto corrente: #product.getName()# ( #product.getShortId()# ) // #product.getLine().getName()# / #product.getModel().getName()# / #product.getFinish().getName()#");

					///if( !IsNull( product.getItems() ) ) {
					items = productItemSvc.getFlatTree( productId = product.getId() )
					//var items = super.fire( "ProductItem.getFlatTree", params );
					if( Len( items ) ) {

						dump("Prodotto corrente: #product.getName()#; item trovati: #items.len()#");

						for( productItem in items ) {

							params = {
								signageConfigItemId = itemRef.getId(),
								productItemId   = productItem.getId()
							}				

							componentRefs = componentSvc.list( signageItemProduct = params );

							dump( "Componenti trovati #Len(componentRefs)# per productItem #productItem.getId()#, signageConfigItemId: #itemRef.getId()#" );
							//dump( DESerializeJSON(SerializeJSON( componentRefs )) );
							//abort;

							for( compRef in componentRefs ) {

								// i componenti virtuali non ci sono

								//shoud be com.apirone.core.model.bean.ComponentSignageItemProduct
								dump( "compRef: #compRef.getId()#, name: #GetComponentMetaData(compRef).fullname#" ); 
								dump( "compRef: rawProduct: #compRef.getRawProduct().getId()#; variant: #compRef.getVariant().getId()#; color: #compRef.getColor().getId()#");

								newComp = duplicate( compRef );

								newComp.setId( "" );
								sizeName = compRef.getSignageConfigItem().getSize().getName();

								signageItemRef = getSignageItemRef( sizeName, currentSignageConfig.getItems() );

								if( IsNull( signageItemRef ) ) {

									dump("Nessun signageItemRef trovato per size #newComp.getSignageConfigItem().getSize().getName()#, sizeName: #sizeName#");

								} else {

									newComp.setSignageConfigItem( signageItemRef );

									componentSvc.create( newComp );

									dump("Created component for productItem #productItem.getId()#, component #newComp.getId()#, sizeName: #sizeName#");

									//abort;

								}

							}

						} 
					
					} else {
						dump("Nessun productItem per prodotto #product.getName()#");
					}

					n++

				}

				y++;
				//abort;

			}


		}

	}

	function getSignageItemRef( sizeName, items ) {

		for( signageItem in arguments.items ) {
			if( signageItem.getSize().getName() EQ arguments.sizeName ) {
				return signageItem;
			}
		}

	}

</cfscript>

<cffunction name="getSizeId" access="private" returntype="Numeric" output="false">
	<cfargument name="sizeName" type="numeric" required="true">
	<cfargument name="fontFamilyId" type="numeric" required="true">

	<cfquery name="qSize" datasource="apirone">
		SELECT * 
		FROM font_family_sizes
		WHERE font_family_size = '#arguments.sizeName#'
			AND font_family_id = #arguments.fontFamilyId#
	</cfquery>

	<cfreturn qSize.font_family_size_id>
</cffunction>