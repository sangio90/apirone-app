component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductItemCombinationDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="productItemService" type="com.apirone.core.model.service.ProductItemService";
	
	property name="scopeCache" type="String" default="ProductItemCombination.bean";

    public com.apirone.core.model.bean.ProductItemCombination function get(
    		required String productItemCombinationId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getScopeCache(), arguments.productItemCombinationId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.productItemCombinationId );
		cm.put( getScopeCache(), arguments.productItemCombinationId, bean );
        
		return bean;

	}

    private Array function convertTree( required Array items ) {
		
        var result = [];

        for( thisItem in items ) {

            var row = super.getDataMapper().convert( thisItem, "ProductItemTree", true );
            
            if( !IsNull( thisItem?.getChildren() ) ) {
                row["children"] = convertTree( items=thisItem.getChildren() );
            }        
    
            ArrayAppend( result, row );
    
        }

		return result;
    
    }


	public com.apirone.core.model.bean.ProductItemCombination[] function calculate(
		String fruitId,
		String combinationId,
	) {

		var result = [];

		var baseTree = getProductItemService().getTree(
			combinationId = arguments.combinationId,
			fruitId = arguments.fruitId
		);

		var baseAttributes = {};

		//dump(DESerializeJSON( SerializeJSON(baseTree)));

		var data = []

		for( var item in baseTree ) {

			//var data = [];

			var key = item.getAttribute().getId();
			data.add( item.getId() );

			if( !baseAttributes.keyExists( key ) ) {
				baseAttributes[ key ] = { 
					"attribute" = { 
						"id" = key, 
						"name" = item.getAttribute().getName() 
					},
					"values": [] 
				};
			}

			var values = getRecursiveValues( item.getChildren(), data );

            baseAttributes[ key ].values = values.data;

		}

		dump(baseAttributes);
		abort;

		return result;
		
	}

	private Struct function getRecursiveValues( required Array items, data=[] ) {
	
		var result = [];

		for( var thisItem in arguments.items ) {

			var item = {};
			item.id = thisItem.getId();
			item.values = [];

			data.add( item.id ); //se ha un figlio lo aggiungo

			var itemRows = getRecursiveValues( thisItem.getChildren(), data ).result;

			//data.add( itemRows )

			if( ArrayLen( itemRows ) ) {
				item.values = itemRows;
			}

			ArrayAppend( result, item );

		}

		return { "result": result, "data": data };
		
	}	

	private Numeric function getChildCount( required Array items, required Numeric parentId ) {

        var result = 0;

        for( var item in items ) {

            if ( item?.getParent()?.getId() == arguments.parentId ) {
                result++;
            }

        }

        return result;

	}


	private Struct function getBaseAttributes( required String combinationId, required String fruitId ) {

		var items = getProductItemService().getFlatTree(
			combinationId = arguments.combinationId,
			fruitId = arguments.fruitId
		);

		//dump( DESerializeJSON( SerializeJSON( items ) ) );

        var baseAttributes = {};

		for( var item in items ) {

            var attrId = item.getAttribute().getId();
            //var key = item.getAttribute().getId() & "__" & item.getAttribute().getName();

            if( !baseAttributes.keyExists( attrId ) ) {
                baseAttributes[ attrId ] = { "attribute" = { 
                    "id": attrId, "name": item.getAttribute().getName() },
                    "values": [] 
                };
            }

            var childCount = getChildCount( data = items, parentId = item.getId() );

            baseAttributes[ attrId ].values.add( 
                {
                    "id": item.getId(), 
                    "name": item.getAttributeValue().getName(),
                    "childCount": childCount
                } 
            );

			//result.add( item );
		}

        return baseAttributes

	}


	/*
	public com.apirone.core.model.bean.ProductItem[] function list(
         	String fruitId,
         	String combinationId
    ) {
		arguments["limit"] = -1;

		return search(argumentCollection = arguments).getData();
	
	}
	*/

    public com.apirone.core.model.bean.Result function search(
			String fruitId,
            String combinationId
        ){

		//dump( arguments );

		// solo uno dei due
		if ( ! ( IsNull( arguments.combinationId ) XOR IsNull( arguments.fruitId ) ) ) {
			throw( type="ApirOne.errors.AtLeastOneParameterIsRequired", message="At least one parameter is required: combinationId or fruitId" );
		}
	
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( 
                get( record.product_item_id ) 
            );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public com.smartvillage.core.model.bean.Outcome function delete(
			String combinationId,
			String attributeId,
			String fruitId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.combinationId );

		outcome.setData( { combinationId: arguments.combinationId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( arguments.combinationId );
        
                cm.remove( getCacheScope(), obj.getId() );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete combination [#arguments.combinationId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.ProductItem combinationItem
		){

		var newId = getDao().insert( arguments.combinationItem );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.ProductItemCombination function build(
    		required String productItemCombinationId
    	){

	    var record = getDao().read( arguments.productItemCombinationId );

	    if( record.recordCount ) { 

            var bean = super.bean( "ProductItemCombination" );

			/*
            bean.setId( record.product_item_id );
            bean.setCombinationId( record.combination_id );
			bean.setCreatedAt( record.created_at );
			bean.setParent( get( record.parent_id ) );
			bean.setOrderBy( record.orderby );

            bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );
            
			bean.setAttributeValue( attributeValue );
            bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
			*/
			
            return bean;

	    }

		return nullValue();

  	}

}
