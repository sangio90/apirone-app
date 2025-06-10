component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductItemDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="attributeService" type="com.apirone.core.model.service.AttributeService";
	property name="attributeValueService" type="com.apirone.core.model.service.AttributeValueService";
	property name="combinationComponentService" type="com.apirone.core.model.service.CombinationComponentService";

    public com.apirone.core.model.bean.ProductItem function get(
    		required String productItemId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.productItemId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.productItemId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.ProductItem[] function getTree(
		String fruitId,
		String combinationId
    ) {

		if ( ! ( IsNull( arguments.combinationId ) XOR IsNull( arguments.fruitId ) ) ) {
			throw( type="ApirOne.errors.OneParameterIsRequired", message="One param is required: fruitId or combinationId" );
		}

        var result = [];

        var fruitId = arguments.fruitId;
        var combinationId = arguments.combinationId;

        var baseItems = list( 
            combinationId = arguments.combinationId,
            fruitId = arguments.fruitId
        );

        for( var item in baseItems ) {

            var rows = getRecursiveTree( parentId=item.getId(), rows=[] )
			item.setChildren( rows );

            result.add( item );
            
        }

		//printTree( DESerializeJSON(SerializeJSON(result)) )

		return result;
	
	}	

	public com.apirone.core.model.bean.ProductItem[] function getFlatTree(
					 String fruitId,
            		 String combinationId,
            required Numeric parentId=NullValue(),
            required String level=1, 
            required String orderBy=""
    ) {

        var result = [];

        var fruitId = arguments.fruitId;
        var combinationId = arguments.combinationId;

        var items = list( 
            combinationId = arguments.combinationId,
            fruitId = arguments.fruitId,
            parentId = arguments.parentId
        );

        var thisLevel = arguments.level;

        var n = 1;

        for( var item in items ) {

            var thisOrderBy = "#arguments.orderBy#.#n#";

            item.setLevel( arguments.level );

            result.add( item );
			
            var rows = getFlatTree( fruitId, combinationId, item.getId(), thisLevel+1, thisOrderBy );

            result = result.merge( rows );

            n++;

        }

		return result;
	
	}


	public com.apirone.core.model.bean.ProductItem[] function list(
         	String fruitId,
         	String combinationId,
			Numeric parentId
    ) {
		arguments["limit"] = -1;

		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.CombinationComponent[] function listComponents(
            required Numeric productItemId,
        ){

		var result = getCombinationComponentService().list( productItemId = productItemId );

        return result;

    }

    public Boolean function addComponent(
            required Numeric productItemId,
            required com.apirone.core.model.bean.CombinationComponent combinationComponent
        ){

		transaction {
			getDao().deleteComponent( argumentCollection=arguments );
			getDao().insertComponent( argumentCollection=arguments );
		}

        return true;

    }

    public com.apirone.core.model.bean.Result function search(
			String fruitId,
            String combinationId,
            Numeric parentId
        ){


		// solo uno dei tre NON VA E NON HA SENSO xor di 3
		/*
		if ( ! ( IsNull( arguments.combinationId ) XOR IsNull( arguments.fruitId ) XOR IsNull( arguments.parentId ) ) ) {
			throw( type="ApirOne.errors.AtLeastOneParameterIsRequired", message="One param is required: combinationId or fruitId or parentId" );
		}
		*/
	
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
        
                cm.remove( "combination_#obj.getId()#" );
                
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

	private Void function printTree(required array items, numeric level="0") {
		for ( var item in arguments.items ) {
			var indent = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", arguments.level );
			
			//  Stampa il nome della categoria con l'indentazione 
			echo("#indent# - #item.id# #item.attributeValue.texts[1].name# <br>");

			//  Se la categoria ha dei figli, chiama ricorsivamente la funzione 
			if ( StructKeyExists( item, "items" ) && arrayLen(item.items) > 0 ) {
				printTree(item.items, arguments.level + 1);
			}
		}
	}

	private Array function getRecursiveTree(
		required Numeric parentId
    ) {

		var result = [];

		var items = list( parentId = arguments.parentId );

        for( var item in items ) {

            var itemRows = getRecursiveTree( parentId=item.getId() );

			if( ArrayLen( itemRows ) ) {
				item.setChildren( itemRows );
			}

			ArrayAppend( result, item );

        }

		return result;
		
	}	

	private com.apirone.core.model.bean.ProductItem function build(
    		required String productItemId
    	){

	    var record = getDao().read( arguments.productItemId );

	    if( record.recordCount ) { 

            var bean = super.bean( "ProductItem" );

            bean.setId( record.product_item_id );
            bean.setCombinationId( record.combination_id );
			bean.setCreatedAt( record.created_at );
			bean.setParent( get( record.parent_id ) );
			bean.setOrderBy( record.orderby );

            bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );
            
			bean.setAttributeValue( attributeValue );
            bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
            bean.setChildren( [] );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "ProductItem_#arguments.id#";

  	}

}
