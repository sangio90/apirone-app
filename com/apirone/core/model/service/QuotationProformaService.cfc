component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="QuotationProformaDAO";

	public Array function list( required String quotationId ){
		var records = getDao().find( quotationId = arguments.quotationId );
		var rows    = [];

		records.each( function( record ){
			rows.add( build( record ) );
		} );

		return rows;
	}

	/**
	 * Vero se per questo preventivo il progressivo è già stato usato.
	 * La coppia (preventivo, progressivo) identifica la proforma: un progressivo
	 * già speso va rifiutato, non riscritto.
	 */
	public Boolean function existsProgressivo( required String quotationId, required String progressivo ){
		return getDao().existsProgressivo( arguments.quotationId, arguments.progressivo );
	}

	public String function create( required com.apirone.core.model.bean.QuotationProforma proforma ){
		return getDao().insert( arguments.proforma );
	}

	public void function delete( required String quotationProformaId ){
		getDao().delete( arguments.quotationProformaId );
	}

	public com.apirone.core.model.bean.QuotationProforma function get( required String quotationProformaId ){
		var record = getDao().read( arguments.quotationProformaId );

		if ( record.recordCount ) {
			return build( record );
		}

		return NullValue();
	}

	private com.apirone.core.model.bean.QuotationProforma function build( required Any record ){
		var bean = super.bean( "QuotationProforma" );

		bean.setId( arguments.record.quotation_proforma_id );
		bean.setQuotationId( arguments.record.quotation_id );
		bean.setProgressivo( arguments.record.progressivo );

		// colonne NUMERIC nullable: tornano Java null, non stringa vuota
		if ( !IsNull( arguments.record.percentuale ) ) {
			bean.setPercentuale( arguments.record.percentuale );
		}

		if ( !IsNull( arguments.record.importo ) ) {
			bean.setImporto( arguments.record.importo );
		}

		bean.setStoredName( arguments.record.stored_name );
		bean.setDirectory( arguments.record.directory );
		bean.setCreatedAt( arguments.record.created_at );

		if ( !IsNull( arguments.record.created_by ) && Len( arguments.record.created_by ) ) {
			bean.setCreatedBy( arguments.record.created_by );
		}

		return bean;
	}

}
