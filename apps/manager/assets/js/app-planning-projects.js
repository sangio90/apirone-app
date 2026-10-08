AP.namespace( "planningProjects" );

/**
 * Ore progetti per la pianificazione ( Gantt ): per ogni preventivo
 * "Confermato da cliente" / "Convertito in ordine" le ore stimate per tipo di
 * attività e lo stato del progetto. Ogni modifica di una riga si salva subito;
 * un progetto concluso esce dall'elenco ( salvo "Mostra i progetti conclusi" )
 * e dal Gantt.
 */
AP.planningProjects = ( function() {

    const BASE = "/manager/ajax/planning";

    const pub = {};

    pub.init = function() {
        pub.vm = new Vue( {
            el: "#planning-projects-app",

            data: {
                workTypes: AP.page.workTypes || [],
                projects: [],
                loading: false,
                filters: { str: "", showCompleted: false },
            },

            computed: {
                filteredProjects: function() {
                    const str = this.filters.str.trim().toLowerCase();
                    const showCompleted = this.filters.showCompleted;

                    return this.projects.filter( function( project ) {
                        if ( project.completed && !showCompleted ) return false;
                        if ( !str ) return true;
                        const text = [ project.number, project.name, project.customer ].join( " " ).toLowerCase();
                        return text.indexOf( str ) !== -1;
                    } );
                },
            },

            mounted: function() {
                this.load();
            },

            methods: {
                load: function() {
                    this.loading = true;
                    NM.util.ajax( {
                        method: "GET",
                        url: BASE + "/projects",
                        callback: {
                            done: ( xhr ) => {
                                this.loading = false;
                                // numero decrescente ( i più recenti in alto ), poi versione decrescente
                                const projects = ( xhr.data || [] ).slice().sort( function( a, b ) {
                                    return ( Number( b.number ) - Number( a.number ) ) || ( Number( b.version ) - Number( a.version ) );
                                } );
                                this.projects = projects.map( ( project ) => {
                                    // form: ore stimate modificabili, una per tipo; budgets: euro, vuoto = nessun budget
                                    const form = {};
                                    const budgets = {};
                                    this.workTypes.forEach( function( type ) {
                                        const hours = project.hours[ type.id ];
                                        form[ type.id ] = hours ? hours.estimated : 0;
                                        budgets[ type.id ] = hours && hours.budget !== "" ? hours.budget : "";
                                    } );
                                    return Object.assign( project, { form: form, budgets: budgets, saving: false, saved: false } );
                                } );
                            },
                        },
                    } ).always( () => { this.loading = false; } );
                },

                save: function( project ) {
                    const hours = {};
                    const budgets = {};
                    this.workTypes.forEach( function( type ) {
                        hours[ type.id ] = Math.max( Number( project.form[ type.id ] ) || 0, 0 );
                        const budget = String( project.budgets[ type.id ] ).trim();
                        budgets[ type.id ] = budget === "" || isNaN( Number( budget ) ) ? "" : Math.max( Number( budget ), 0 );
                    } );

                    project.saving = true;
                    project.saved = false;

                    return new Promise( ( resolve ) => {
                        NM.util.ajax( {
                            method: "POST",
                            url: BASE + "/projects/" + project.id,
                            loading: false, // salvataggio di una riga: niente spinner a tutta pagina
                            data: JSON.stringify( { hours: hours, budgets: budgets, completed: project.completed } ),
                            callback: {
                                done: function( xhr ) {
                                    project.saving = false;
                                    if ( xhr.status === "ERROR" ) {
                                        AP.widget.notify( "error", ( xhr.data && xhr.data.message ) || "Salvataggio non riuscito." );
                                        resolve( false );
                                        return;
                                    }
                                    project.saved = true;
                                    setTimeout( function() { project.saved = false; }, 1500 );
                                    resolve( true );
                                },
                            },
                        } ).always( function() { project.saving = false; } );
                    } );
                },

                toggleCompleted: async function( project ) {
                    const saved = await this.save( project );
                    if ( !saved ) {
                        project.completed = !project.completed;
                        return;
                    }
                    if ( project.completed ) {
                        AP.widget.notify( "success", "Progetto n. " + project.number + " concluso: non compare più nel Gantt." );
                    }
                },

                planned: function( project, typeId ) {
                    return project.hours[ typeId ] ? project.hours[ typeId ].planned : 0;
                },

                // ore extra: pianificate oltre la stima, non la consumano
                extra: function( project, typeId ) {
                    return project.hours[ typeId ] ? ( project.hours[ typeId ].extra || 0 ) : 0;
                },

                // pianificate oltre la stima: in rosso; pari alla stima: in verde
                plannedClass: function( project, typeId ) {
                    const planned = this.planned( project, typeId );
                    const estimated = Number( project.form[ typeId ] ) || 0;
                    return { over: planned > estimated, done: planned > 0 && planned === estimated };
                },

                total: function( project ) {
                    return this.workTypes.reduce( function( sum, type ) { return sum + ( Number( project.form[ type.id ] ) || 0 ); }, 0 );
                },

                // somma dei budget inseriti ( null se nessuna attività ha un budget )
                totalBudget: function( project ) {
                    let total = null;
                    this.workTypes.forEach( function( type ) {
                        const budget = String( project.budgets[ type.id ] ).trim();
                        if ( budget !== "" && !isNaN( Number( budget ) ) ) total = ( total || 0 ) + Number( budget );
                    } );
                    return total;
                },

                formatMoney: function( value ) {
                    return ( Number( value ) || 0 ).toLocaleString( "it-IT", { style: "currency", currency: "EUR" } );
                },

                totalPlanned: function( project ) {
                    return this.workTypes.reduce( ( sum, type ) => sum + this.planned( project, type.id ), 0 );
                },

                format: function( value ) {
                    return ( Math.round( ( Number( value ) || 0 ) * 100 ) / 100 ).toLocaleString( "it-IT" );
                },
            },
        } );
    };

    return pub;
}() );

$( document ).ready( function() {
    if ( document.getElementById( "planning-projects-app" ) ) {
        AP.planningProjects.init();
    }
} );
