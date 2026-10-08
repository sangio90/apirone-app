/**
 * Pianificazione ( Gantt ): persone con tipo di lavoro e ore disponibili per
 * giorno della settimana, ore di attività stimate per preventivo.
 * I tipi di lavoro ( config/data/workTypes.json.cfm ) sono anche i tipi di
 * attività del preventivo: le ore di montaggio vanno ai montatori, quelle di
 * produzione agli addetti alla produzione, e così via.
 */
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PlanningDAO";
	property name="accountService" inject="AccountService";
	property name="userService" inject="UserService";
	property name="workCalendarService" inject="WorkCalendarService";

	/**
	 * Ore di default quando a una persona si assegna un tipo: 8h dal lunedì al
	 * venerdì, sabato e domenica liberi.
	 */
	variables.DEFAULT_HOURS = [ 8, 8, 8, 8, 8, 0, 0 ];

	variables.HOURS_COLUMNS = [ "hours_mon", "hours_tue", "hours_wed", "hours_thu", "hours_fri", "hours_sat", "hours_sun" ];

	public Array function workTypes(){
		return DeserializeJSON( FileRead( ExpandPath( "/config/data/workTypes.json.cfm" ) ) );
	}

	public Array function workTypeIds(){
		return workTypes().map( function( type ){ return type.id; } );
	}

	public Array function defaultHours(){
		return Duplicate( variables.DEFAULT_HOURS );
	}

	/* ======================= Persone ======================= */

	/**
	 * Persone per la pagina Disponibilità e per il Gantt ( onlyWithType ):
	 * { id, name, roleId, active, workTypeId, hours: [ lun .. dom ] }.
	 */
	public Array function listPeople( Boolean onlyWithType = false ){
		var result = [];

		for ( var row in getDao().findPeople( arguments.onlyWithType ) ) {
			var hours = [];
			for ( var column in variables.HOURS_COLUMNS ) {
				hours.append( Val( row[ column ] ) );
			}

			result.append( {
				"id"         = row.user_id,
				"name"       = row.name ?: "",
				"roleId"     = row.role_id,
				"active"     = row.status_id == "ACT",
				"workTypeId" = row.work_type_id ?: "",
				"hours"      = hours,
				"dayStart"   = formatTime( Val( row.day_start_minutes ) ),
				// tariffa in vigore oggi ( stringa vuota se non c'è )
				"hourlyCost"    = IsNumeric( row.hourly_cost ?: "" ) ? Val( row.hourly_cost ) : "",
				"costValidFrom" = IsDate( row.cost_valid_from ?: "" ) ? DateFormat( row.cost_valid_from, "yyyy-mm-dd" ) : ""
			} );
		}

		return result;
	}

	/**
	 * Tipo di lavoro ( stringa vuota: la persona non si pianifica ) e ore da
	 * lunedì a domenica.
	 */
	public void function savePerson( required String userId, required String workTypeId, required Array hours, String dayStart = "08:00" ){
		if ( Len( arguments.workTypeId ) && !ArrayContains( workTypeIds(), arguments.workTypeId ) ) {
			Throw( type = "apirone.planning.InvalidWorkType", message = "Tipo di lavoro non valido: #arguments.workTypeId#" );
		}
		if ( ArrayLen( arguments.hours ) != 7 ) {
			Throw( type = "apirone.planning.InvalidHours", message = "Servono le ore dei 7 giorni della settimana." );
		}

		var cleanHours = arguments.hours.map( function( value ){
			var hours = IsNumeric( value ) ? value : 0;
			return Min( Max( hours, 0 ), 24 );
		} );

		parseTime( arguments.dayStart );
		getDao().updatePerson( arguments.userId, arguments.workTypeId, cleanHours, arguments.dayStart );
	}

	/**
	 * Persona senza accesso all'app ( es. un montatore ): account e utente
	 * disattivati, con un'email segnaposto ( l'email è obbligatoria ) e una
	 * password casuale. Ruolo Produzione, ore di default.
	 */
	public String function createPerson( required String name, required String workTypeId ){
		if ( !Len( Trim( arguments.name ) ) ) {
			Throw( type = "apirone.planning.NameRequired", message = "Il nome è obbligatorio." );
		}

		var status  = super.bean( "Status" ).setId( "DEA" );
		var account = super.bean( "Account" );
		account.setName( Trim( arguments.name ) );
		// corta: l'email viene salvata cifrata in una colonna da 225 caratteri
		account.setEmail( "p" & LCase( Left( Hash( CreateUUID() ), 10 ) ) & "@noemail.local" );
		account.setPwd( Hash( CreateUUID() & CreateUUID(), "SHA-256" ) );
		account.setStatus( status );

		var user = super.bean( "User" );
		user.setName( Trim( arguments.name ) );
		user.setPhone( "" );
		user.setStatus( super.bean( "Status" ).setId( "DEA" ) );
		user.setRole( super.bean( "Role" ).setId( "PRO" ) );
		user.setLang( super.bean( "Lang" ).setId( "IT" ) );

		transaction {
			var accountId = getAccountService().create( account );
			user.setAccount( super.bean( "Account" ).setId( accountId ) );
			var userId = getUserService().create( user );
			savePerson( userId, arguments.workTypeId, defaultHours() );
		}

		return userId;
	}

	/* ======================= Progetti ( ore dei preventivi ) ======================= */

	/**
	 * Preventivi pianificabili ( "Confermato da cliente" / "Convertito in
	 * ordine", più quelli che hanno già blocchi nel Gantt ) con ore stimate e
	 * pianificate per tipo ( hours: { MON: { estimated, planned }, ... } ) e
	 * stato del progetto ( completed: concluso, non si pianifica più ).
	 */
	public Array function plannableQuotations(){
		var quotations = [];
		var byId       = {};

		for ( var row in getDao().findPlannableQuotations() ) {
			var quotation = {
				"id"         = row.quotation_id,
				"number"     = row.quotation_number,
				"version"    = row.version_number ?: "",
				"name"       = row.name ?: "",
				"rifLibero"  = row.rif_libero ?: "",
				"customer"   = row.customer ?: "",
				"statusId"   = row.status_id ?: "",
				"plannable"  = IsBoolean( row.plannable ?: "" ) && row.plannable,
				"completed"  = IsBoolean( row.completed ?: "" ) && row.completed,
				"hours"      = {}
			};
			quotations.append( quotation );
			byId[ row.quotation_id ] = quotation;
		}

		for ( var row in getDao().findPlannableQuotationHours() ) {
			if ( byId.keyExists( row.quotation_id ) ) {
				byId[ row.quotation_id ].hours[ row.work_type_id ] = {
					"estimated" = Val( row.estimated ),
					"budget"    = IsNumeric( row.budget ?: "" ) ? Val( row.budget ) : "",
					// pianificate sulla stima; le extra sono a parte
					"planned"   = Val( row.planned ),
					"extra"     = Val( row.extra )
				};
			}
		}

		return quotations;
	}

	/**
	 * Pagina Progetti: ore stimate e budget per tipo ( struct tipo -> valore;
	 * budget vuoto = nessun budget ) e progetto concluso. Si salvano anche su un
	 * preventivo bloccato: la pianificazione avviene dopo la conferma del cliente.
	 */
	public void function saveProject(
		required String quotationId,
		required Struct hours,
		Struct budgets = {},
		required Boolean completed,
		String userId = ""
	){
		transaction {
			saveQuotationWorkHours( arguments.quotationId, arguments.hours, arguments.budgets );
			getDao().setCompleted( arguments.quotationId, arguments.completed, arguments.userId );
		}
	}

	/**
	 * hours / budgets: struct tipo -> valore.
	 */
	public void function saveQuotationWorkHours( required String quotationId, required Struct hours, Struct budgets = {} ){
		var validIds = workTypeIds();

		for ( var workTypeId in arguments.hours ) {
			if ( !ArrayContains( validIds, UCase( workTypeId ) ) ) {
				continue;
			}
			var value  = IsNumeric( arguments.hours[ workTypeId ] ) ? Max( arguments.hours[ workTypeId ], 0 ) : 0;
			var budget = arguments.budgets[ workTypeId ] ?: "";
			budget = IsNumeric( budget ) && budget >= 0 ? budget : "";
			getDao().saveQuotationWorkHours( arguments.quotationId, UCase( workTypeId ), value, budget );
		}
	}

	/* ======================= Costi orari ======================= */

	/**
	 * Storico delle tariffe orarie di una persona, dalla più recente:
	 * [ { id, validFrom, hourlyCost, current } ] ( current: in vigore oggi ).
	 */
	public Array function personCosts( required String userId ){
		var result   = [];
		var today    = DateFormat( Now(), "yyyy-mm-dd" );
		var found    = false;

		for ( var row in getDao().findPersonCosts( arguments.userId ) ) {
			var validFrom = DateFormat( row.valid_from, "yyyy-mm-dd" );
			var current   = !found && validFrom <= today;
			if ( current ) found = true;

			result.append( {
				"id"         = row.cost_id,
				"validFrom"  = validFrom,
				"hourlyCost" = Val( row.hourly_cost ),
				"current"    = current
			} );
		}

		return result;
	}

	/**
	 * Tariffa valida da validFrom fino alla successiva ( stessa data: si sostituisce ).
	 */
	public void function savePersonCost( required String userId, required Date validFrom, required Numeric hourlyCost, String createdBy = "" ){
		if ( arguments.hourlyCost < 0 ) {
			Throw( type = "apirone.planning.InvalidCost", message = "Il costo orario non può essere negativo." );
		}
		getDao().savePersonCost( arguments.userId, arguments.validFrom, arguments.hourlyCost, arguments.createdBy );
	}

	public void function deletePersonCost( required Numeric costId ){
		getDao().deletePersonCost( arguments.costId );
	}

	/* ======================= Statistiche ======================= */

	/**
	 * Costi dei progetti rispetto al budget, per progetto e attività. Il costo
	 * viene dalle ore pianificate nel Gantt × tariffa della persona in vigore quel
	 * giorno ( non c'è un consuntivo ): "done" sono i giorni fino a oggi.
	 * [ { ...plannableQuotations, activities: [ { workTypeId, estimatedHours,
	 * budget, hours, doneHours, cost, doneCost, missingRateHours } ], totals } ]
	 * Solo i progetti con ore stimate, budget o ore pianificate.
	 */
	public Array function projectStats(){
		var costs = {};
		for ( var row in getDao().findCostStats() ) {
			costs[ row.quotation_id & "|" & row.work_type_id ] = row;
		}

		var types  = workTypes();
		var result = [];

		for ( var quotation in plannableQuotations() ) {
			var activities = [];
			var totals     = {
				"estimatedHours" = 0, "budget" = "", "hours" = 0, "doneHours" = 0,
				"cost" = 0, "doneCost" = 0, "missingRateHours" = 0,
				"extraHours" = 0, "extraCost" = 0
			};

			for ( var type in types ) {
				var estimate = quotation.hours[ type.id ] ?: {};
				var cost     = costs[ quotation.id & "|" & type.id ] ?: {};
				var activity = {
					"workTypeId"       = type.id,
					"estimatedHours"   = estimate.estimated ?: 0,
					"budget"           = estimate.budget ?: "",
					"hours"            = Val( cost.hours ?: 0 ),
					"doneHours"        = Val( cost.done_hours ?: 0 ),
					"cost"             = Val( cost.cost ?: 0 ),
					"doneCost"         = Val( cost.done_cost ?: 0 ),
					"missingRateHours" = Val( cost.missing_rate_hours ?: 0 ),
					"extraHours"       = Val( cost.extra_hours ?: 0 ),
					"extraCost"        = Val( cost.extra_cost ?: 0 )
				};

				if ( !activity.estimatedHours && !IsNumeric( activity.budget ) && !activity.hours ) {
					continue;
				}

				activities.append( activity );
				totals.estimatedHours   += activity.estimatedHours;
				totals.hours            += activity.hours;
				totals.doneHours        += activity.doneHours;
				totals.cost             += activity.cost;
				totals.doneCost         += activity.doneCost;
				totals.missingRateHours += activity.missingRateHours;
				totals.extraHours       += activity.extraHours;
				totals.extraCost        += activity.extraCost;
				if ( IsNumeric( activity.budget ) ) {
					totals.budget = Val( totals.budget ) + activity.budget;
				}
			}

			if ( activities.len() ) {
				quotation[ "activities" ] = activities;
				quotation[ "totals" ]     = totals;
				result.append( quotation );
			}
		}

		return result;
	}

	/* ======================= Gantt ======================= */

	/**
	 * Dati del Gantt per un intervallo di date:
	 * - people: persone con un tipo di lavoro ( listPeople );
	 * - quotations: preventivi pianificabili ( plannableQuotations ); i progetti
	 *   conclusi servono solo a dare un nome ai loro blocchi;
	 * - blocks: blocchi con almeno un giorno nell'intervallo, con tutti i giorni
	 *   ( days: [ { day, hours } ] ), inizio, fine e totale;
	 * - nonWorkingDays: sabati, domeniche, festivi e chiusure dell'intervallo.
	 */
	public Struct function ganttData( required Date fromDate, required Date toDate ){
		var quotations = plannableQuotations();

		var blocks      = [];
		var blocksById  = {};
		for ( var row in getDao().findBlocks( arguments.fromDate, arguments.toDate ) ) {
			if ( !blocksById.keyExists( row.block_id ) ) {
				var block = {
					"id"            = row.block_id,
					"quotationId"   = row.quotation_id,
					"userId"        = row.user_id,
					"workTypeId"    = row.work_type_id,
					"useSaturday"   = row.use_saturday ? true : false,
					"forceHolidays" = row.force_holidays ? true : false,
					"note"          = row.note ?: "",
					"extra"         = row.extra ? true : false,
					"days"          = [],
					"total"         = 0
				};
				blocks.append( block );
				blocksById[ row.block_id ] = block;
			}
			var day = DateFormat( row.day, "yyyy-mm-dd" );
			blocksById[ row.block_id ].days.append( { "day" = day, "hours" = Val( row.hours ), "start" = Val( row.start_minutes ) } );
			blocksById[ row.block_id ].total += Val( row.hours );
		}
		for ( var block in blocks ) {
			block[ "start" ] = block.days[ 1 ].day;
			block[ "end" ]   = block.days[ ArrayLen( block.days ) ].day;
		}

		return {
			"people"         = listPeople( onlyWithType = true ),
			"quotations"     = quotations,
			"blocks"         = blocks,
			"nonWorkingDays" = getWorkCalendarService().nonWorkingDays( arguments.fromDate, arguments.toDate )
		};
	}

	/* ======================= Blocchi ======================= */

	/*
		Regole ( il client disegna soltanto, decide tutto il server ):
		- capacità di un giorno = ore della persona per quel giorno della settimana;
		  sabati, domeniche, festivi e chiusure valgono 0, salvo che il blocco usi
		  i sabati ( useSaturday ) o forzi anche domeniche e festivi
		  ( forceHolidays, che comprende i sabati ): allora valgono le ore della
		  persona per quel giorno, o le sue ore massime dei feriali se sono 0;
		- un blocco nuovo riempie la capacità libera ( capacità meno le ore degli
		  altri blocchi della persona ) giorno per giorno: 12h su 8h/giorno libere
		  sono 8 + 4, i giorni già pieni si saltano;
		- spostare un blocco mantiene le ore di ciascun giorno sui giorni lavorabili
		  dalla nuova data ( anche su un'altra persona dello stesso tipo );
		- allungarlo o accorciarlo dal bordo destro ridistribuisce il totale sui
		  giorni lavorabili coperti, in proporzione alla capacità;
		- le ore di un singolo giorno si forzano a mano, anche oltre la capacità
		  ( il Gantt lo segna in rosso ).
	*/

	/**
	 * Giorni entro cui cercare spazio per un blocco.
	 */
	variables.HORIZON_DAYS = 370;

	/**
	 * extra: ore oltre la stima del progetto; tutte sul giorno scelto ( anche
	 * oltre la disponibilità: sono straordinari ), dall'ora indicata o dal primo
	 * spazio libero. Le altre si distribuiscono sulla capacità libera.
	 */
	public Numeric function createBlock(
		required String quotationId,
		required String userId,
		required String workTypeId,
		required Date start,
		required Numeric hours,
		Boolean extra = false,
		String startTime = "",
		String note = "",
		String createdBy = ""
	){
		var person = loadPerson( arguments.userId );
		checkWorkType( person, arguments.workTypeId );

		if ( arguments.hours <= 0 ) {
			Throw( type = "apirone.planning.InvalidHours", message = "Non ci sono ore da pianificare." );
		}

		var days = [];
		if ( arguments.extra ) {
			if ( arguments.hours > 24 ) {
				Throw( type = "apirone.planning.InvalidHours", message = "Le ore extra stanno in un solo giorno: al massimo 24." );
			}
			var key    = DateFormat( arguments.start, "yyyy-mm-dd" );
			var booked = bookedMap( person.id, arguments.start, arguments.start, 0 );
			var begin  = Len( arguments.startTime )
				? parseTime( arguments.startTime )
				: freeStart( person, booked[ key ] ?: [] );
			days = [ { "day" = key, "hours" = arguments.hours, "start" = begin } ];
		} else {
			days = distribute( person, arguments.start, arguments.hours, false, false, 0 );
		}

		transaction {
			var blockId = getDao().insertBlock(
				quotationId = arguments.quotationId,
				userId      = arguments.userId,
				workTypeId  = arguments.workTypeId,
				startDay    = DateFormat( arguments.start, "yyyy-mm-dd" ),
				note        = arguments.note,
				extra       = arguments.extra,
				createdBy   = arguments.createdBy
			);
			getDao().replaceBlockDays( blockId, days );
		}

		return blockId;
	}

	/**
	 * Sposta il blocco a una nuova data ( e persona, dello stesso tipo ),
	 * mantenendo le ore di ciascun giorno.
	 */
	public void function moveBlock( required Numeric blockId, required Date start, String userId = "" ){
		var block        = loadBlock( arguments.blockId );
		var targetUserId = Len( arguments.userId ) ? arguments.userId : block.userId;
		var person       = loadPerson( targetUserId );
		checkWorkType( person, block.workTypeId );

		var pattern    = block.days.map( function( day ){ return day.hours; } );
		var horizon    = DateAdd( "d", variables.HORIZON_DAYS, arguments.start );
		var nonWorking = getWorkCalendarService().nonWorkingDays( arguments.start, horizon );
		// ogni giorno il pezzo parte dove finisce l'ultima attività della persona
		var booked     = bookedMap( person.id, arguments.start, horizon, block.id );
		var days       = [];
		var date       = arguments.start;

		for ( var i = 1; i <= variables.HORIZON_DAYS && days.len() < pattern.len(); i++ ) {
			if ( dayCapacity( person, date, nonWorking, block.useSaturday, block.forceHolidays ) > 0 ) {
				var key = DateFormat( date, "yyyy-mm-dd" );
				days.append( { "day" = key, "hours" = pattern[ days.len() + 1 ], "start" = freeStart( person, booked[ key ] ?: [] ) } );
			}
			date = DateAdd( "d", 1, date );
		}

		if ( days.len() < pattern.len() ) {
			Throw( type = "apirone.planning.NoCapacity", message = "La persona non ha giorni lavorativi disponibili." );
		}

		transaction {
			getDao().updateBlock( block.id, targetUserId, block.useSaturday, block.forceHolidays, DateFormat( arguments.start, "yyyy-mm-dd" ) );
			getDao().replaceBlockDays( block.id, days );
		}
	}

	/**
	 * Nuova fine del blocco ( bordo destro ): il totale si ridistribuisce sui
	 * giorni lavorabili tra inizio e fine, in proporzione alla capacità.
	 */
	public void function resizeBlock( required Numeric blockId, required Date end ){
		var block  = loadBlock( arguments.blockId );
		var person = loadPerson( block.userId );
		var start  = ParseDateTime( block.days[ 1 ].day );
		var lastDay = DateCompare( arguments.end, start, "d" ) < 0 ? start : arguments.end;
		var total  = blockTotal( block );

		var nonWorking = getWorkCalendarService().nonWorkingDays( start, lastDay );
		var usable     = [];
		var date       = start;
		while ( DateCompare( date, lastDay, "d" ) <= 0 ) {
			var capacity = dayCapacity( person, date, nonWorking, block.useSaturday, block.forceHolidays );
			if ( capacity > 0 ) {
				usable.append( { "day" = DateFormat( date, "yyyy-mm-dd" ), "capacity" = capacity } );
			}
			date = DateAdd( "d", 1, date );
		}

		// nessun giorno lavorabile ( es. solo un sabato ): tutto sul primo giorno
		if ( !usable.len() ) {
			usable.append( { "day" = block.days[ 1 ].day, "capacity" = 1 } );
		}

		var totalCapacity = 0;
		for ( var item in usable ) {
			totalCapacity += item.capacity;
		}

		// mezze ore, il resto sull'ultimo giorno; il primo giorno mantiene la sua
		// ora di inizio, gli altri partono dove finisce l'ultima attività
		var booked   = bookedMap( person.id, start, lastDay, block.id );
		var days     = [];
		var assigned = 0;
		for ( var i = 1; i <= usable.len(); i++ ) {
			var dayHours = i < usable.len()
				? Round( total * usable[ i ].capacity / totalCapacity * 2 ) / 2
				: Round( ( total - assigned ) * 100 ) / 100;
			if ( dayHours > 0 ) {
				var dayStart = usable[ i ].day == block.days[ 1 ].day
					? block.days[ 1 ].start
					: freeStart( person, booked[ usable[ i ].day ] ?: [] );
				days.append( { "day" = usable[ i ].day, "hours" = dayHours, "start" = dayStart } );
				assigned += dayHours;
			}
		}

		getDao().replaceBlockDays( block.id, days );
	}

	/**
	 * Divide il blocco in due blocchi di pari durata, in ordine di tempo: il
	 * primo prende la metà arrotondata per eccesso alla mezz'ora ( 3h -> 1h30 +
	 * 1h30, 3h30 -> 2h + 1h30 ). Se il taglio cade dentro un giorno quel giorno
	 * si spezza: il secondo pezzo parte dove finisce il primo.
	 */
	public Numeric function splitBlock( required Numeric blockId ){
		var block = loadBlock( arguments.blockId );
		var total = blockTotal( block );

		if ( total < 1 ) {
			Throw( type = "apirone.planning.InvalidSplit", message = "Il blocco è troppo corto per essere diviso ( servono almeno 1 h )." );
		}

		var firstHours = Ceiling( total / 2 * 2 ) / 2;
		var first      = [];
		var second     = [];
		var assigned   = 0;

		for ( var day in block.days ) {
			var left = firstHours - assigned;

			if ( left <= 0 ) {
				second.append( day );
			} else if ( day.hours <= left ) {
				first.append( day );
				assigned += day.hours;
			} else {
				// il taglio cade in questo giorno
				first.append( { "day" = day.day, "hours" = left, "start" = day.start } );
				second.append( { "day" = day.day, "hours" = Round( ( day.hours - left ) * 100 ) / 100, "start" = day.start + Round( left * 60 ) } );
				assigned += left;
			}
		}

		transaction {
			var newId = getDao().insertBlock(
				quotationId   = block.quotationId,
				userId        = block.userId,
				workTypeId    = block.workTypeId,
				useSaturday   = block.useSaturday,
				forceHolidays = block.forceHolidays,
				startDay      = second[ 1 ].day,
				note          = block.note,
				extra         = block.extra
			);
			getDao().replaceBlockDays( block.id, first );
			getDao().replaceBlockDays( newId, second );
		}

		return newId;
	}

	public void function deleteBlock( required Numeric blockId ){
		getDao().deleteBlock( arguments.blockId );
	}

	/**
	 * Ore di un singolo giorno, forzate a mano ( anche oltre la capacità ).
	 * 0 toglie il giorno; un blocco senza giorni si elimina.
	 */
	public void function setDayHours( required Numeric blockId, required Date day, required Numeric hours ){
		var block = loadBlock( arguments.blockId );
		var key   = DateFormat( arguments.day, "yyyy-mm-dd" );
		var value = Min( Max( arguments.hours, 0 ), 24 );

		// il giorno mantiene la sua ora di inizio; un giorno nuovo parte dove
		// finisce l'ultima attività della persona
		var existing = block.days.filter( function( item ){ return item.day == key; } );
		var days     = block.days.filter( function( item ){ return item.day != key; } );
		if ( value > 0 ) {
			var start = existing.len() ? existing[ 1 ].start : -1;
			if ( start < 0 ) {
				var person = loadPerson( block.userId );
				var booked = bookedMap( person.id, arguments.day, arguments.day, block.id );
				start = freeStart( person, booked[ key ] ?: [] );
			}
			days.append( { "day" = key, "hours" = value, "start" = start } );
		}
		days.sort( function( a, b ){ return Compare( a.day, b.day ); } );

		if ( !days.len() ) {
			getDao().deleteBlock( block.id );
			return;
		}

		getDao().replaceBlockDays( block.id, days );
	}

	/**
	 * Usa i sabati / forza domeniche e festivi: il totale si ridistribuisce
	 * dalla data di inizio sulla capacità libera.
	 */
	public void function setBlockFlags( required Numeric blockId, required Boolean useSaturday, required Boolean forceHolidays ){
		var block  = loadBlock( arguments.blockId );
		var person = loadPerson( block.userId );
		var days   = distribute(
			person,
			ParseDateTime( block.startDay ),
			blockTotal( block ),
			arguments.useSaturday,
			arguments.forceHolidays,
			block.id,
			// se il blocco parte ancora dal giorno scelto ne mantiene l'ora di inizio
			block.startDay == block.days[ 1 ].day ? block.days[ 1 ].start : -1
		);

		transaction {
			getDao().updateBlock( block.id, block.userId, arguments.useSaturday, arguments.forceHolidays, block.startDay );
			getDao().replaceBlockDays( block.id, days );
		}
	}

	/**
	 * Ora di inizio ( start ) o di fine ( end ) del blocco, "HH:MM" a passi di
	 * 30 minuti. La durata resta la stessa: con l'inizio le ore si ridistribuiscono
	 * da lì ( la fine si adegua ); con la fine l'inizio si sposta della stessa
	 * differenza.
	 */
	public void function setBlockTimes( required Numeric blockId, String start = "", String end = "" ){
		var block  = loadBlock( arguments.blockId );
		var person = loadPerson( block.userId );
		var first  = block.days[ 1 ];
		var last   = block.days[ block.days.len() ];
		var begin  = 0;

		if ( Len( arguments.start ) ) {
			begin = parseTime( arguments.start );
		} else if ( Len( arguments.end ) ) {
			var oldEnd = last.start + Round( last.hours * 60 );
			begin = first.start + ( parseTime( arguments.end ) - oldEnd );
		} else {
			return;
		}

		begin = Min( Max( begin, 0 ), 23 * 60 + 30 );

		var days = distribute(
			person,
			ParseDateTime( first.day ),
			blockTotal( block ),
			block.useSaturday,
			block.forceHolidays,
			block.id,
			begin
		);

		getDao().replaceBlockDays( block.id, days );
	}

	/**
	 * Ore extra: oltre la stima del progetto ( costo in più ), non la consumano.
	 */
	public void function setBlockExtra( required Numeric blockId, required Boolean extra ){
		loadBlock( arguments.blockId );
		getDao().updateBlockExtra( arguments.blockId, arguments.extra );
	}

	/**
	 * Nota del blocco ( descrizione facoltativa, es. per le attività "Altro" ).
	 */
	public void function setBlockNote( required Numeric blockId, required String note ){
		loadBlock( arguments.blockId );
		getDao().updateBlockNote( arguments.blockId, Left( arguments.note, 1000 ) );
	}

	/*
		private methods
	*/

	private Struct function loadPerson( required String userId ){
		var record = getDao().readPerson( arguments.userId );
		if ( !record.recordCount ) {
			Throw( type = "apirone.planning.PersonNotFound", message = "Persona non trovata." );
		}

		var hours = [];
		for ( var column in variables.HOURS_COLUMNS ) {
			hours.append( Val( record[ column ][ 1 ] ) );
		}

		return {
			"id"         = record.user_id[ 1 ],
			"workTypeId" = record.work_type_id[ 1 ] ?: "",
			"hours"      = hours,
			"dayStart"   = Val( record.day_start_minutes[ 1 ] )
		};
	}

	private Struct function loadBlock( required Numeric blockId ){
		var records = getDao().readBlock( arguments.blockId );
		if ( !records.recordCount ) {
			Throw( type = "apirone.planning.BlockNotFound", message = "Blocco non trovato: forse è stato eliminato, ricarica la pagina." );
		}

		var block = {
			"id"            = records.block_id[ 1 ],
			"quotationId"   = records.quotation_id[ 1 ],
			"userId"        = records.user_id[ 1 ],
			"workTypeId"    = records.work_type_id[ 1 ],
			"useSaturday"   = records.use_saturday[ 1 ] ? true : false,
			"forceHolidays" = records.force_holidays[ 1 ] ? true : false,
			"note"          = records.note[ 1 ] ?: "",
			"extra"         = records.extra[ 1 ] ? true : false,
			"days"          = []
		};

		for ( var row in records ) {
			if ( IsDate( row.day ?: "" ) ) {
				block.days.append( { "day" = DateFormat( row.day, "yyyy-mm-dd" ), "hours" = Val( row.hours ), "start" = Val( row.start_minutes ) } );
			}
		}

		if ( !block.days.len() ) {
			Throw( type = "apirone.planning.BlockNotFound", message = "Il blocco non ha giorni pianificati." );
		}

		// giorno di inizio scelto ( anche non lavorativo ); se manca, o è dopo il
		// primo giorno pianificato ( ore spostate a mano ), il primo giorno
		var startDay = IsDate( records.start_day[ 1 ] ?: "" ) ? DateFormat( records.start_day[ 1 ], "yyyy-mm-dd" ) : "";
		block[ "startDay" ] = Len( startDay ) && startDay <= block.days[ 1 ].day ? startDay : block.days[ 1 ].day;

		return block;
	}

	/**
	 * Le attività si assegnano alle persone del tipo corrispondente; "Altro" ( ALT )
	 * a chiunque.
	 */
	private void function checkWorkType( required Struct person, required String workTypeId ){
		if ( arguments.workTypeId != "ALT" && arguments.person.workTypeId != arguments.workTypeId ) {
			var wanted  = arguments.workTypeId;
			var matches = workTypes().filter( function( item ){ return item.id == wanted; } );
			Throw(
				type    = "apirone.planning.WrongWorkType",
				message = "Questa attività si assegna solo a persone di tipo " & ( matches.len() ? matches[ 1 ].name : wanted ) & "."
			);
		}
	}

	private Numeric function blockTotal( required Struct block ){
		var total = 0;
		for ( var day in arguments.block.days ) {
			total += day.hours;
		}
		return total;
	}

	/**
	 * Attività già pianificate per giorno ( escluso un blocco ): "yyyy-mm-dd" ->
	 * [ { start, end } ] in minuti, ordinate per inizio.
	 */
	private Struct function bookedMap( required String userId, required Date fromDate, required Date toDate, required Numeric excludeBlockId ){
		var result = {};
		for ( var row in getDao().findBookedSegments( arguments.userId, arguments.fromDate, arguments.toDate, arguments.excludeBlockId ) ) {
			var key   = DateFormat( row.day, "yyyy-mm-dd" );
			var start = Val( row.start_minutes );
			if ( !result.keyExists( key ) ) result[ key ] = [];
			result[ key ].append( { "start" = start, "end" = start + Round( Val( row.hours ) * 60 ) } );
		}
		for ( var key in result ) {
			result[ key ].sort( function( a, b ){ return a.start - b.start; } );
		}
		return result;
	}

	/**
	 * Primo spazio libero della giornata ( da inizio giornata a windowEnd ) tra
	 * le attività già pianificate: { start, minutes }; minutes 0 se è piena.
	 */
	private Struct function freeSlot( required Struct person, required Array intervals, required Numeric windowEnd ){
		var cursor = arguments.person.dayStart;

		for ( var interval in arguments.intervals ) {
			if ( interval.start > cursor ) {
				var gap = Min( interval.start, arguments.windowEnd ) - cursor;
				if ( gap > 0 ) {
					return { "start" = cursor, "minutes" = gap };
				}
			}
			cursor = Max( cursor, interval.end );
		}

		return { "start" = cursor, "minutes" = Max( arguments.windowEnd - cursor, 0 ) };
	}

	/**
	 * Ora di inizio di un pezzo aggiunto in un giorno: il primo spazio libero, o
	 * la fine dell'ultima attività se la giornata è piena.
	 */
	private Numeric function freeStart( required Struct person, required Array intervals ){
		var slot = freeSlot( arguments.person, arguments.intervals, 24 * 60 );
		return slot.start;
	}

	/**
	 * Minuti dalla mezzanotte -> "HH:MM".
	 */
	private String function formatTime( required Numeric minutes ){
		return NumberFormat( Int( arguments.minutes / 60 ), "00" ) & ":" & NumberFormat( arguments.minutes mod 60, "00" );
	}

	/**
	 * "HH:MM" a passi di 30 minuti -> minuti dalla mezzanotte.
	 */
	private Numeric function parseTime( required String time ){
		if ( !REFind( "^([01][0-9]|2[0-3]):(00|30)$", arguments.time ) ) {
			Throw( type = "apirone.planning.InvalidTime", message = "Orario non valido: usa ore intere o mezze ore ( es. 07:00, 07:30 )." );
		}
		return Val( ListFirst( arguments.time, ":" ) ) * 60 + Val( ListLast( arguments.time, ":" ) );
	}

	/**
	 * Ore lavorabili da una persona in un giorno ( vedi le regole sopra ).
	 */
	private Numeric function dayCapacity(
		required Struct person,
		required Date date,
		required Struct nonWorking,
		required Boolean useSaturday,
		required Boolean forceHolidays
	){
		var key   = DateFormat( arguments.date, "yyyy-mm-dd" );
		// DayOfWeek: 1 = domenica; hours: 1 = lunedì .. 7 = domenica
		var index = ( ( DayOfWeek( arguments.date ) + 5 ) mod 7 ) + 1;
		var base  = arguments.person.hours[ index ];

		if ( !arguments.nonWorking.keyExists( key ) ) {
			return base;
		}

		var type    = arguments.nonWorking[ key ].type;
		var allowed = arguments.forceHolidays || ( type == "SAT" && arguments.useSaturday );
		if ( !allowed ) {
			return 0;
		}

		if ( base > 0 ) {
			return base;
		}

		var weekdayMax = 0;
		for ( var i = 1; i <= 5; i++ ) {
			weekdayMax = Max( weekdayMax, arguments.person.hours[ i ] );
		}
		return weekdayMax;
	}

	/**
	 * Distribuisce le ore dalla data di inizio sulla capacità libera della
	 * persona ( capacità meno le ore degli altri blocchi ).
	 */
	private Array function distribute(
		required Struct person,
		required Date start,
		required Numeric hours,
		required Boolean useSaturday,
		required Boolean forceHolidays,
		required Numeric excludeBlockId,
		Numeric firstStart = -1
	){
		var to         = DateAdd( "d", variables.HORIZON_DAYS, arguments.start );
		var nonWorking = getWorkCalendarService().nonWorkingDays( arguments.start, to );
		var booked     = bookedMap( arguments.person.id, arguments.start, to, arguments.excludeBlockId );

		var days      = [];
		var remaining = arguments.hours;
		var date      = arguments.start;

		for ( var i = 1; i <= variables.HORIZON_DAYS && remaining > 0.001; i++ ) {
			var key      = DateFormat( date, "yyyy-mm-dd" );
			var capacity = dayCapacity( arguments.person, date, nonWorking, arguments.useSaturday, arguments.forceHolidays );

			if ( capacity > 0 ) {
				// la giornata va da inizio giornata per le ore disponibili; il pezzo
				// occupa il primo spazio libero ( o parte dall'ora scelta, il primo giorno,
				// fino a fine giornata )
				var windowEnd = arguments.person.dayStart + capacity * 60;
				var slot      = i == 1 && arguments.firstStart >= 0
					? { "start" = arguments.firstStart, "minutes" = windowEnd - arguments.firstStart }
					: freeSlot( arguments.person, booked[ key ] ?: [], windowEnd );
				var free = slot.minutes / 60;

				if ( free > 0 ) {
					var dayHours = Round( Min( free, remaining ) * 100 ) / 100;
					days.append( { "day" = key, "hours" = dayHours, "start" = slot.start } );
					remaining -= dayHours;
				}
			}

			date = DateAdd( "d", 1, date );
		}

		if ( remaining > 0.001 ) {
			Throw( type = "apirone.planning.NoCapacity", message = "La persona non ha abbastanza ore disponibili nei prossimi 12 mesi." );
		}

		return days;
	}

	/**
	 * Revisione / duplica: le ore stimate passano al nuovo preventivo ( la
	 * pianificazione nel Gantt no ).
	 */
	public void function copyQuotationWorkHours( required String fromQuotationId, required String toQuotationId ){
		getDao().copyQuotationWorkHours( arguments.fromQuotationId, arguments.toQuotationId );
	}

}
