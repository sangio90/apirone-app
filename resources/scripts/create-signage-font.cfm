Remove cfabort.
<cfabort>
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
	
	//lettering big, lettering small, lettering medium
	refCatalogBundleIds = ["b52f5f60-e901-4b68-af46-80b0b8213e36","7a74d187-6c17-4e49-ade8-ba3eae142094", "d0ab32db-078d-447d-a98e-f22de2ed610f"]; 

	newFont  = fontSvc.get( newFontId );

	newFontFamilyId = newFont.getFontFamily().getId();

	for( refCatalogBundleId in refCatalogBundleIds ){

		// prendo tutte le configurazioni signage del bundle di riferimento
		signageConfigs = signageSvc.list( catalogBundleId = refCatalogBundleId );

		echo("Configurazioni trovate per bundle #refCatalogBundleId#: #ArrayLen(signageConfigs)#<br>");

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

			echo("Prodotti trovati: #ArrayLen(products)#<br>");

			y = 1
			for( itemRef in thisSignageConfig.getItems() ) {

				echo("#y# ******************************  / #itemRef.getSize().getName()# <br>");
				echo("Current size: #itemRef.getSize().getName()# <br>");

				n = 1
				for( product in products ) {

					echo("#n# ************<br>");
					echo("Prodotto corrente: #product.getName()# ( #product.getShortId()# ) // #product.getLine().getName()# / #product.getModel().getName()# / #product.getFinish().getName()# <br>");

					///if( !IsNull( product.getItems() ) ) {
					items = productItemSvc.getFlatTree( productId = product.getId() )
					//var items = super.fire( "ProductItem.getFlatTree", params );
					if( Len( items ) ) {

						echo("Prodotto corrente: #product.getName()#; item trovati: #items.len()#<br>");

						for( productItem in items ) {

							params = {
								signageConfigItemId = itemRef.getId(),
								productItemId   = productItem.getId()
							}				

							componentRefs = componentSvc.list( signageItemProduct = params );

							echo( "Componenti trovati #Len(componentRefs)# per productItem #productItem.getId()#, signageConfigItemId: #itemRef.getId()#<br>" );
							//dump( DESerializeJSON(SerializeJSON( componentRefs )) );
							//abort;

							for( compRef in componentRefs ) {

								// i componenti virtuali non ci sono

								//shoud be com.apirone.core.model.bean.ComponentSignageItemProduct
								echo( "compRef: #compRef.getId()#, name: #GetComponentMetaData(compRef).fullname#<br>" );
								echo( "compRef: rawProduct: #compRef.getRawProduct().getId()#; variant: #compRef.getVariant().getId()#; color: #compRef.getColor().getId()#<br>");

								newComp = duplicate( compRef );

								newComp.setId( "" );
								sizeName = compRef.getSignageConfigItem().getSize().getName();

								signageItemRef = getSignageItemRef( sizeName, currentSignageConfig.getItems() );

								if( IsNull( signageItemRef ) ) {

									echo("Nessun signageItemRef trovato per size #newComp.getSignageConfigItem().getSize().getName()#, sizeName: #sizeName#<br>");

								} else {

									newComp.setSignageConfigItem( signageItemRef );

									componentSvc.create( newComp );

									echo("Created component for productItem #productItem.getId()#, component #newComp.getId()#, sizeName: #sizeName#<br>");

									//abort;

								}

							}

						} 
					
					} else {
						echo("Nessun productItem per prodotto #product.getName()#<br>");
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