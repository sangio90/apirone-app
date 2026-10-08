/**
 * Eliminazione di elementi di catalogo ( prodotti, righe attributo-valore dei
 * prodotti, attributi, valori ) in base al loro uso nei preventivi:
 * - usati in un preventivo in corso: non si eliminano, si restituisce dove sono
 *   usati perché l'utente li tolga prima dai preventivi;
 * - usati solo in preventivi chiusi ( closedStatusIds ): eliminazione logica
 *   ( deleted_at ), restano nei preventivi che li usano ma da ora non sono più
 *   a catalogo né selezionabili;
 * - mai usati: cancellazione vera.
 * Contano tutte le versioni di un preventivo.
 */
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="CatalogUsageDAO";

	/**
	 * Stati di un preventivo chiuso: un elemento usato solo in questi si può eliminare.
	 */
	public Array function closedStatusIds(){
		return [ "CON", "PER", "EST" ];
	}

	/**
	 * Uso nei preventivi degli elementi indicati ( argomenti di
	 * CatalogUsageDAO.findQuotationUsage ).
	 * open: preventivi in corso, nel formato mostrato dalla modale "in uso"
	 * ( { id, number, version, items: [ { zoneId, zoneName, type, count, itemIds } ] } );
	 * closed: quanti preventivi chiusi li usano.
	 */
	public Struct function usage(){
		var records    = getDao().findQuotationUsage( argumentCollection = arguments );
		var closedIds  = closedStatusIds();
		var open       = [];
		var byId       = {};
		var closedSeen = {};

		for ( var row in records ) {
			if ( ArrayContains( closedIds, row.status_id ) ) {
				closedSeen[ row.quotation_id ] = true;
				continue;
			}

			if ( !byId.keyExists( row.quotation_id ) ) {
				byId[ row.quotation_id ] = {
					"id"      = row.quotation_id,
					"number"  = row.quotation_number,
					"version" = row.version_number ?: "",
					"items"   = []
				};
				open.append( byId[ row.quotation_id ] );
			}

			byId[ row.quotation_id ].items.append( {
				"zoneId"   = row.zone_id,
				"zoneName" = row.quotation_zone ?: "",
				"type"     = row.type_id ?: "",
				"count"    = row.item_count,
				"itemIds"  = ListToArray( row.item_ids )
			} );
		}

		return { "open" = open, "closed" = StructCount( closedSeen ) };
	}

	/**
	 * Elimina gli elementi indicati secondo il loro uso nei preventivi.
	 * target: argomenti di usage() / softDelete(); hardDelete: closure che fa la
	 * cancellazione vera ( lancia un errore se non riesce ).
	 * Restituisce { result, quotations, closed }, result:
	 * IN_USE ( usati in preventivi in corso, elencati in quotations ),
	 * DEACTIVATED ( eliminazione logica ), DELETED.
	 */
	public Struct function remove( required Struct target, required any hardDelete ){
		var used = usage( argumentCollection = arguments.target );

		if ( used.open.len() ) {
			return { "result" = "IN_USE", "quotations" = used.open, "closed" = used.closed };
		}

		if ( used.closed ) {
			softDelete( argumentCollection = arguments.target );
			return { "result" = "DEACTIVATED", "quotations" = [], "closed" = used.closed };
		}

		arguments.hardDelete();
		return { "result" = "DELETED", "quotations" = [], "closed" = 0 };
	}

	/**
	 * remove() su più elementi dello stesso tipo. targetKey: argomento di usage()
	 * ( es. "attributeIds" ); hardDelete( id ): cancellazione vera, restituisce un
	 * Outcome. { quotations ( preventivi in corso che usano gli elementi non
	 * eliminati ), deactivated ( quanti eliminati logicamente ), errors }.
	 */
	public Struct function removeMany( required String targetKey, required Array ids, required any hardDelete ){
		var summary = { "quotations" = [], "deactivated" = 0, "errors" = [] };
		var seen    = {};
		var deleter = arguments.hardDelete;

		for ( var id in arguments.ids ) {
			var thisId = id;
			var state  = {};
			var target = {};
			target[ arguments.targetKey ] = [ thisId ];

			var removed = remove( target, function(){
				state.outcome = deleter( thisId );
			} );

			if ( removed.result == "IN_USE" ) {
				for ( var quotation in removed.quotations ) {
					if ( !seen.keyExists( quotation.id ) ) {
						seen[ quotation.id ] = true;
						summary.quotations.append( quotation );
					}
				}
			} else if ( removed.result == "DEACTIVATED" ) {
				summary.deactivated++;
			} else if ( state.keyExists( "outcome" ) && state.outcome.getStatus() == "ERROR" ) {
				summary.errors.append( { "message" = "Non sono riuscito a cancellare l'Id #thisId#" } );
			}
		}

		return summary;
	}

	/**
	 * Eliminazione logica ( argomenti di CatalogUsageDAO.softDelete ).
	 */
	public void function softDelete(){
		getDao().softDelete( argumentCollection = arguments );
	}

	/**
	 * Righe di un preventivo con elementi non più a catalogo: revisione e duplica
	 * non le copiano. { itemIds ( struct id -> true ), labels ( cosa non è più a
	 * catalogo, senza doppioni ), labelsByItem ( id -> labels della riga ) }.
	 */
	public Struct function deletedInQuotation( required String quotationId ){
		return groupDeleted( getDao().findDeletedInQuotation( quotationId = arguments.quotationId ) );
	}

	/**
	 * Cosa non è più a catalogo in una riga di preventivo ( avviso in modifica ).
	 */
	public Array function deletedInQuotationItem( required String quotationItemId ){
		if ( !REFind( "^[0-9a-fA-F-]{36}$", arguments.quotationItemId ) ) {
			return [];
		}
		return groupDeleted( getDao().findDeletedInQuotation( quotationItemId = arguments.quotationItemId ) ).labels;
	}

	/**
	 * labels di deletedInQuotation() limitate alle righe indicate ( es. quelle
	 * saltate duplicando una zona ).
	 */
	public Array function labelsOfItems( required Struct deleted, required Array itemIds ){
		var labels = [];
		for ( var itemId in arguments.itemIds ) {
			for ( var label in arguments.deleted.labelsByItem[ itemId ] ?: [] ) {
				if ( !ArrayContains( labels, label ) ) {
					labels.append( label );
				}
			}
		}
		return labels;
	}

	private Struct function groupDeleted( required Query records ){
		var result = { "itemIds" = {}, "labels" = [], "labelsByItem" = {} };

		for ( var row in arguments.records ) {
			result.itemIds[ row.quotation_item_id ] = true;
			if ( !ArrayContains( result.labels, row.label ) ) {
				result.labels.append( row.label );
			}
			if ( !result.labelsByItem.keyExists( row.quotation_item_id ) ) {
				result.labelsByItem[ row.quotation_item_id ] = [];
			}
			result.labelsByItem[ row.quotation_item_id ].append( row.label );
		}

		return result;
	}

	/**
	 * Prodotto di una riga di preventivo ( stringa vuota se non c'è ): nei
	 * configuratori resta selezionabile anche se eliminato dal catalogo.
	 */
	public String function quotationItemProductId( String quotationItemId = "" ){
		if ( !REFind( "^[0-9a-fA-F-]{36}$", arguments.quotationItemId ) ) {
			return "";
		}
		return getDao().readQuotationItemProductId( arguments.quotationItemId );
	}

	/**
	 * Un prodotto eliminato logicamente torna a catalogo ( es. riaggiunto dalla
	 * matrice linea / modello / finitura ).
	 */
	public void function restoreProduct( required String productId ){
		getDao().restoreProduct( arguments.productId );
	}

}
