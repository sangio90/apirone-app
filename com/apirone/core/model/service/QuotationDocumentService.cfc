component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationDocumentDAO";

	public Array function list( required String quotationId ){
		var records = getDao().find( quotationId = arguments.quotationId );
		var rows    = [];

		records.each( function( record ){
			rows.add( build( record ) );
		} );

		return rows;
	}

	public String function create( required com.apirone.core.model.bean.QuotationDocument doc ){
		var nextOrder = getNextSortOrder( arguments.doc.getQuotationId() );
		arguments.doc.setSortOrder( nextOrder );
		return getDao().insert( arguments.doc );
	}

	public void function updateSortOrder( required String quotationDocumentId, required Numeric sortOrder ){
		getDao().updateSortOrder( arguments.quotationDocumentId, arguments.sortOrder );
	}

	public void function delete( required String quotationDocumentId ){
		getDao().delete( arguments.quotationDocumentId );
	}

	public com.apirone.core.model.bean.QuotationDocument function get( required String quotationDocumentId ){
		var record = getDao().read( arguments.quotationDocumentId );
		if ( record.recordCount ) {
			return build( record );
		}
		return NullValue();
	}

	private com.apirone.core.model.bean.QuotationDocument function build( required Any record ){
		var bean = super.bean( "QuotationDocument" );
		bean.setId( arguments.record.quotation_document_id );
		bean.setQuotationId( arguments.record.quotation_id );
		bean.setOriginalName( arguments.record.original_name );
		bean.setStoredName( arguments.record.stored_name );
		bean.setDirectory( arguments.record.directory );
		bean.setSortOrder( Val( arguments.record.sort_order ) );
		bean.setCreatedAt( arguments.record.created_at );
		return bean;
	}

	private Numeric function getNextSortOrder( required String quotationId ){
		var docs = getDao().find( quotationId = arguments.quotationId );
		return docs.recordCount;
	}

}
