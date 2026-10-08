/**
 * Calendario lavorativo della pianificazione: sabati, domeniche, festivi di
 * San Marino ( fissi e mobili, calcolati ) e chiusure aziendali
 * ( planning_closures ). Di default nessuno di questi giorni si lavora; un
 * blocco può usare i sabati o forzare domeniche e festivi ( PlanningService ).
 */
component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="PlanningDAO";

	/**
	 * Festivi fissi di San Marino ( mm-dd ).
	 */
	variables.FIXED_HOLIDAYS = {
		"01-01" = "Capodanno",
		"01-06" = "Epifania",
		"02-05" = "Sant'Agata",
		"03-25" = "Anniversario dell'Arengo",
		"04-01" = "Insediamento Capitani Reggenti",
		"05-01" = "Festa dei Lavoratori",
		"07-28" = "Caduta del Fascismo",
		"08-15" = "Assunzione",
		"09-03" = "San Marino",
		"10-01" = "Insediamento Capitani Reggenti",
		"11-01" = "Ognissanti",
		"11-02" = "Commemorazione dei Defunti",
		"12-08" = "Immacolata Concezione",
		"12-25" = "Natale",
		"12-26" = "Santo Stefano"
	};

	/**
	 * Festivi di un anno, compresi Pasqua, Lunedì dell'Angelo e Corpus Domini:
	 * struct "yyyy-mm-dd" -> nome.
	 */
	public Struct function holidays( required Numeric year ){
		var result = {};

		for ( var monthDay in variables.FIXED_HOLIDAYS ) {
			result[ arguments.year & "-" & monthDay ] = variables.FIXED_HOLIDAYS[ monthDay ];
		}

		var easterDay = easter( arguments.year );
		result[ DateFormat( easterDay, "yyyy-mm-dd" ) ]                  = "Pasqua";
		result[ DateFormat( DateAdd( "d", 1, easterDay ), "yyyy-mm-dd" ) ]  = "Lunedì dell'Angelo";
		result[ DateFormat( DateAdd( "d", 60, easterDay ), "yyyy-mm-dd" ) ] = "Corpus Domini";

		return result;
	}

	/**
	 * Giorni non lavorativi tra due date ( incluse ): struct "yyyy-mm-dd" ->
	 * { type, name }, type: SAT ( sabato ), SUN ( domenica ), HOL ( festivo ),
	 * CLO ( chiusura aziendale ). Festivi e chiusure prevalgono sul giorno della
	 * settimana.
	 */
	public Struct function nonWorkingDays( required Date fromDate, required Date toDate ){
		var result     = {};
		var holidayMap = {};

		for ( var year = Year( arguments.fromDate ); year <= Year( arguments.toDate ); year++ ) {
			StructAppend( holidayMap, this.holidays( year ) );
		}

		var closures = {};
		for ( var row in getDao().findClosures( arguments.fromDate, arguments.toDate ) ) {
			closures[ DateFormat( row.day, "yyyy-mm-dd" ) ] = row.description ?: "Chiusura aziendale";
		}

		var day = arguments.fromDate;
		while ( DateCompare( day, arguments.toDate, "d" ) <= 0 ) {
			var key = DateFormat( day, "yyyy-mm-dd" );

			if ( closures.keyExists( key ) ) {
				result[ key ] = { "type" = "CLO", "name" = closures[ key ] };
			} else if ( holidayMap.keyExists( key ) ) {
				result[ key ] = { "type" = "HOL", "name" = holidayMap[ key ] };
			} else if ( DayOfWeek( day ) == 7 ) {
				result[ key ] = { "type" = "SAT", "name" = "Sabato" };
			} else if ( DayOfWeek( day ) == 1 ) {
				result[ key ] = { "type" = "SUN", "name" = "Domenica" };
			}

			day = DateAdd( "d", 1, day );
		}

		return result;
	}

	public Array function listClosures( required Date fromDate, required Date toDate ){
		var result = [];
		for ( var row in getDao().findClosures( arguments.fromDate, arguments.toDate ) ) {
			result.append( {
				"id"          = row.closure_id,
				"day"         = DateFormat( row.day, "yyyy-mm-dd" ),
				"description" = row.description ?: ""
			} );
		}
		return result;
	}

	public void function saveClosure( required Date day, String description = "" ){
		getDao().saveClosure( arguments.day, arguments.description );
	}

	public void function deleteClosure( required Numeric closureId ){
		getDao().deleteClosure( arguments.closureId );
	}

	/**
	 * Domenica di Pasqua ( algoritmo gregoriano anonimo, Meeus/Jones/Butcher ).
	 */
	private Date function easter( required Numeric year ){
		var a = arguments.year mod 19;
		var b = Int( arguments.year / 100 );
		var c = arguments.year mod 100;
		var d = Int( b / 4 );
		var e = b mod 4;
		var f = Int( ( b + 8 ) / 25 );
		var g = Int( ( b - f + 1 ) / 3 );
		var h = ( 19 * a + b - d - g + 15 ) mod 30;
		var i = Int( c / 4 );
		var k = c mod 4;
		var l = ( 32 + 2 * e + 2 * i - h - k ) mod 7;
		var m = Int( ( a + 11 * h + 22 * l ) / 451 );
		var month = Int( ( h + l - 7 * m + 114 ) / 31 );
		var day   = ( ( h + l - 7 * m + 114 ) mod 31 ) + 1;

		return CreateDate( arguments.year, month, day );
	}

}
