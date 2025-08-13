component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	public AbsCatalogBundle function init(){
		var bundle = new com.apirone.core.model.bean.CatalogBundle();
		setCatalogBundle( bundle );
		return this;
	}

	public com.apirone.core.model.bean.Line function getLine(){
		return getCatalogBundle().getLine();
	}
	public com.apirone.core.model.bean.Model function getModel(){
		return getCatalogBundle().getModel();
	}
	public com.apirone.core.model.bean.ProductCategory function getCategory(){
		return getCatalogBundle().getCategory();
	}

	public com.apirone.core.model.bean.Line function setLine( required any line ){
		getCatalogBundle().setLine( arguments.line );
	}
	public com.apirone.core.model.bean.Model function setModel( required any model ){
		var bundle = new com.apirone.core.model.bean.CatalogBundle();
		// bundle.setId( getCatalogBundle().getId() );
		getCatalogBundle().setModel( arguments.model );
	}
	public com.apirone.core.model.bean.ProductCategory function setCategory( required any category ){
		getCatalogBundle().setCategory( arguments.category );
	}

}
