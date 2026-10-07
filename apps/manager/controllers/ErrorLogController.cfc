component extends="com.apirone.core.controller.AbsController" {

	variables.PAGE_SIZE = 50;

	/**
	 * Elenco degli errori registrati da apps/utils/errorReport.cfm ( solo ADM ).
	 */
	function list( event, rc, prc ){
		param rc.str  = "";
		param rc.page = 1;

		prc.title = "Log errori";
		prc.str   = Trim( rc.str );
		prc.page  = ( IsNumeric( rc.page ) && rc.page >= 1 ) ? Int( rc.page ) : 1;

		prc.rows  = super.service( "ErrorLog" ).search(
			str    = prc.str,
			limit  = variables.PAGE_SIZE,
			offset = ( prc.page - 1 ) * variables.PAGE_SIZE
		);
		prc.total = prc.rows.recordCount ? prc.rows.total[1] : 0;
		prc.pages = Max( 1, Ceiling( prc.total / variables.PAGE_SIZE ) );

		event.setView( "error-log/list" );
	}

	function detail( event, rc, prc ){
		prc.row = super.service( "ErrorLog" ).get( IsNumeric( rc.id ) ? rc.id : 0 );

		if ( !prc.row.recordCount ) {
			relocate( uri="/manager/error-logs", addToken=false );
			return;
		}

		prc.title = "Errore #prc.row.code#";

		event.setView( "error-log/detail" );
	}

	/**
	 * Report HTML completo, senza layout: lo carica l'iframe della pagina di
	 * dettaglio, così il suo CSS non si mescola con quello del manager.
	 */
	function report( event, rc, prc ){
		var row = super.service( "ErrorLog" ).get( IsNumeric( rc.id ) ? rc.id : 0 );

		event.renderData(
			data        = row.recordCount ? row.report_html : "Report non trovato.",
			type        = "text",
			contentType = "text/html"
		);
	}

}
