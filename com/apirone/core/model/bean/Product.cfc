component extends="com.apirone.core.model.bean.TranslatedBean" accessors="true" {

	this.memento = {
		defaultIncludes = [
			"id",
			"shortId",
			"name",
			"code",
			"category",
			"categories",
			"line",
			"model",
			"finish"
		],
		mappers  = {},
		profiles = {
			list = {
				defaultIncludes = [
					"id",
					"shortId",
					"name",
					"code",
					"nameItem",
					"status",
					"positionCount",
					"createdAt",
					"code",
					"categories",
					"category",
					"lines",
					"line",
					"model",
					"finish",
					"prices"
				]
			}
		}
	}

	/*
		complex (plates)
		TODO da cancellare line/model sostituite da bundle
		TODO: move to bundle:
			  - remove properties
			  - and shortcut getMolde(), setModel()
	*/
	property name="model" type="com.apirone.core.model.bean.Model";
	property name="line" type="com.apirone.core.model.bean.Line";
	property name="finish" type="com.apirone.core.model.bean.Finish";
	property name="status" type="com.apirone.core.model.bean.Status";

	/*
		simple (fruit)
	*/
	property name="code" type="String";
	property name="positionCount" type="Numeric";
	property name="lines" type="com.apirone.core.model.bean.Line[]";

	/*
		common fields
	*/
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="category" type="com.apirone.core.model.bean.ProductCategory";

	property name="catalogBundle" type="com.apirone.core.model.bean.CatalogBundle";

	// TODO: remove this for prices[]
	property name="pricesAsArray" type="Array" default=[];

	public Product function init(){
		variables.prices = {};
		return this;
	}

	public Struct function getPrice( required String typeId ){
		for ( var price in getPricesAsArray() ) {
			if ( price.getType().getId() EQ typeId ) {
				return price;
			}
		}
	}

	public Array function getPrices(){
		return this.getPricesAsArray();

		/*
		var result = {}

		for ( var price in getPricesAsArray() ) {
			// TODO: avoid "MEMENTO" key
			// let's try...

			StructDelete( price, "memento" );
			StructDelete( price.getType(), "memento" );
			StructDelete( price.getType().getStatus(), "memento" );
			StructDelete( price.getMethod(), "memento" );

			result[ price.getType().getId() ] = price;
		}

		return result;
		*/
	}

	public Array function setPrices(){
		Throw( type = "NotImplemented", message = "Use setPricesAsArray( price[] ) instead" );
	}

}
