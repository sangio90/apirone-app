component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductItemDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="attributeService" type="com.apirone.core.model.service.AttributeService";
	property name="attributeValueService" type="com.apirone.core.model.service.AttributeValueService";
	property name="combinationComponentService" type="com.apirone.core.model.service.CombinationComponentService";
	property name="componentService" type="com.apirone.core.model.service.ComponentService";
	
	property name="cacheScope" type="String" default="ProductItem.bean";

    public com.apirone.core.model.bean.ProductItem function get(
    		required String productItemId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.productItemId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.productItemId );
		cm.put( getCacheScope(), arguments.productItemId, bean );
        
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
            required String orderBy="",
			required Boolean includeMissingValues=true,
    ) {

        var result = [];
		var rows = [];

        var fruitId = arguments.fruitId;
        var combinationId = arguments.combinationId;

        var items = list( 
            combinationId = arguments.combinationId,
            fruitId = arguments.fruitId,
            parentId = arguments.parentId
        );

		if( arguments.includeMissingValues ) {
			rows = listWithMissingValues( items );
		} else {
			rows = items;
		}
		
		/*

        for( var item in items ) {
			dump( "#item.getOrderBy()# - #item.getId()# - #item.getAttribute().getName()# : #item.getAttributeValue().getRawValue().getName()#" );
		}
					
		dump("=============================================================================================================================================")
		dump("=========#arguments.level#")

		dump( arguments );

		dump("<br>");

        for( var row in rows ) {
        	dump( "#arguments.level# - #row.getOrderBy()# - #row.getId()# - #row.getAttribute().getName()# : #row.getAttributeValue().getRawValue().getName()#" );
        }
		*/

        var thisLevel = arguments.level;
        var includeMissingValues = arguments.includeMissingValues;

        var n = 1;

        for( var row in rows ) {

			//if( item.getId() > 0 ) {

				var thisOrderBy = "#arguments.orderBy#.#n#";
        		var parentId = row.getId();

				row.setLevel( arguments.level );

				result.add( row );
				
				var rows = getFlatTree( fruitId, combinationId, parentId, thisLevel+1, thisOrderBy, includeMissingValues );

				result = result.merge( rows );

				n++;
			
			//}

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

                getDao().delete( getCacheScope(), arguments.combinationId );
        
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
			required com.apirone.core.model.bean.ProductItem ProductItem
		){

		var newId = getDao().insert( arguments.ProductItem );

		return newId;

	}


	public String function update(
			required com.apirone.core.model.bean.ProductItem productItem
		){

		var newId = getDao().update( arguments.productItem );

		super.getCacheManager().remove( getCacheScope(), arguments.productItem.getId() );

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

	private Array function calcultateAttributes(
		required Array rows
    ) {

		var attrs = [];

		Boolean function exists( required attributeId, required attrs ) {

			for( var attr in arguments.attrs ) {
				if( attr.getId() == arguments.attributeId ) {
					return true;
				}
			}

			return false
		}

		for( var row in rows ) {

			if( !exists( row.getAttribute().getId(), attrs ) ) {

				//attribute with all values
				attrs.add( getAttributeService().get( row.getAttribute().getId() ) );

			}


		}

		return attrs;
		
	}	

	private Array function listWithMissingValues(
		required Array productItems
    ) {

		var values = [];

		var items = Duplicate( arguments.productItems );

		//1. calcolo gli attributi dei valori recuperati
		var attrs = calcultateAttributes( arguments.productItems );

		for( var thisAttr in attrs ) {

			for( var thisValue in thisAttr.getValues() ) {

				//2. cerco i valori mancanti per ogni attributo

				var found = false;

				var index = 1;

				for( var thisProduct in arguments.productItems ) {

					if( thisAttr.getId() == thisProduct.getAttribute().getId() ) {

						if( thisValue.getRawValue().getId() == thisProduct.getAttributeValue().getRawValue().getId() ) {

							var found = true;
							//dump( "trovato: #thisAttr.getName()#: #thisValue.getRawValue().getName()# == #thisProduct.getAttributeValue().getRawValue().getName()#" );

						}

						var lastOrderby = thisProduct.getOrderBy();
						var lastAttribute = thisAttr;

						index++;

					}

				}

				if ( !found ) {

					var bean = super.bean( "ProductItem" );

					bean.setId( -1 );
					bean.setAttributeValue( thisValue );
					bean.setAttribute( lastAttribute );
					bean.setStatus( getStatusService().get( "DEA" ) );

					//attributeValue
					bean.setOrderBy( lastOrderby + 10 );

					items.insertAt( index, bean );

				}

			}

		}

		return items;

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

			bean.setParent( IsNull( record.parent_id ) ? NullValue() : get( record.parent_id ) );

			bean.setOrderBy( record.orderby );

            bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_raw_value_id );
			
			bean.setAttributeValue( attributeValue );

            bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
            bean.setComponentCount( getComponentService().count( productItemId=record.product_item_id ) );
            
			bean.setChildren( [] );
			
            return bean;

	    }

		return nullValue();

  	}

}
