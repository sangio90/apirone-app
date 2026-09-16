component extends="coldbox.system.web.tasks.ColdBoxScheduler" {

    /*
        Sincronizzazione automatica da Verticale: lun-ven, alle ore pari 8-16 (ora italiana).
        Il lock atomico in VerticaleSyncService/DAO rende sicura una sovrapposizione
        con un lancio manuale dal bottone in topbar (uno dei due riceve semplicemente
        alreadyRunning=true e non fa nulla).

        Nota: il timezone va impostato sul singolo task con task.setTimezone(), PRIMA di
        onWeekdays()/everyDayAt() - impostarlo con lo Scheduler.setTimezone() a livello di
        configure() non si propaga (this.getTimezone() nella classe base dello scheduler
        legge un'istanza diversa da quella mutata qui, per come WireBox implementa la
        virtual inheritance su questo CFC) e i task restano schedulati in UTC.
    */
    function configure(){

        var verticaleSyncService = getInstance( "VerticaleSyncService" );
        var runTimes = [ "08:00", "10:00", "12:00", "14:00", "16:00" ];

        for ( var runTime in runTimes ) {
            task( "verticaleSync-#runTime#" )
                .call( function(){ verticaleSyncService.run(); } )
                .setTimezone( "Europe/Rome" )
                .onWeekdays( runTime );
        }

        // Sincronizzazione CRM: una volta al giorno di notte (tutti i giorni, non solo
        // lun-ven). Volume molto più grande di Verticale (~127mila record tra account e
        // lead, paginati via HTTP): qualche minuto, non ha senso farla girare ogni 2 ore.
        var crmSyncService = getInstance( "CrmSyncService" );

        task( "crmSync-03:00" )
            .call( function(){ crmSyncService.run(); } )
            .setTimezone( "Europe/Rome" )
            .everyDayAt( "03:00" );

    }

}
