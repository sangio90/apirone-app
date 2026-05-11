component extends="com.apirone.core.controller.AbsController" {

	function listCategories( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "typeId" ] = rc.typeId;

		var rows = super.fire( "productCategory.list" );
		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listLines( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "catalogBundleCategoryId" ] = rc.categoryId;

		var rows = super.fire( "line.list", params );

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listModels( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		param rc.catalogBundleCategoryId = "";

		params[ "catalogBundleLineId" ] = rc.lineId;

		if( Len( rc.catalogBundleCategoryId ) ){
			params[ "catalogBundleCategoryId" ] = rc.catalogBundleCategoryId;
		}

		var rows = super.fire( "model.list", params );

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listFinishes( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		params[ "lineId" ]            = rc.lineId;
		params[ "productCategoryId" ] = rc.categoryId;

		var rows = super.fire( "finish.list", params );
		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function list( event, rc, prc ){
		var data = [];
		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();
		var user = session.user;
		if (!isNull(user) && !isNull(user.getRole())) {
			if (user.getRole().getId() == 'CMJ') {
				params['ownerId'] = user.getId();
			}
			if (user.getRole().getId() == 'PRO') {
				params['statusId'] = 'CON';
			}
		}
		var rows = super.fire( "quotation.search", params );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId    = "";
		var messageId = "";
		var result    = super.getResult();

		var currency      = super.bean( "Currency" );
		var quotation     = super.bean( "Quotation" );
		var paymentMethod = super.bean( "PaymentMethod" );

		quotation.setId( json.id );
		quotation.setName( json.name );
		//quotation.setQuotationNumber( json.quotationNumber );
		quotation.setOwner( session.user );

		quotation.setValidityDate( IsDate( json?.validityDate ) ? json.validityDate : NullValue() );
		quotation.setQuotationDate( IsDate( json?.quotationDate ) ? json.quotationDate : NullValue() );
		quotation.setNote( json.note );

		quotation.setActive( true );
		quotation.setLang( super.fire( "lang.get", [ json.lang.id ] ) );


		if ( Val( json?.vatCode?.id ) ) {
			quotation.setVatCode( super.fire( "vatCode.get", [ json.vatCode.id ] ) );
		};

		if ( Len( json?.opportunity?.id ) ) {
			quotation.setOpportunity( super.fire( "opportunity.get", [ json.opportunity.id ] ) );
		};

		if ( Len( json?.lead?.id ) ) {
			quotation.setLead( super.fire( "lead.get", [ json.lead.id ] ) );
		};

		if ( Len( json?.customer?.id ) ) {
			quotation.setCustomer( super.fire( "customer.get", [ json.customer.id ] ) )
		}

		if ( Len( json?.salesAgent?.id ) ) {
			quotation.setSalesAgent( super.fire( "user.get", [ json.salesAgent.id ] ) )
		}

		if ( Len( json?.graphicTechnician?.id ) ) {
			quotation.setGraphicTechnician( super.fire( "user.get", [ json.graphicTechnician.id ] ) )
		}

		if ( Len( json?.shippingProfile?.id ) ) {
			quotation.setShippingProfile( super.bean("ShippingProfile").setId( json.shippingProfile.id ) );
		}

		quotation.setPaymentMethod( paymentMethod.setId( json.paymentMethod.id ) );
		quotation.setCurrency( currency.setId( json.currency.id ) );

		quotation.setAgente1( json.agente1?.id );
		quotation.setAgente2( json.agente2?.id );
		quotation.setAgente3( json.agente3?.id );
		quotation.setAgente4( json.agente4?.id );
		quotation.setAgente5( json.agente5?.id );
		quotation.setNessunAgente( json.nessunAgente );

		if ( !Len( json.id ) ) {

			thisId = super.fire( "quotation.create", [ quotation, session.user.getId() ] );
			messageId = "quotation.created";

		} else {
			thisId    = super.fire( "quotation.update", [ quotation ] )
			messageId = "quotation.updated";
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message, "payload" = { "id" = thisId }, "error" = {} } );
		event.setValue( "result", result );
	}

	function approveQuotation( event, rc, prc ) {
		var thisId = "";
		var message = "Preventivo approvato.";
		var result    = super.getResult();

		var isValid = true;
		var quotationId = rc.id

		try {
			transaction {
				var history = super.bean( "QuotationStatusHistory" );
				history.setQuotationId( quotationId );
				history.setUser( session.user );
				var quotation = super.fire( 'quotation.get', [ quotationId ] );
				var userRole = session.user.getRole().getId();

				if (!ArrayContains(['ADM', 'CMA'], userRole)) {
					var totals = getTotals(quotationId).pricing
					var totalPrice = totals.total

					if (session.user.getRole().getQuotationMaxAmount() && session.user.getRole().getQuotationMaxAmount() > 0 && totalPrice > session.user.getRole().getQuotationMaxAmount()) {
						isValid = false;
						message = "Approvazione rimandata ad un superiore, il prezzo totale del preventivo è " & numberFormat( totalPrice, "999,999.00" ) & " €, ed è maggiore del tuo massimale: " & numberFormat( session.user.getRole().getQuotationMaxAmount(), "999,999.00" ) &  " €";

						history.setStatus( super.fire( 'status.get', [ 'PEN' ] ) );
						super.fire('Quotation.promoteStatus', { 'quotation': quotation });
						super.fire('QuotationStatusHistory.create', [ history ] );

						result.setData( { "message" = message, "error" = {} } );
						result.setStatus('warning')
						event.setValue( "result", result );
						return;
					}

					if (isValid) {
						var quotationDiscount1 = totals.discount1
						var quotationDiscount2 = totals.discount2

						var quotationItems = super.fire( 'QuotationItem.list', [ quotationId = quotationId ] )

						for (var quotationItem in quotationItems) {
							if (!isNull(quotationItem.getArticle())) {
								continue;
							}
							isValid = super.fire( 'QuotationItem.validateQuantity', [ quotation, quotationItem ])
							if (!IsValid) {
								var message = "C'è almeno un prodotto nel preventivo che sfora le quantità minima o massima. Approvazione rimandata ad un superiore.";

								history.setStatus( super.fire( 'status.get', [ 'PEN' ] ) );
								super.fire('Quotation.promoteStatus', { 'quotation': quotation });
								super.fire('QuotationStatusHistory.create', [ history ] );

								result.setData( { "message" = message, "error" = {} } );
								result.setStatus('warning')
								event.setValue( "result", result );
								return;
							}
							isValid = super.fire( 'QuotationItem.validateDiscounts', [
								session.user.getRole().getQuotationMaxDiscount(),
								quotationDiscount1,
								quotationDiscount2,
								quotationItem.getPrice().getDiscount1(),
								quotationItem.getPrice().getDiscount2()
							])

							if (!IsValid) {
								var message = "C'è almeno una riga del preventivo che supera il tuo massimale di sconto. Approvazione rimandata ad un superiore.";

								history.setStatus( super.fire( 'status.get', [ 'PEN' ] ) );
								super.fire('Quotation.promoteStatus', { 'quotation': quotation });
								super.fire('QuotationStatusHistory.create', [ history ] );

								result.setData( { "message" = message, "error" = {} } );
								result.setStatus('warning')
								event.setValue( "result", result );
								return;
							}
						}
					}
				}

				history.setStatus( super.fire( 'status.get', [ 'APR' ] ) );
				super.fire('QuotationStatusHistory.create', [ history ] );
			}
		} catch (e) {
			message = "Errore durante l'approvazione del preventivo: " & e.Message
			result.setData( { "message" = message, "error" = {} } );
			result.setStatus('error')
			event.setValue( "result", result );
		}


		result.setData( { "message" = message, "error" = { } } );
		event.setValue( "result", result );
	}

	function setQuotationStatusHistory(json) {
		var quotationStatusHistories = super.fire( "QuotationStatusHistory.list", [ "quotationId" = json.id ] );
		//gli status history sono ordinati per data creazione decrescente, quindi cerco l'ultimo e verifico che lo status sia diverso. Se è diverso ne creo uno nuovo, altrimenti sono in modifica.
		if ( quotationStatusHistories.len() > 0 && quotationStatusHistories[1].getStatus().getId() == json.status.id ) {
			var quotationStatusHistory = quotationStatusHistories[1];
			thisId = quotationStatusHistory.getId();
		} else {
			var quotationStatusHistory = super.bean( "QuotationStatusHistory" );
			quotationStatusHistory.setQuotationId( json.id );
			quotationStatusHistory.setAccount( session.user.getAccount() );
			quotationStatusHistory.setStatus( super.service( "Status" ).get( json.status.id ) );
			messageId = "quotationStatusHistory.created";
			thisId    = super.fire( "quotationStatusHistory.create", [ quotationStatusHistory ] );
		}

		if ( StructKeyExists( json, "statusFile" ) AND json.status.id == 'CCN' ) {
			var tmpDir = getTempDir();
			var extension = super.fire( "File.getExtensionFromDataUrl", [ json.statusFile.file ] );
			if (IsNull(extension)) {
				return "Formato File non valido.";
			}
			fileName   = "quotation_status_history_" & json.id & "_" & json.status.id & "." & extension;
			filePath   = tmpDir & "/" & fileName;
			binaryData = ToBinary( json.statusFile.file );

			FileWrite( filePath, binaryData );

			var files = super.fire( "File.search", { quotationStatusHistoryId = thisId } );
			if ( Len( files.getData() ) ) {
				for ( var file in files.getData() ) {
					super.fire( "File.delete", { fileId = file.getId() } );
				}
			}

			var entity = super.bean( "Entity" );

			var kindId = "quotationStatusHistory";
			entity.setKey( "quotationStatusHistory.id" );
			entity.setValue( thisId );

			var fileId = super.fire(
				"file.create",
				{
					filePath = filePath,
					typeId   = "default",
					kindId   = kindId,
					entity   = entity
				}
			);
		}

		return null;
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var messageId = "quotation.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var id = rc.id
		var outcome = super.fire( "quotation.delete", [ id ] );

		if ( outcome.getStatus() == "ERROR" ) {
			errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
		}

		if ( errors.len() ) {
			messageId = "quotation.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

	function crmCustomers( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "customer.search", [ rc.str ] );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmOpportunities( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var mem    = super.getMementify();

		var rows = super.fire( "opportunity.search", [ rc.str ] );
		var data = mem.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function crmLeads( event, rc, prc ){
		param rc.str = "";

		var result = super.getResult();
		var memy   = super.getMementify();

		var rows = super.fire( "lead.search", [ rc.str ] );

		var data = memy.convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();
		var memy   = super.getMementify();

		var bean = super.fire( "Quotation.get", [ rc.id ] );
		var data = memy.convert( bean, "detail" );

		event.setValue( "result", data );
	}

	function updateTotals( event, rc, prc ){

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var pricing = super.bean( "QuotationPrice" );
		var service = super.service( "QuotationPrice" );

		pricing.setQuotationId( rc.id );
		pricing.setDiscount1( Val( json?.discount1 ) ? json.discount1 : 0 );
		pricing.setDiscount2( Val( json?.discount2 ) ? json.discount2 : 0 );
		pricing.setFlatDiscount( Val( json?.flatDiscount ) ? json.flatDiscount : 0 );

		pricing.setShippingCost( Len( json?.shippingCost ) ? json.shippingCost : 0 );

		service.save( pricing );

		var data = getTotals( rc.id );

		event.setValue( "result", data );

	}

	function totals( event, rc, prc ){

		var data = getTotals( rc.id );

		event.setValue( "result", data );

	}

	function exportProducts( event, rc, prc ){
		var data = [];

		var result = super.getResult();

		var quotationItems = super.fire( "QuotationItem.list", [ "quotationId" = rc.id ] );

		var result         = super.fire( "Quotation.exportProducts", [ quotationItems ] );

		event.setValue( "result", result );
	}

	function export( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();

		params[ "id" ] = rc.id;

		var quotationItems = super.fire( "QuotationItem.list", [ "quotationId" = rc.id ] );
		var result         = super.fire( "Quotation.export", [ quotationItems ] );

		if (result.success) {
			var quotation = super.fire( "Quotation.get",[ rc.id ]);
			quotation.setExported( true );
			super.fire( "quotation.update", [ quotation ] );
		}

		event.setValue( "result", result );
	}


	/*
		private methods
	*/

	private Struct function getQuantities( quotationId ){

		var acc = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "ACC" );
		var accQuantity = 0;
		var accessoriesTotalPrice = 0;
		for ( var item in acc ) {
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			accQuantity += item.getQuantity() * zoneQuantity;
			accessoriesTotalPrice += item.getQuantity() * zoneQuantity * item.getPrice().getTotal();
		}
		var pla = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "PLA" );
		var plaQuantity = 0;
		var platesTotalPrice = 0;
		for ( var item in pla ) {
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			plaQuantity += item.getQuantity() * zoneQuantity;
			platesTotalPrice += item.getQuantity() * zoneQuantity * item.getPrice().getTotal();
		}
		var seg = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "SEG" );
		var segQuantity = 0;
		var signagesTotalPrice = 0;
		for ( var item in seg ) {
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			segQuantity += item.getQuantity() * zoneQuantity;
			signagesTotalPrice += item.getQuantity() * zoneQuantity * item.getPrice().getTotal();
		}
		var art = super.service( "QuotationItem" ).list( quotationId = quotationId, typeId = "ART" );
		var artQuantity = 0;
		var articlesTotalPrice = 0;
		for ( var item in art ) {
			var zone = item.getQuotationZone()
			var originZone = zone.getOrigin()
			var zoneQuantity = zone.getQuantity();
			if (!isNull(originZone)) {
				zoneQuantity *= originZone.getQuantity()
			}
			artQuantity += item.getQuantity() * zoneQuantity;
			articlesTotalPrice += item.getQuantity() * zoneQuantity * item.getPrice().getTotal();
		}

		var data = {
			"accessories" = accQuantity,
			"accessoriesTotalPrice" = accessoriesTotalPrice,
			"plates" = plaQuantity,
			"platesTotalPrice" = platesTotalPrice,
			"signages" = segQuantity,
			"signagesTotalPrice" = signagesTotalPrice,
			"articles" = artQuantity,
			"articlesTotalPrice" = articlesTotalPrice,
		}

		return data;

	}

	public Struct function getTotals( quotationId ){

		var service = super.service( "QuotationPrice" );

		var result = service.calculate( quotationId );
		var counters = getQuantities( quotationId );

		var values = result.getCalculatedTotals();

		var data = {
			"counters" = counters,
			"pricing" = values,
			"currency" = result.getCurrency()
		}

		return data;

	}

}
