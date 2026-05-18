AP.namespace( "plate" );

Object.assign( AP.plate.fields, {
    modalRoot: $( "#plate-modal-root" ),
} );

AP.plate.modal = ( function() {
    /**
     * Riferimento globale all'istanza Vue della placca.
     * @type {Vue|null}
     */
    window.vm = null;

    /** Oggetto pubblico esportato dal modulo. */
    const pub = {};

    /** Risposta del server restituita dal caricamento della placca in modifica. */
    let plateResponse = null;

    /**
     * Restituisce il modulo griglia per la gestione delle celle della placca.
     * @returns {Object|null} Il modulo AP.plate.grid o null se non definito.
     */
    function getGridModule() {
        return AP.plate.grid;
    }

    /**
     * Restituisce l'app modale per la gestione dei file allegati.
     * @returns {Object} Il modulo AP.file.modal.
     */
    function fileApp() {
        return AP.file.modal;
    }

    /**
     * Crea e restituisce la struttura dati predefinita per il form di dettaglio della placca.
     * Contiene dati iniziali vuoti, elenchi di stato, titolo e configurazioni di prezzo.
     * @returns {Object} Oggetto form con proprietà data, statuses, itemStatuses, title, canSave, isClone, priceTypes.
     */
    function createDefaultDetailForm() {
        return {
            data: {
                id: "",
                quantity: 1,
                special: false,
                customImage: false,
                note: "",
                status: { id: "ACT" },
                position: { id: "", code: "" },
                quotationZone: { id: "", name: "" },
                quotationZoneId: "",
                quotationSubzone: null,
                quotationSubzoneId: "",
                product: {
                    id: "",
                    orientation: { id: "" },
                    frame: { id: "" },
                    finish: { id: "" },
                    line: { id: "" },
                    model: { id: "", code: "" },
                    image: { id: "", uri: "" },
                    items: [],
                },
                plateQuotationItemProductItems: [],
                fruits: [],
                fruitQuotationItemProductItems: [],
                productItemsImages: [],
            },
            statuses: AP.page.statuses || [],
            itemStatuses: AP.page.itemStatuses || [],
            title: "Carica placca",
            canSave: false,
            isClone: false,
            priceTypes: [
                { id: "C", name: "Calcolato" },
                { id: "F", name: "Fisso" },
            ],
        };
    }

    /** Valori predefiniti per una nuova placca: dimensioni, orientamento e griglia di base. */
    const defaultPlate = {
        id: "100",
        code: "508",
        image: { uri: "" },
        width: 1200,
        height: 500,
        orientation: { id: "" },
        cellOrientation: { id: "" },
        grid: [
            [
                { type: "_", id: "default-cell-1" },
                { type: "_", id: "default-cell-2" },
            ],
        ],
    };

    /**
     * Mappa i dati di un frutto nel formato richiesto dal FruitsController della griglia.
     * Calcola larghezza e altezza in base alle dimensioni delle celle libere e al positionCount.
     * @param {Object} data - Dati del frutto da mappare.
     * @param {string} data.id - Identificativo del frutto.
     * @param {string} data.fruitId - Identificativo del prodotto frutto.
     * @param {Object} data.fruit - Oggetto frutto con proprietà code, name, horizontalImage.
     * @param {number} [data.fruit.positionCount] - Numero di posizioni occupate dal frutto sulla griglia.
     * @returns {Object|null} Oggetto frutto formattato per la griglia, o null se il modulo griglia non è disponibile.
     */
    function mapFruitForPlate( data ) {
        const gm = getGridModule();
        if ( !gm ) {
            return null;
        }
        const fruitWidth = gm.constants.GRID_CELL_DIMENSIONS[gm.CELL_TYPE.FREE].width * ( data.fruit.positionCount || 1 );
        const fruitHeight = gm.constants.GRID_CELL_DIMENSIONS[gm.CELL_TYPE.FREE].height;
        return {
            id: data.id,
            fruitId: data.fruitId,
            width: fruitWidth,
            height: fruitHeight,
            columnSpan: data.fruit.positionCount || 1,
            rowSpan: 1,
            code: data.fruit.code,
            name: data.fruit.name,
            image: data.fruit?.horizontalImage?.uri || "/assets/main/img/fruit-generic.png",
        };
    }

    /**
     * Crea un nuovo oggetto frutto arricchito con dati aggiuntivi.
     * Aggiunge fruitId, genera un UUID se mancante e inizializza posizioni e items.
     * @param {Object} data - Dati base del frutto.
     * @param {Object} data.fruit - Oggetto frutto con proprietà id.
     * @param {string} [data.id] - Identificativo opzionale del frutto.
     * @param {Array} [data.positionIds] - Elenco opzionale degli ID posizione.
     * @returns {Object} Nuovo oggetto frutto con proprietà id, fruitId, positionIds, items, expanded.
     */
    function createFruit( data ) {
        const fruit = { ...data };
        fruit.fruitId = data.fruit.id;
        fruit.id = data.id || NM.util.uuid();
        fruit._key = NM.util.uuid();
        fruit.positionIds = data.positionIds || [];
        fruit.items = [];
        fruit.expanded = true;
        return fruit;
    }

    /**
     * Configura la placca all'interno del modulo griglia.
     * Imposta le dimensioni delle celle, costruisce la griglia a partire dai dati della placca,
     * crea il Plate e il FruitsController, disegna la placca nel DOM e aggiunge i frutti esistenti.
     * Aggiorna il flag isPlateDefined al termine.
     */
    function configPlate() {
        const gm = getGridModule();
        if ( !gm ) {
            return;
        }

        const plate = window.vm.plate;

        let freeCellWidth = gm.constants.GRID_CELL_DIMENSIONS[gm.CELL_TYPE.FREE].width;
        let freeCellHeight = gm.constants.GRID_CELL_DIMENSIONS[gm.CELL_TYPE.FREE].height;

        if ( plate.cellOrientation.id == gm.orientation.VERTICAL ) {
            const tmp = freeCellWidth;
            freeCellWidth = freeCellHeight;
            freeCellHeight = tmp;
        }

        gm.setCellDimensions( freeCellWidth, freeCellHeight );

        const grid = [];
        for ( const columns of plate.grid ) {
            const row = [];
            for ( const cellData of columns ) {
                const cellType = cellData.type;
                const cell = new gm.Cell(
                    gm.constants.GRID_CELL_DIMENSIONS[cellType].width,
                    gm.constants.GRID_CELL_DIMENSIONS[cellType].height,
                    plate.cellOrientation.id,
                    cellType,
                    cellData.id,
                    cellData.order
                );
                row.push( cell );
            }
            grid.push( row );
        }

        const plateObj = new gm.Plate( {
            width: plate.width,
            height: plate.height,
            orientation: plate.orientation.id,
            cellOrientation: plate.cellOrientation.id,
            id: plate.id,
            code: plate.code,
            image: plate.image.uri,
            grid: grid,
            isSpecial: false,
        } );

        pub.fruitsController = new gm.FruitsController( {
            plate: plateObj,
            fruits: [],
        } );

        pub.fruitsController.plate.drawGridWithin( $( ".plate-designer" ) );

        window.vm.isPlateDefined = true;
    }

    /**
     * Wrapper per le chiamate AJAX tramite NM.util.ajax.
     * @param {Object} opts - Opzioni della richiesta AJAX.
     * @returns {Object} Promise restituita da NM.util.ajax.
     */
    const ajax = function( opts ) {
        return NM.util.ajax( opts );
    };

    /** URL base per le richieste AJAX del manager. */
    const BASE = "/manager/ajax";

    /**
     * Recupera i dati completi di una placca.
     * @param {string} id - Identificativo della placca.
     * @returns {Object} Promise della richiesta AJAX.
     */
    function getPlate( id ) {
        return ajax( { method: "GET", url: BASE + "/quotation-items/plate/" + id } );
    }

    /**
     * Template originale dell'element #plate-vue-app, cacheato al primo montaggio
     * per poter ripristinare le direttive Vue prima di un re-mount.
     */
    let plateVueTemplate = "";

    /**
     * Monta l'applicazione Vue per il modale della placca.
     * Crea una nuova istanza Vue direttamente, senza attendere eventi Bootstrap.
     * Se un'istanza esiste già (da un'apertura precedente), la distrugge
     * e ripristina il template originale prima di crearne una nuova.
     */
    function mountVue() {
        if ( window.vm ) {
            window.vm.$destroy();
            window.vm = null;
        }

        // Cache del template originale al primo montaggio e ripristino prima del re-mount
        if ( plateVueTemplate ) {
            $( "#plate-vue-app" ).html( plateVueTemplate );
        } else {
            plateVueTemplate = $( "#plate-vue-app" ).html() || "";
        }

        // Lega la pulizia alla chiusura del modal (un solo handler attivo per volta)
        $( "#plate-modal-root" ).off( "hidden.bs.modal" ).on( "hidden.bs.modal", function() {
            if ( window.vm ) {
                window.vm.$destroy();
                window.vm = null;
            }
        } );

        window.vm = new Vue( {
            data: {
                backgroundCustomImage: { id: "", url: "" }, /** Immagine personalizzata di sfondo per la placca. */
                detailForm: createDefaultDetailForm(), /** Dati del form di dettaglio: item, prodotto, frutti, zone e stato. */
                lines: [], /** Elenco delle linee prodotto disponibili. */
                models: [], /** Elenco dei modelli disponibili per la linea selezionata. */
                finishes: [], /** Elenco delle finiture disponibili per il modello selezionato. */
                plate: { ...defaultPlate }, /** Dati della placca corrente: dimensioni, orientamento, griglia e immagine. */
                availableOrientations: [], /** Orientamenti disponibili per il telaio selezionato. */
                currentFruit: {}, /** Frutto correntemente selezionato o in interazione. */
                toggleFruitsLabel: "Comprimi tutti", /** Etichetta del pulsante comprimi/espandi tutti i frutti. */
                zones: [], /** Zone di quotazione principali (senza origine). */
                subzones: [], /** Sottozone di quotazione (con origine). */
                allZones: [], /** Elenco completo di tutte le zone, incluse le sottozone. */
                isEditMode: false, /** Flag che indica se la modalità corrente è di modifica. */
                isPlateDefined: false, /** Flag che indica se la placca è stata disegnata nella griglia. */
                fruitSearchTerm: "", /** Termine di ricerca per il suggeritore frutti. */
                fruitSuggestions: [], /** Suggerimenti frutti corrispondenti alla ricerca. */
                positionSearchTerm: "", /** Termine di ricerca per il suggeritore posizioni. */
                positionSuggestions: [], /** Suggerimenti posizioni corrispondenti alla ricerca. */
                fruitSuggestLoading: false, /** Flag di caricamento per la ricerca frutti. */
                positionSuggestLoading: false, /** Flag di caricamento per la ricerca posizioni. */
                productItemsImages: {}, /** Mappa degli URI delle immagini dei product items, indicizzata per ID. */
                activeTab: "plate", /** Tab attivo nel pannello degli attributi (plate | fruits). */
                saving: false, /** Flag di caricamento durante il salvataggio. */

                /** Dati di prezzatura: sconti, metodo di calcolo, righe e totale. */
                pricing: {
                    data: {
                        id: "",
                        quantity: 1,
                        discount1: "",
                        discount2: "",
                        method: { id: "C", name: "Calcolato" },
                        lines: [],
                        total: 0,
                    },
                    priceTypes: [
                        { id: "C", name: "Calcolato" },
                        { id: "F", name: "Fisso" },
                    ],
                    isTotalEnabled: false,
                },
            },

            computed: {
                /**
                 * Restituisce il numero totale di frutti presenti nel form.
                 * @returns {number} Conteggio dei frutti.
                 */
                getFruitCount: function() {
                    return this.detailForm.data.fruits.length;
                },

                /**
                 * Indica se il pulsante di cancellazione superiore deve essere visibile.
                 * È visibile solo in modalità nuovo inserimento (ID assente).
                 * @returns {boolean} True se il form è in modalità nuovo inserimento.
                 */
                visibleUpperClearButton: function() {
                    return this.detailForm.data.id === "";
                },

                /**
                 * Indica se il pulsante di cancellazione inferiore deve essere visibile.
                 * È visibile solo in modalità nuovo inserimento (ID assente).
                 * @returns {boolean} True se il form è in modalità nuovo inserimento.
                 */
                visibleLowerClearButton: function() {
                    return this.detailForm.data.id === "";
                },
            },

            watch: {
                /**
                 * Osserva il cambiamento della zona di quotazione selezionata.
                 * Alla selezione di una nuova zona, carica le relative sottozone.
                 * @param {string} newZoneId - Identificativo della nuova zona selezionata.
                 */
                "detailForm.data.quotationZoneId": function( newZoneId ) {
                    this.loadSubZones( newZoneId );
                },

                /**
                 * Osserva in profondità l'array dei frutti per rilevare cambiamenti
                 * nelle selezioni degli attributi (sia manuali che automatici).
                 * Quando una value diventa selected=true, carica i figli tramite
                 * processFruitCascade e aggiorna gli overlay delle immagini.
                 * L'uso di deep: true garantisce la reattività anche per modifiche
                 * annidate (es. values[0].selected = true).
                 */
                "detailForm.data.fruits": {
                    deep: true,
                    handler: function() {
                        this.$nextTick( function() {
                            if ( !this._cascadingFruit ) {
                                this._cascadingFruit = true;
                                this.processFruitCascade().finally( function() {
                                    this._cascadingFruit = false;
                                }.bind( this ) );
                            }
                        }.bind( this ) );
                    },
                },
            },

            methods: {
                // MARK: Lifecycle
                /**
                 * Reimposta il form di dettaglio ai valori predefiniti.
                 * Sostituisce tutti i dati del form con una nuova istanza pulita,
                 * resettando frutti e product items.
                 */
                resetDetailForm: function() {
                    const fresh = createDefaultDetailForm();
                    Object.assign( this.detailForm, fresh );
                    this.detailForm.data.fruits = [];
                    this.detailForm.data.product.items = [];
                },

                // MARK: Custom Image
                /**
                 * Attiva o disattiva la modalità immagine personalizzata per la placca.
                 * Quando attivata, carica l'immagine di sfondo esistente e scambia
                 * la vista tra designer standard e personalizzato.
                 * Modifica il DOM mostrando/nascondendo #plate-designer e #plate-custom-designer.
                 */
                toggleCustomImage: function() {
                    const id = this.detailForm.data.id;
                    if ( id ) {
                        this.loadBackgroundCustomImage( id );
                    }
                    // La visibilità è gestita da v-show nel template
                },

                /**
                 * Carica l'immagine personalizzata di sfondo per un quotation item.
                 * Effettua una richiesta AJAX per ottenere le immagini associate all'item.
                 * @param {string} quotationItemId - Identificativo del quotation item.
                 */
                loadBackgroundCustomImage: async function( quotationItemId ) {
                    if ( !quotationItemId ) {
                        return;
                    }
                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotation-items/" + quotationItemId + "/images",
                        callback: {
                            done: ( xhr ) => {
                                if ( xhr.data && xhr.data.length > 0 && xhr.data[0].uri ) {
                                    this.backgroundCustomImage = xhr.data[0];
                                }
                            },
                        },
                    } );
                },

                /**
                 * Apre il modale di selezione immagini per il quotation item corrente.
                 * Utilizza l'app file modale passando tipo e identificativo dell'item.
                 */
                openImagesList: function() {
                    const type = "quotationItem";
                    const value = {
                        type: type,
                        id: this.detailForm.data.id,
                        name: this.detailForm.data.id,
                    };
                    fileApp().open( value );
                },

                // MARK: Lines / Models / Finishes
                /**
                 * Carica l'elenco delle linee prodotto per la categoria 22.
                 * Effettua una richiesta AJAX e aggiorna la lista lines.
                 */
                loadLines: async function() {
                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotations/lines/22",
                        callback: {
                            done: ( xhr ) => {
                                this.lines = xhr.data;
                            },
                        },
                    } );
                },

                /**
                 * Carica l'elenco dei modelli per la linea attualmente selezionata.
                 * Effettua una richiesta AJAX e aggiorna la lista models.
                 * Salva la preferenza utente per la linea.
                 */
                loadModels: async function() {
                    const lineId = this.detailForm.data.product.line.id;
                    if ( !lineId ) {
                        return;
                    }
                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotations/models/" + lineId,
                        callback: {
                            done: ( xhr ) => {
                                this.models = xhr.data;
                            },
                        },
                    } );
                    AP.setUserPref( "plate.lineId", lineId );
                },

                /**
                 * Carica l'elenco delle finiture per la linea selezionata.
                 * Effettua una richiesta AJAX e aggiorna la lista finishes.
                 * Verifica la possibilità di salvare e salva la preferenza utente per il modello.
                 */
                loadFinishes: async function() {
                    const modelId = this.detailForm.data.product.model.id;
                    const lineId = this.detailForm.data.product.line.id;
                    if ( !modelId || modelId === "" ) {
                        return;
                    }
                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotations/finishes/22/" + lineId,
                        callback: {
                            done: ( xhr ) => {
                                this.finishes = xhr.data;
                            },
                        },
                    } );
                    this.checkCanSave();
                    AP.setUserPref( "plate.modelId", modelId );
                },

                // MARK: Zones
                /**
                 * Carica l'elenco completo delle zone di quotazione.
                 * Filtra le zone separando quelle principali (senza origine) dalle sottozone.
                 * Aggiorna le proprietà allZones, zones e subzones.
                 */
                loadZones: async function() {
                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotations/" + AP.page.quotation.id + "/zones",
                        callback: {
                            done: ( xhr ) => {
                                const allZones = xhr.data || [];
                                this.allZones = allZones;
                                this.zones = allZones.filter( ( zone ) => {
                                    return !zone.origin;
                                } );
                            },
                        },
                    } );
                },

                /**
                 * Carica le sottozone corrispondenti a una zona padre.
                 * Resetta la selezione della sottozona corrente.
                 * @param {string} zoneId - Identificativo della zona padre.
                 */
                loadSubZones: function( zoneId ) {
                    this.detailForm.data.quotationSubzoneId = "";
                    this.detailForm.data.quotationSubzone = null;
                    if ( !zoneId ) {
                        this.subzones = [];
                        return;
                    }
                    this.subzones = this.allZones.filter( ( z ) => {
                        return z.origin?.id === zoneId;
                    } );
                },

                /**
                 * Gestisce il cambiamento della zona di quotazione selezionata.
                 * Aggiorna l'oggetto quotationZone nel form con i dati completi della zona scelta.
                 */
                onZoneChange: function() {
                    const zoneId = this.detailForm.data.quotationZoneId;
                    if ( zoneId ) {
                        const match = this.allZones.find( ( z ) => { return z.id === zoneId; } );
                        if ( match ) {
                            this.detailForm.data.quotationZone = match;
                        }
                    } else {
                        this.detailForm.data.quotationZone = { id: "", name: "" };
                    }
                },

                // MARK: Product loading
                /**
                 * Popola i campi del prodotto nel form di dettaglio a partire dai dati ricevuti.
                 * Imposta ID, finitura, modello, linea e immagine del prodotto.
                 * @param {Object} product - Dati del prodotto da mappare.
                 * @param {string} product.id - Identificativo del prodotto.
                 * @param {Object} product.finish - Oggetto finitura con proprietà id.
                 * @param {Object} product.model - Oggetto modello con proprietà id e code.
                 * @param {Object} product.line - Oggetto linea con proprietà id.
                 * @param {Object|null} product.horizontalImage - Immagine orizzontale con id e uri.
                 * @param {Object|null} product.verticalImage - Immagine verticale con id e uri.
                 */
                populateProduct: function( product ) {
                    const image = product.horizontalImage || product.verticalImage;
                    this.detailForm.data.product.id = product.id || "";
                    this.detailForm.data.product.finish.id = product.finish.id;
                    this.detailForm.data.product.finish.name = product.finish.name || "";
                    this.detailForm.data.product.model.id = product.model.id;
                    this.detailForm.data.product.model.code = product.model.code;
                    this.detailForm.data.product.model.name = product.model.name || "";
                    this.detailForm.data.product.line.id = product.line.id;
                    this.detailForm.data.product.line.name = product.line.name || "";
                    this.detailForm.data.product.image.id = ( image?.id ) || "";
                    this.detailForm.data.product.image.uri = ( image?.uri ) || "";
                },

                /**
                 * Carica il prodotto in base a linea, modello e finitura selezionati.
                 * Effettua una richiesta AJAX per ottenere il prodotto, poi carica i product items
                 * e configura la placca. Salva la preferenza utente per la finitura.
                 */
                loadProduct: async function() {
                    const lineId = this.detailForm.data.product.line.id;
                    const modelId = this.detailForm.data.product.model.id;
                    const finishId = this.detailForm.data.product.finish.id;
                    AP.setUserPref( "plate.finishId", finishId );

                    if ( !finishId || finishId === "" ) {
                        this.detailForm.data.product.items = [];
                        return;
                    }

                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotation-items/product/by-params?categoryId=22&lineId=" + lineId + "&modelId=" + modelId + "&finishId=" + finishId,
                        callback: {
                            done: ( xhr ) => {
                                this.populateProduct( xhr.data );
                            },
                        },
                    } );

                    await this.firstLoadProductItems();
                    await this.loadPlate();
                },

                // MARK: Plate / Frame
                /**
                 * Carica i dati del telaio e configura la placca.
                 * Cerca il telaio corrispondente al codice modello, effettua una richiesta AJAX
                 * e aggiorna le proprietà della placca (dimensioni, orientamento, griglia, immagine).
                 * Se viene fornito un orientamento, attiva il cambio orientamento.
                 * @param {Object} [orientationValue] - Orientamento opzionale da applicare dopo il caricamento.
                 */
                loadPlate: async function( orientationValue ) {
                    const modelCode = this.detailForm.data.product.model.code;
                    const image = this.detailForm.data.product.image;

                    const frame = AP.page.frames.find( ( f ) => {
                        return f.code === modelCode;
                    } );

                    if ( !frame ) {
                        AP.widget.notify( "error", `Modello [${modelCode}] non trovato. Impossibile continuare.` );
                        return;
                    }

                    const frameId = frame.id;
                    this.detailForm.data.product.frame.id = frameId;

                    await ajax( {
                        method: "GET",
                        url: BASE + "/frames/" + frameId,
                        callback: {
                            done: ( xhr ) => {
                                this.plate.id = xhr.data.id;
                                this.plate.code = xhr.data.code;
                                this.plate.width = xhr.data?.width ?? 1200;
                                this.plate.height = xhr.data?.height ?? 500;
                                this.plate.orientation = xhr.data.orientation;
                                this.detailForm.data.product.orientation = orientationValue || xhr.data.orientation;
                                this.plate.cellOrientation = xhr.data.cellOrientation;
                                this.availableOrientations = xhr.data.availableOrientations;
                                this.plate.grid = xhr.data.grid;
                                this.plate.image = image;
                                this.$nextTick( () => {
                                    if ( orientationValue ) {
                                        this.changeOrientation();
                                    } else {
                                        this.renderPlateWithFruits();
                                    }
                                } );
                            },
                        },
                    } );
                },

                /**
                 * Cambia l'orientamento della placca e ricarica la configurazione.
                 * Effettua una richiesta AJAX per ottenere i dati del telaio con il nuovo orientamento,
                 * aggiorna la griglia e riconfigura la placca.
                 * Riapplica le immagini dei product items dopo il cambio.
                 */
                changeOrientation: async function() {
                    const orientationId = this.detailForm.data.product.orientation.id;
                    const frameId = this.detailForm.data.product.frame.id;
                    const productId = this.detailForm.data.product.id;

                    if ( !orientationId || !frameId ) {
                        return;
                    }

                    await ajax( {
                        method: "GET",
                        url: BASE + "/frames/" + frameId + "?orientationId=" + orientationId + "&productId=" + productId,
                        callback: {
                            done: ( xhr ) => {
                                this.plate.orientation = xhr.data.orientation;
                                this.plate.cellOrientation = xhr.data.cellOrientation;
                                this.plate.grid = xhr.data.grid;
                                this.plate.image = xhr.data.image;
                                this.detailForm.data.product.orientation = xhr.data.orientation;
                                this.$nextTick( () => {
                                    this.renderPlateWithFruits();
                                } );
                            },
                        },
                    } );
                },

                /**
                 * Riapplica le immagini dei product items dopo un cambio di orientamento.
                 * Scorre tutti gli attributi del prodotto e per ogni valore selezionato
                 * richiama il metodo changeImage.
                 */
                reapplyProductItemImages: function() {
                    const items = this.detailForm.data.product.items;
                    for ( let i = 0; i < items.length; i++ ) {
                        const attr = items[i];
                        if ( attr.values && attr.values.length ) {
                            const selected = attr.values.find( ( v ) => { return v.selected; } );
                            if ( selected && selected.productItemId ) {
                                this.changeImage( selected );
                            }
                        }
                    }
                },

                // MARK: Product Items
                /**
                 * Carica per la prima volta i product items del prodotto selezionato.
                 * Organizza gli items per attributo raggruppandone i valori.
                 * Se esiste già un quotation item, ripristina le selezioni salvate.
                 */
                firstLoadProductItems: async function() {
                    const quotationItemId = this.detailForm.data.id;
                    const productId = this.detailForm.data.product.id;

                    await ajax( {
                        method: "GET",
                        url: BASE + "/product-items?productId=" + productId,
                        callback: {
                            done: ( xhr ) => {
                                if ( xhr.count > 0 ) {
                                    const items = [];
                                    for ( const item of xhr.data ) {
                                        const existing = items.find( ( d ) => {
                                            return d.attributeId === item.attribute.id;
                                        } );
                                        if ( existing ) {
                                            const already = existing.values.find( ( v ) => {
                                                return v.productItemId === item.id;
                                            } );
                                            if ( !already ) {
                                                existing.values.push( {
                                                    attributeId: item.attribute.id,
                                                    attributeValue: item.attributeValue,
                                                    productItemId: item.id,
                                                    images: item.images,
                                                    selected: false,
                                                    orderby: item.orderby || 0,
                                                    horizontalImage: item.horizontalImage,
                                                    verticalImage: item.verticalImage,
                                                } );
                                            }
                                        } else {
                                            items.push( {
                                                attributeId: item.attribute.id,
                                                attributeName: item.attribute.name,
                                                level: 0,
                                                values: [ {
                                                    attributeValue: item.attributeValue,
                                                    attributeId: item.attribute.id,
                                                    productItemId: item.id,
                                                    images: item.images,
                                                    selected: false,
                                                    orderby: item.orderby || 0,
                                                    horizontalImage: item.horizontalImage,
                                                    verticalImage: item.verticalImage,
                                                } ],
                                            } );
                                        }
                                    }
                                    this.detailForm.data.product.items = items;
                                }
                            },
                        },
                    } );

                    // Auto-seleziona il primo valore degli attributi radice e carica i figli
                    for ( const pi of this.detailForm.data.product.items ) {
                        if ( pi.level === 0 && !pi.parentItemId && pi.values && pi.values.length ) {
                            const hasSelection = pi.values.some( ( v ) => { return v.selected; } );
                            if ( !hasSelection ) {
                                pi.values[0].selected = true;
                                await this.loadProductItems( pi.values[0].productItemId, pi.attributeId );
                            }
                        }
                    }

                    if ( quotationItemId ) {
                        await ajax( {
                            method: "GET",
                            url: BASE + "/quotation-items/" + quotationItemId + "/product-items",
                            callback: {
                                done: ( xhr ) => {
                                    this.restoreProductItemSelections( xhr.data );
                                },
                            },
                        } );
                    }
                },

                /**
                 * Ripristina le selezioni dei product items a partire dai dati salvati.
                 * Ordina gli items per orderby e carica ricorsivamente i figli.
                 * Al termine, applica l'immagine del product item selezionato.
                 * @param {Array} data - Elenco dei quotation item product items salvati.
                 */
                restoreProductItemSelections: function( data ) {
                    if ( !data || !data.length ) {
                        return;
                    }
                    data.sort( ( a, b ) => {
                        return a.productItem.orderby - b.productItem.orderby;
                    } );
                    data.forEach( ( qipi ) => {
                        this.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id );
                    } );
                    this.$nextTick( () => {
                        this.renderPlateWithFruits();
                    } );
                },


                /**
                 * Carica i product items figli per un dato attributo e origine.
                 * Se originId è vuoto, deseleziona i valori dell'attributo e rimuove gli items figli.
                 * Altrimenti, carica i figli tramite AJAX e li organizza per attributo.
                 * Gestisce la sostituzione degli items esistenti con quelli nuovi.
                 * @param {string} [originId=""] - Identificativo dell'item origine per il caricamento dei figli.
                 * @param {string} attributeId - Identificativo dell'attributo da aggiornare.
                 */
                loadProductItems: async function( originId, attributeId ) {
                    const productId = this.detailForm.data.product.id;
                    const items = this.detailForm.data.product.items;

                    originId = originId || "";

                    if ( originId === "" ) {
                        let actualIndex = null;
                        for ( let i = items.length - 1; i >= 0; i-- ) {
                            if ( items[i].attributeId == attributeId ) {
                                actualIndex = i;
                                items[i].values.forEach( ( v ) => {
                                    v.selected = false;
                                } );
                            }
                        }
                        if ( actualIndex !== null ) {
                            const idx = actualIndex + 1;
                            while ( idx < items.length ) {
                                if ( items[idx].level > items[actualIndex].level ) {
                                    items.splice( idx, 1 );
                                } else {
                                    break;
                                }
                            }
                        }
                        this.detailForm.data.product.items = items.slice();
                        return;
                    }

                    await ajax( {
                        method: "GET",
                        url: BASE + "/product-items?productId=" + productId + "&originId=" + originId,
                        callback: {
                            done: ( xhr ) => {
                                let parentIndex = -1;
                                items.forEach( ( d, idx ) => {
                                    if ( d.attributeId == attributeId ) {
                                        parentIndex = idx;
                                    }
                                } );

                                // Se l'attributo non è più presente in items (es. race condition
                                // tra chiamate AJAX asincrone annidate dovute al processFruitCascade
                                // o a rapide interazioni utente), si esce senza modificare lo stato.
                                if ( parentIndex === -1 ) {
                                    this.detailForm.data.product.items = items.slice();
                                    return;
                                }

                                const parent = items[parentIndex];
                                parent.values.forEach( ( v ) => {
                                    v.selected = v.productItemId == originId;
                                } );

                                // Rimuove tutti gli elementi figli (level > parent.level)
                                // che seguono immediatamente il genitore
                                const i = parentIndex + 1;
                                while ( i < items.length ) {
                                    if ( items[i].level > parent.level ) {
                                        items.splice( i, 1 );
                                    } else {
                                        break;
                                    }
                                }

                                if ( xhr.data.length > 0 ) {
                                    const newAttrs = [];
                                    let lastAttrId = null;
                                    let attr = null;

                                    xhr.data.forEach( ( item ) => {
                                        if ( lastAttrId == null || lastAttrId != item.attribute.id ) {
                                            attr = {
                                                attributeId: item.attribute.id,
                                                attributeName: item.attribute.name,
                                                parentAttributeId: attributeId,
                                                parentItemId: originId,
                                                level: parent.level + 1,
                                                values: [],
                                                horizontalImage: item.horizontalImage,
                                                verticalImage: item.verticalImage,
                                                orderby: item.orderby,
                                            };
                                            newAttrs.push( attr );
                                        }
                                        attr.values.push( {
                                            attributeValue: item.attributeValue,
                                            productItemId: item.id,
                                            selected: false,
                                            horizontalImage: item.horizontalImage,
                                            verticalImage: item.verticalImage,
                                            orderby: item.orderby,
                                        } );
                                        lastAttrId = item.attribute.id;
                                    } );

                                    for ( let ni = 0; ni < newAttrs.length; ni++ ) {
                                        items.splice( parentIndex + 1 + ni, 0, newAttrs[ni] );
                                    }
                                }
                                this.detailForm.data.product.items = items.slice();
                            },
                        },
                    } );

                    // Auto-seleziona il primo valore di ogni nuovo figlio e carica ricorsivamente
                    const allItems = this.detailForm.data.product.items;
                    let parentIdx = -1;
                    for ( let i = 0; i < allItems.length; i++ ) {
                        if ( allItems[i].attributeId == attributeId ) {
                            parentIdx = i;
                            break;
                        }
                    }
                    if ( parentIdx !== -1 ) {
                        const parentLevel = allItems[parentIdx].level;
                        const children = [];
                        for ( let i = parentIdx + 1; i < allItems.length; i++ ) {
                            if ( allItems[i].level > parentLevel ) {
                                children.push( allItems[i] );
                            } else {
                                break;
                            }
                        }
                        for ( const child of children ) {
                            if ( child.values && child.values.length ) {
                                const hasSelection = child.values.some( ( v ) => { return v.selected; } );
                                if ( !hasSelection ) {
                                    child.values[0].selected = true;
                                    await this.loadProductItems( child.values[0].productItemId, child.attributeId );
                                }
                            }
                        }
                    }
                },

                /**
                 * Cambia l'immagine visualizzata per un product item selezionato.
                 * Cerca l'immagine corrispondente all'orientamento corrente tra quelle disponibili.
                 * Se trovata, crea o aggiorna un elemento DOM sovrapposto al designer della placca.
                 * @param {Object} item - Oggetto valore del product item con productItemId e images.
                 */
                changeImage: function( item ) {
                    if ( !item || !item.productItemId ) {
                        return;
                    }
                    let uri = "";
                    const orientationId = this.detailForm.data.product.orientation.id;
                    if ( item.images?.length ) {
                        const targetOrientation = orientationId === "HOR" ? "horizontal" : "vertical";
                        for ( const image of item.images ) {
                            if ( image.type?.id == targetOrientation ) {
                                uri = image.uri;
                                break;
                            }
                        }
                    }
                    if ( uri ) {
                        const existing = $( `#productItem-image-${item.productItemId}` );
                        if ( existing.length ) {
                            existing.css( "background-image", `url('${uri}')` );
                        } else {
                            $( "<div>" )
                                .attr( "id", `productItem-image-${item.productItemId}` )
                                .css( {
                                    "background-image": `url('${uri}')`,
                                    "background-size": "cover",
                                    "background-position": "center",
                                    position: "absolute",
                                    top: 0,
                                    left: 0,
                                    width: "100%",
                                    height: "100%",
                                    "z-index": item.productItemId,
                                } )
                                .insertBefore( "#plate-layers" );
                        }
                    } else {
                        $( `#productItem-image-${item.productItemId}` ).remove();
                    }
                },

                /**
                 * Gestisce la selezione di un product item da parte dell'utente.
                 * Carica i product items figli e aggiorna l'immagine corrispondente.
                 * @param {string} selectedId - Identificativo del product item selezionato.
                 * @param {string} attributeId - Identificativo dell'attributo.
                 * @param {Object} value - Oggetto valore selezionato per l'aggiornamento dell'immagine.
                 */
                handleProductItemSelect: async function( selectedId, attributeId, value ) {
                    await this.loadProductItems( selectedId, attributeId );
                    this.renderPlateWithFruits();
                },

                // MARK: Fruits
                /**
                 * Gestisce la selezione di un frutto dall'elenco dei suggerimenti.
                 * Crea un nuovo frutto, lo aggiunge al form, lo disegna nella placca
                 * e inizializza i suoi product items e l'effetto hover.
                 * @param {Object} selectedFruit - Dati del frutto selezionato.
                 */
                onSelectFruit: async function( selectedFruit ) {
                    const newFruit = createFruit( { position: 1, fruit: selectedFruit } );
                    this.detailForm.data.fruits.push( newFruit );
                    await this.addProductItemsToFruit( newFruit.id );
                    this.renderPlateWithFruits();
                },

                /**
                 * Aggiunge gli effetti hover al DOM per un frutto nella lista e nella griglia.
                 * All'entrata del mouse colora lo sfondo; all'uscita ripristina il colore originale.
                 * Usa .off() prima di .on() per evitare accumulo di handler in caso di
                 * chiamate multiple (es. da renderPlateWithFruits).
                 * @param {string} fruitId - Identificativo del frutto.
                 */
                addFruitHover: function( fruitId ) {
                    $( `.quotation-fruit-row[data-fruit-id="${fruitId}"]` )
                        .off( "mouseenter mouseleave" )
                        .on( "mouseenter", () => {
                            $( `#quotation-plate-fruits #${fruitId}` ).css( "background-color", "rgba(162, 253, 161, 0.44)" );
                            $( `div[data-fruit-id="${fruitId}"]` ).css( "background-color", "#a3fda170" );
                        } )
                        .on( "mouseleave", () => {
                            $( `#quotation-plate-fruits #${fruitId}` ).css( "background-color", "" );
                            $( `div[data-fruit-id="${fruitId}"]` ).css( "background-color", "" );
                        } );
                },

                /**
                 * Ricostruisce da zero l'intero designer della placca:
                 * svuota il contenitore grafico, richiama configPlate() per ridisegnare
                 * griglia e frutti, poi riapplica tutte le sovrapposizioni
                 * (immagini attributi placca, immagini frutti, overlay attributi frutto).
                 * Va chiamato dopo ogni modifica ai dati dei frutti
                 * (aggiunta, rimozione, cambio attributo) o della placca.
                 */
                renderPlateWithFruits: function() {
                    this.$nextTick( function() {
                        const gm = getGridModule();
                        if ( !gm ) {
                            return;
                        }

                        $( ".plate-designer" ).empty();
                        configPlate();
                        for ( const fruit of this.detailForm.data.fruits ) {
                            const obj = mapFruitForPlate( fruit );
                            if ( fruit.positionIds && fruit.positionIds.length ) {
                                pub.fruitsController.addFruitToPositions( obj, fruit.positionIds );
                            } else {
                                pub.fruitsController.addFruitToPlate( obj );
                            }
                        }
                        this.reapplyProductItemImages();
                        for ( const fruit of this.detailForm.data.fruits ) {
                            this.addFruitHover( fruit.id );
                            this.changeFruitImage( fruit.id );
                            if ( fruit.items ) {
                                for ( const fi of fruit.items ) {
                                    const selected = fi.values && fi.values.find( function( v ) { return v.selected; } );
                                    if ( selected && selected.productItemId ) {
                                        this.updateFruitAttributeOverlay( fruit.id, fi.attributeId, selected, fi.parentAttributeId );
                                    }
                                }
                            }
                        }
                    }.bind( this ) );
                },

                /**
                 * Rimuove un frutto dalla lista del form e dalla placca.
                 * Aggiorna sia i dati del form che il controller dei frutti nella griglia.
                 * @param {Object} fruit - Oggetto frutto da rimuovere.
                 */
                removeFruit: function( fruit ) {
                    const idx = this.detailForm.data.fruits.indexOf( fruit );
                    if ( idx > -1 ) {
                        this.detailForm.data.fruits.splice( idx, 1 );
                    }
                    this.renderPlateWithFruits();
                },

                /**
                 * Espande o comprime la visualizzazione dei dettagli di un singolo frutto.
                 * @param {Object} fruit - Oggetto frutto di cui invertire lo stato expanded.
                 */
                toggleFruit: function( fruit ) {
                    fruit.expanded = !fruit.expanded;
                },

                /**
                 * Espande o comprime tutti i frutti contemporaneamente.
                 * Aggiorna l'etichetta del pulsante in base allo stato corrente.
                 */
                toggleFruits: function() {
                    const currentLabel = this.toggleFruitsLabel;
                    const newExpandedState = currentLabel === "Espandi tutti";
                    this.detailForm.data.fruits.forEach( ( f ) => {
                        f.expanded = newExpandedState;
                    } );
                    this.toggleFruitsLabel = newExpandedState ? "Comprimi tutti" : "Espandi tutti";
                },

                /**
                 * Carica i frutti associati a una placca esistente.
                 * Effettua una richiesta AJAX, crea i frutti e li posiziona nella griglia.
                 * Carica i product items per ciascun frutto e inizializza gli effetti hover.
                 */
                loadFruits: async function() {
                    const id = this.detailForm.data.id;
                    if ( !id ) {
                        return;
                    }
                    const fruitQIPIs = [];
                    const fruits = [];

                    await ajax( {
                        method: "GET",
                        url: BASE + "/quotation-items/plate/" + id + "/fruits",
                        callback: {
                            done: ( xhr ) => {
                                xhr.data.forEach( ( thisFruit ) => {
                                    const newFruit = createFruit( { position: 1, fruit: thisFruit.fruit, id: thisFruit.id } );
                                    if ( thisFruit.positions && thisFruit.positions.length ) {
                                        newFruit.positionIds = thisFruit.positions.map( ( p ) => { return p.position; } );
                                    }
                                    fruits.push( newFruit );
                                    this.detailForm.data.fruits.push( newFruit );

                                    thisFruit?.items?.forEach( ( item ) => {
                                        if ( item.productItem && item.productItem.attributeValue && item.productItem.attributeValue.allowNote ) {
                                            fruitQIPIs.push( {
                                                quotation_item_fruit_id: thisFruit.id,
                                                product_item_id: item.productItem.id,
                                                attribute_value_id: item.productItem.attributeValue.id,
                                                note: item.note,
                                            } );
                                        }
                                    } );
                                } );
                                this.detailForm.data.fruitQuotationItemProductItems = fruitQIPIs;
                            },
                        },
                    } );

                    for ( const fruit of fruits ) {
                        await this.addProductItemsToFruit( fruit.id );
                    }
                    this.renderPlateWithFruits();
                },

                /**
                 * Carica i product items per un frutto specifico.
                 * Effettua una richiesta AJAX per gli items del prodotto frutto e per i product items salvati.
                 * Aggiorna la mappa delle immagini e ripristina le selezioni esistenti.
                 * @param {string} fruitId - Identificativo del frutto.
                 */
                addProductItemsToFruit: async function( fruitId ) {
                    const fruits = this.detailForm.data.fruits;
                    let thisFruit = null;
                    for ( let i = 0; i < fruits.length; i++ ) {
                        if ( fruits[i].id === fruitId ) {
                            thisFruit = fruits[i];
                            break;
                        }
                    }

                    if ( !thisFruit ) {
                        return;
                    }

                    const productId = thisFruit.fruit.id;

                    await ajax( {
                        method: "GET",
                        url: BASE + "/product-items?productId=" + productId,
                        callback: {
                            done: ( xhr ) => {
                                if ( xhr.count > 0 ) {
                                    const fruitItems = thisFruit.items || [];
                                    xhr.data.forEach( ( item ) => {
                                        this.productItemsImages[ item.id ] = item.horizontalImage ? item.horizontalImage.uri : "";
                                        const existing = fruitItems.find( ( d ) => { return d.attributeId === item.attribute.id; } );
                                        if ( existing ) {
                                            existing.values.push( {
                                                attributeValue: item.attributeValue,
                                                productItemId: item.id,
                                                images: item.images,
                                                selected: false,
                                                orderby: item.orderby || 0,
                                                horizontalImage: item.horizontalImage,
                                                verticalImage: item.verticalImage,
                                            } );
                                        } else {
                                            fruitItems.push( {
                                                id: NM.util.uuid(),
                                                attributeId: item.attribute.id,
                                                attributeName: item.attribute.name,
                                                level: 0,
                                                values: [ {
                                                    attributeValue: item.attributeValue,
                                                    productItemId: item.id,
                                                    images: item.images,
                                                    selected: false,
                                                    orderby: item.orderby || 0,
                                                    horizontalImage: item.horizontalImage,
                                                    verticalImage: item.verticalImage,
                                                } ],
                                            } );
                                        }
                                    } );
                                    thisFruit.items = fruitItems;
                                }
                            },
                        },
                    } );

                    // Carica prima le selezioni salvate degli attributi (se presenti)
                    const savedSelections = [];
                    const qifId = thisFruit.id;
                    if ( typeof qifId === "number" ) {
                        await ajax( {
                            method: "GET",
                            url: BASE + "/quotation-items/fruits/" + qifId + "/product-items",
                            callback: {
                                done: ( xhr ) => {
                                    if ( xhr.data && xhr.data.length ) {
                                        savedSelections.push( ...xhr.data );
                                    }
                                },
                            },
                        } );
                    }

                    // Se i valori degli attributi sono salvati nel db, applica quelli
                    if ( savedSelections.length > 0 ) {
                        this._cascadingFruit = true;
                        savedSelections.sort( ( a, b ) => { return a.productItem.orderby - b.productItem.orderby; } );
                        for ( const qipi of savedSelections ) {
                            for ( const fi of thisFruit.items ) {
                                if ( fi.attributeId == qipi.productItem.attribute.id ) {
                                    const match = fi.values.find( ( v ) => { return v.productItemId == qipi.productItem.id; } );
                                    if ( match ) {
                                        match.selected = true;
                                        await this.loadFruitProductItems( fruitId, qipi.productItem.id, fi.id, true );
                                        break;
                                    }
                                }
                            }
                        }
                        this._cascadingFruit = false;
                    } else {
                        // Altrimenti procede con l'auto-selezione normale:
                        // auto-seleziona il primo valore degli attributi radice e carica i figli
                        for ( const fi of thisFruit.items ) {
                            if ( fi.level === 0 && !fi.parentItemId && fi.values && fi.values.length ) {
                                const hasSelection = fi.values.some( ( v ) => { return v.selected; } );
                                if ( !hasSelection ) {
                                    fi.values[0].selected = true;
                                    await this.loadFruitProductItems( fruitId, fi.values[0].productItemId, fi.id );
                                }
                            }
                        }
                    }
                },

                /**
                 * Imposta l'immagine radice del frutto
                 * sul tag <img> del frutto nella griglia. Se il frutto non ha un'immagine
                 * radice (es. nessuna immagine definita sul prodotto frutto), nasconde
                 * completamente il tag <img>.
                 * NON carica immagini di combinazione dagli attributi selezionati
                 * @param {string} fruitId - Identificativo del frutto.
                 */
                changeFruitImage: function( fruitId ) {
                    const fruit = this.detailForm.data.fruits.find( ( f ) => { return f.id === fruitId; } );
                    if ( !fruit ) {
                        return;
                    }
                    const img = $( "#quotation-plate-fruits #" + fruitId + " img" );
                    if ( !img.length ) {
                        return;
                    }
                    const rootImage = fruit.fruit?.horizontalImage?.uri;
                    if ( rootImage ) {
                        img.attr( "src", rootImage ).show();
                        return;
                    }
                    // Se il frutto non ha l'immagine e almeno un attributo selezionato ce l'ha,
                    // nasconde l'immagine generica. Altrimenti mostra il
                    // placeholder generico per non lasciare la cella vuota.
                    const hasOverlayImage = fruit.items?.some( ( fi ) => {
                        const sel = fi.values?.find( ( v ) => { return v.selected; } );
                        return sel && ( sel.horizontalImage?.uri || sel.verticalImage?.uri || sel.images?.length );
                    } );
                    if ( hasOverlayImage ) {
                        img.hide();
                    } else {
                        img.show();
                    }
                },

                /**
                 * Restituisce la prima immagine disponibile tra gli ID dei product items forniti.
                 * Scorre l'elenco e controlla la mappa delle immagini precaricata.
                 * @param {Array<string>} productItemIds - Elenco degli ID dei product items.
                 * @returns {string|null} URI della prima immagine trovata o null.
                 */
                getFirstFruitImage: function( productItemIds ) {
                    for ( const prodctItemId of productItemIds ) {
                        const img = this.productItemsImages[ prodctItemId ];
                        if ( img && img !== "" ) {
                            return img;
                        }
                    }
                    return null;
                },

                /**
                 * Carica i product items figli per un attributo di un frutto specifico.
                 * Se originId è vuoto, deseleziona i valori dell'attributo e rimuove gli items figli.
                 * Altrimenti, carica i figli tramite AJAX e li organizza per attributo.
                 * @param {string} fruitId - Identificativo del frutto.
                 * @param {string} [originId=""] - Identificativo dell'item origine per il caricamento dei figli.
                 * @param {string} itemId - Identificativo univoco dell'item attributo (fi.id).
                 * @param {boolean} [skipAutoSelect=false] - Se true, non auto-seleziona il primo
                 *   valore dei figli dopo il caricamento. Utile quando si ripristinano selezioni
                 *   salvate (il loop chiamante si occupa di selezionare i valori corretti).
                 */
                loadFruitProductItems: async function( fruitId, originId, itemId, skipAutoSelect ) {
                    let fruit = null;
                    for ( const fr of this.detailForm.data.fruits ) {
                        if ( fr.id === fruitId ) {
                            fruit = fr;
                            break;
                        }
                    }
                    if ( !fruit ) {
                        return;
                    }
                    const fruitItems = fruit.items;
                    const productId = fruit.fruit.id;
                    originId = originId || "";

                    const itemIdx = fruitItems.findIndex( ( d ) => { return d.id === itemId; } );
                    if ( itemIdx === -1 ) {
                        fruit.items = fruitItems.slice();
                        return;
                    }
                    const itemAttr = fruitItems[itemIdx];
                    const attributeId = itemAttr.attributeId;

                    if ( originId === "" ) {
                        itemAttr.values.forEach( ( v ) => {
                            v.selected = false;
                        } );
                        const idx = itemIdx + 1;
                        while ( idx < fruitItems.length ) {
                            if ( fruitItems[idx].level > itemAttr.level ) {
                                fruitItems.splice( idx, 1 );
                            } else {
                                break;
                            }
                        }
                        fruit.items = fruitItems.slice();
                        return;
                    }

                    await ajax( {
                        method: "GET",
                        url: BASE + "/product-items?productId=" + productId + "&originId=" + originId,
                        callback: {
                            done: ( xhr ) => {
                                let parentIndex = -1;
                                fruitItems.forEach( ( d, idx ) => {
                                    if ( d.id === itemId ) {
                                        parentIndex = idx;
                                    }
                                } );

                                if ( parentIndex === -1 ) {
                                    fruit.items = fruitItems.slice();
                                    return;
                                }

                                const parent = fruitItems[parentIndex];
                                parent.values.forEach( ( v ) => {
                                    v.selected = v.productItemId == originId;
                                } );

                                // Rimuove i vecchi figli prima di caricare i nuovi
                                const i = parentIndex + 1;
                                while ( i < fruitItems.length ) {
                                    if ( fruitItems[i].level > parent.level ) {
                                        fruitItems.splice( i, 1 );
                                    } else {
                                        break;
                                    }
                                }

                                if ( xhr.data.length > 0 ) {
                                    const newAttrs = [];
                                    let lastAttrId = null;
                                    let attr = null;

                                    xhr.data.forEach( ( item ) => {
                                        if ( lastAttrId == null || lastAttrId != item.attribute.id ) {
                                            attr = {
                                                id: NM.util.uuid(),
                                                attributeId: item.attribute.id,
                                                attributeName: item.attribute.name,
                                                parentAttributeId: attributeId,
                                                parentItemId: originId,
                                                level: fruitItems[parentIndex].level + 1,
                                                values: [],
                                                horizontalImage: item.horizontalImage,
                                                verticalImage: item.verticalImage,
                                                orderby: item.orderby,
                                            };
                                            newAttrs.push( attr );
                                        }
                                        attr.values.push( {
                                            attributeValue: item.attributeValue,
                                            productItemId: item.id,
                                            selected: false,
                                            orderby: item.orderby || 0,
                                            horizontalImage: item.horizontalImage,
                                            verticalImage: item.verticalImage,
                                        } );
                                        lastAttrId = item.attribute.id;
                                    } );

                                    for ( let ni = 0; ni < newAttrs.length; ni++ ) {
                                        fruitItems.splice( parentIndex + 1 + ni, 0, newAttrs[ni] );
                                    }
                                }
                                fruit.items = fruitItems.slice();
                            },
                        },
                    } );

                    // Auto-seleziona il primo valore di ogni nuovo figlio
                    // Il watcher processFruitCascade si occuperà di caricare ricorsivamente
                    // i figli successivi e di chiamare updateFruitAttributeOverlay.
                    // Se skipAutoSelect è true, salta (il chiamante gestisce le selezioni).
                    if ( !skipAutoSelect ) {
                        const updatedFruitItems = fruit.items;
                        const fruitParentIdx = updatedFruitItems.findIndex( ( d ) => { return d.id === itemId; } );
                        if ( fruitParentIdx !== -1 ) {
                            const fruitParentLevel = updatedFruitItems[fruitParentIdx].level;
                            for ( let i = fruitParentIdx + 1; i < updatedFruitItems.length; i++ ) {
                                if ( updatedFruitItems[i].level > fruitParentLevel ) {
                                    if ( updatedFruitItems[i].values && updatedFruitItems[i].values.length ) {
                                        const hasSelection = updatedFruitItems[i].values.some( ( v ) => { return v.selected; } );
                                        if ( !hasSelection ) {
                                            updatedFruitItems[i].values[0].selected = true;
                                        }
                                    }
                                } else {
                                    break;
                                }
                            }
                        }
                    }
                },

                /**
                 * Gestisce la selezione di un product item per un frutto.
                 * Carica i product items figli e aggiorna l'immagine del frutto.
                 * @param {string} fruitId - Identificativo del frutto.
                 * @param {string} selectedId - Identificativo del product item selezionato.
                 * @param {string} itemId - Identificativo univoco dell'item attributo (fi.id).
                 * @param {Object} value - Oggetto valore selezionato.
                 */
                handleFruitProductItemSelect: async function( fruitId, selectedId, itemId, value ) {
                    await this.loadFruitProductItems( fruitId, selectedId, itemId );
                    this.renderPlateWithFruits();
                },

                /**
                 * Processa a cascata tutte le selezioni di attributi frutto.
                 * Questo metodo viene chiamato dal watcher su detailForm.data.fruits
                 * ogni volta che una value diventa selected=true, sia per interazione manuale
                 * dell'utente che per selezione automatica via codice.
                 *
                 * Usa un do-while perché ogni caricamento di figli può generare nuove
                 * selezioni automatiche (primo valore pre-selezionato), che a loro volta
                 * potrebbero avere figli da caricare.
                 *
                 * processed (Set) traccia le coppie fruitId + attributeId già processate
                 * per evitare loop infiniti su attributi foglia (senza figli): per questi
                 * childrenLoaded è sempre false, ma non vanno rieseguiti all'infinito.
                 *
                 * childrenLoaded verifica se esistono già items con parentAttributeId
                 * e parentItemId corrispondenti alla selezione corrente. Se true, significa
                 * che i figli sono già stati caricati (da un giro precedente del do-while
                 * o dal flusso manuale handleFruitProductItemSelect -> loadFruitProductItems).
                 */
                processFruitCascade: async function() {
                    const processed = new Set();
                    let cascaded;
                    do {
                        cascaded = false;
                        for ( const fruit of this.detailForm.data.fruits ) {
                            if ( !fruit.items ) {
                                continue;
                            }
                            for ( const item of fruit.items ) {
                                const key = fruit.id + "-" + item.attributeId;
                                if ( processed.has( key ) ) {
                                    continue;
                                }
                                const selected = item.values && item.values.find( ( v ) => { return v.selected; } );
                                if ( !selected || !selected.productItemId ) {
                                    continue;
                                }
                                const childrenLoaded = fruit.items.some( ( ci ) => {
                                    return ci.parentAttributeId === item.attributeId && ci.parentItemId === selected.productItemId;
                                } );
                                if ( !childrenLoaded ) {
                                    processed.add( key );
                                    await this.loadFruitProductItems( fruit.id, selected.productItemId, item.id );
                                    this.updateFruitAttributeOverlay( fruit.id, item.attributeId, selected, item.parentAttributeId );
                                    cascaded = true;
                                } else {
                                    processed.add( key );
                                }
                            }
                        }
                    } while ( cascaded );
                },

                /**
                 * Aggiorna l'overlay dell'attributo di un frutto sulla griglia della placca.
                 * Rimuove l'overlay esistente e ne crea uno nuovo con l'immagine corretta
                 * in base all'orientamento (orizzontale/verticale).
                 * @param {string} fruitId - Identificativo del frutto.
                 * @param {string} attributeId - Identificativo dell'attributo.
                 * @param {Object} value - Oggetto valore del product item con immagini e z-index.
                 * @param {string} [parentAttributeId] - Identificativo opzionale dell'attributo padre.
                 */
                updateFruitAttributeOverlay: function( fruitId, attributeId, value, parentAttributeId ) {
                    if ( !value || !attributeId ) {
                        return;
                    }
                    const fruitEl = $( "#quotation-plate-fruits #" + fruitId );
                    if ( !fruitEl.length ) {
                        return;
                    }
                    const overlayKey = parentAttributeId ? parentAttributeId + "-" + attributeId : attributeId;
                    fruitEl.find( "> .fruit-overlay-" + overlayKey ).remove();
                    const orientationId = this.detailForm.data.product.orientation.id;
                    const imageUri = orientationId === "VER" ? value.verticalImage?.uri : value.horizontalImage?.uri;
                    if ( imageUri ) {
                        const zIndex = ( value.orderby || 0 ) + 1040;
                        fruitEl.append( `<div class="fruit-overlay-${overlayKey}" style="z-index: ${zIndex}; width: 100%; height: 100%; position: absolute; top: 0; left: 0; background-image: url('${imageUri}'); background-size: contain; background-repeat: no-repeat; background-position: center"></div>` );
                    }
                },

                // MARK: Fruit Suggest
                /**
                 * Gestisce l'input di ricerca nel suggeritore frutti.
                 * Se il termine ha almeno 3 caratteri, effettua una richiesta AJAX
                 * per ottenere i suggerimenti filtrati per termine e linea.
                 * Aggiorna la lista fruitSuggestions e il flag di caricamento.
                 */
                onFruitSearchInput: function() {
                    const term = this.fruitSearchTerm;
                    if ( term.length < 3 ) {
                        this.fruitSuggestions = [];
                        return;
                    }
                    this.fruitSuggestLoading = true;
                    ajax( {
                        method: "GET",
                        url: BASE + "/fruits?str=" + encodeURIComponent( term ) + "&lineId=" + ( this.detailForm.data.product.line.id || "" ),
                        callback: {
                            done: ( xhr ) => {
                                this.fruitSuggestions = xhr.data || [];
                                this.fruitSuggestLoading = false;
                            },
                            fail: () => {
                                this.fruitSuggestLoading = false;
                            },
                        },
                    } );
                },

                /**
                 * Seleziona un frutto dai suggerimenti e lo aggiunge alla placca.
                 * Resetta il termine di ricerca e la lista dei suggerimenti.
                 * @param {Object} item - Frutto selezionato dai suggerimenti.
                 */
                selectFruitSuggestion: function( item ) {
                    this.onSelectFruit( item );
                    this.fruitSearchTerm = "";
                    this.fruitSuggestions = [];
                },

                // MARK: Position Suggest
                /**
                 * Gestisce l'input di ricerca nel suggeritore posizioni.
                 * Se il termine ha almeno 2 caratteri ed è selezionata una zona,
                 * effettua una richiesta AJAX per ottenere i suggerimenti.
                 * Aggiorna la lista positionSuggestions e il flag di caricamento.
                 */
                onPositionSearchInput: function() {
                    const term = this.positionSearchTerm;
                    const zoneId = this.detailForm.data.quotationZoneId;
                    if ( term.length < 2 || !zoneId ) {
                        this.positionSuggestions = [];
                        this.detailForm.data.position = { id: "", code: term };
                        return;
                    }
                    this.positionSuggestLoading = true;
                    ajax( {
                        method: "GET",
                        url: BASE + "/quotations/zones/" + zoneId + "/positions?str=" + encodeURIComponent( term ),
                        callback: {
                            done: ( xhr ) => {
                                this.positionSuggestions = xhr.data || [];
                                this.positionSuggestLoading = false;
                            },
                            fail: () => {
                                this.positionSuggestLoading = false;
                            },
                        },
                    } );
                },

                /**
                 * Seleziona una posizione dai suggerimenti e aggiorna il form.
                 * Imposta il termine di ricerca con il codice della posizione selezionata.
                 * @param {Object} item - Posizione selezionata con proprietà id e code.
                 */
                selectPositionSuggestion: function( item ) {
                    this.detailForm.data.position = item;
                    this.positionSearchTerm = item.code || item.term;
                    this.positionSuggestions = [];
                },

                /**
                 * Sincronizza il campo position con il termine di ricerca digitato.
                 * Se l'utente ha digitato un codice che non corrisponde a nessun suggerimento,
                 * imposta una posizione libera con solo il codice.
                 */
                syncPositionFromSearchTerm: function() {
                    if ( this.positionSearchTerm && ( !this.detailForm.data.position || this.detailForm.data.position.code !== this.positionSearchTerm ) ) {
                        this.detailForm.data.position = { id: "", code: this.positionSearchTerm };
                    }
                },

                // MARK: Pricing
                /**
                 * Calcola e aggiorna il prezzo della placca tramite richiesta al server.
                 * Se il metodo di prezzo è "Fisso", mostra un avviso e non procede.
                 * Invia i dati dell'item, il prezzo corrente e l'ID quotazione.
                 * Applica gli sconti e calcola il totale.
                 * @returns {Promise<boolean>} Promise che restituisce false se il metodo è fisso.
                 */
                updatePricing: async function() {
                    // debugger
                    if ( this.pricing.data.method.id === "F" ) {
                        AP.widget.notify( "warning", "Hai selezionato Prezzo Fisso." );
                        return false;
                    }
                    const item = this.getItemData();
                    const payload = {
                        item: item,
                        price: this.pricing.data,
                        quotationId: AP.page.quotation.id,
                    };
                    AP.loading.show();

                    ajax( {
                        method: "POST",
                        url: BASE + "/quotation-items/type/plate/pricing",
                        data: JSON.stringify( payload ),
                        callback: {
                            done: ( xhr ) => {
                                AP.loading.hide();
                                if ( xhr.data ) {
                                    this.pricing.data = xhr.data;
                                    const actualTotal = xhr.data.totalGoods;
                                    const disc1 = Number.parseFloat( this.pricing.data.discount1 ) || 0;
                                    const disc2 = Number.parseFloat( this.pricing.data.discount2 ) || 0;
                                    const td1 = actualTotal - ( actualTotal * disc1 / 100 );
                                    const td2 = td1 - ( td1 * disc2 / 100 );
                                    this.pricing.data.total = Number( td2 ).toFixed( 2 );
                                }
                            },
                            fail: () => {
                                AP.loading.hide();
                            },
                        },
                    } );
                },

                /**
                 * Gestisce il cambiamento del metodo di prezzo tra "Calcolato" e "Fisso".
                 * In modalità calcolato, azzera il totale e disabilita l'inserimento manuale.
                 * In modalità fisso, azzera sconti e righe e abilita l'inserimento manuale del totale.
                 */
                changePricingMethod: function() {
                    if ( this.pricing.data.method.id === "C" ) {
                        this.pricing.data.total = 0;
                        this.pricing.isTotalEnabled = false;
                    } else {
                        this.pricing.data.discount1 = "";
                        this.pricing.data.discount2 = "";
                        this.pricing.data.lines = [];
                        this.pricing.data.total = 0;
                        this.pricing.isTotalEnabled = true;
                    }
                },

                /**
                 * Formatta un importo numerico nel formato valuta italiano:
                 * punto come separatore delle migliaia, virgola per i decimali,
                 * sempre due cifre decimali.
                 * @param {*} amount - Valore da formattare (numero o stringa numerica).
                 * @returns {string} Importo formattato, o stringa vuota se non valido.
                 */
                formatMoney: function( amount ) {
                    if ( amount === null || amount === undefined || amount === "" ) { return ""; }
                    const num = Number( amount );
                    if ( isNaN( num ) ) { return String( amount ); }
                    return num.toLocaleString( "it-IT", { minimumFractionDigits: 2, maximumFractionDigits: 2 } );
                },

                // MARK: Save
                /**
                 * Salva la placca sul server.
                 * Verifica la presenza di almeno un frutto e, in caso di custom image,
                 * che sia stata selezionata un'immagine.
                 * Prepara i dati includendo posizioni, zone e fruit positions.
                 * Genera un'anteprima tramite html2canvas da inviare come base64.
                 * Al successo, mostra il modale post-salvataggio.
                 * @returns {Promise<boolean>} Promise che restituisce false se le validazioni falliscono.
                 */
                save: async function() {
                    AP.loading.show();

                    if ( !pub.fruitsController?.fruits.length ) {
                        AP.widget.notify( "error", "Devi configurare almeno un frutto per poter procedere." );
                        AP.loading.hide();
                        return false;
                    }

                    if ( this.detailForm.data.id && this.detailForm.data.customImage && !this.backgroundCustomImage.url ) {
                        AP.widget.notify( "error", "Hai scelto custom image, devi selezionare un'immagine prima di salvare." );
                        AP.loading.hide();
                        return false;
                    }

                    const positions = {};
                    pub.fruitsController.fruits.forEach( ( fruit ) => {
                        positions[fruit.id] = fruit.cellIds;
                    } );

                    this.saving = true;

                    let preview = $( "#plate-background" )[0];
                    if ( this.detailForm.data.id && this.detailForm.data.customImage ) {
                        preview = $( "#plate-custom-image" )[0];
                    }

                    const parsedData = {};
                    parsedData.quotationId = AP.page.quotation.id;
                    parsedData.item = this.getItemData();
                    parsedData.isClone = this.detailForm.isClone || false;
                    parsedData.typeId = "plate";
                    parsedData.price = this.pricing.data;

                    if ( this.detailForm.data.quotationSubzoneId ) {
                        let subzoneObj = this.detailForm.data.quotationSubzone;
                        if ( !subzoneObj ) {
                            for ( const subzone of this.subzones ) {
                                if ( subzone.id === this.detailForm.data.quotationSubzoneId ) {
                                    subzoneObj = subzone;
                                    break;
                                }
                            }
                        }
                        parsedData.item.quotationZone = subzoneObj || this.detailForm.data.quotationZone;
                    } else if ( this.detailForm.data.quotationZoneId ) {
                        parsedData.item.quotationZone = this.detailForm.data.quotationZone;
                    }

                    const fruitPositions = {};
                    for ( const f of this.detailForm.data.fruits ) {
                        fruitPositions[f.id] = positions[f.id] || [];
                    }
                    parsedData.positions = fruitPositions;

                    const canvas = await html2canvas( preview, { useCORS: true } );
                    const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                    parsedData.imageBase64 = imgData;

                    await ajax( {
                        method: "POST",
                        url: BASE + "/quotation-items/plate",
                        data: JSON.stringify( parsedData ),
                        callback: {
                            done: ( xhr ) => {
                                this.saving = false;
                                AP.loading.hide();
                                AP.widget.notify( "success", "Placca salvata correttamente." );
                                this.showPostSaveModal( parsedData.quotationId );
                            },
                            fail: () => {
                                this.saving = false;
                                AP.loading.hide();
                            },
                        },
                    } );
                },

                /**
                 * Mostra il modale post-salvataggio per decidere se posizionare
                 * la placca in pianta o rimanere nella pagina corrente.
                 * Se la placca è nuova o sono cambiati zona/quantità, mostra il modale.
                 * Altrimenti reindirizza alla scheda quotazione dopo un breve timeout.
                 * @param {string} parsedQuotationId - Identificativo della quotazione.
                 */
                showPostSaveModal: function( parsedQuotationId ) {
                    const pd = this.detailForm.data;
                    const modal = $( "#posizione-in-pianta-modal" );

                    function handlerSi() {
                        window.location.href = "/manager/quotation-plant-positions/" + AP.page.quotation.id + "?zoneId=" + ( pd.quotationZone ? pd.quotationZone.id : "" );
                    }

                    function handlerNo() {
                        window.location.reload();
                    }

                    modal.find( "#btn-si" ).off( "click" ).on( "click", handlerSi );
                    modal.find( "#btn-no" ).off( "click" ).on( "click", handlerNo );

                    const isNew = plateResponse === undefined || plateResponse === null;
                    let hoCambiatoZona = false;
                    let hoCambiatoQuantita = false;

                    if ( !isNew && plateResponse?.data ) {
                        hoCambiatoZona = pd.quotationZone && plateResponse.data.quotationItem && pd.quotationZone.name !== plateResponse.data.quotationItem.quotationZone.name;
                        hoCambiatoQuantita = pd.quantity !== plateResponse.data.quotationItem.quantity;
                    }

                    if ( isNew || ( ( !pd.id || hoCambiatoZona || hoCambiatoQuantita ) && pd.quotationZone && pd.quotationZone.name !== "Non assegnato" ) ) {
                        modal.modal( "show" );
                        return;
                    }

                    setTimeout( function() {
                        window.location.href = "/manager/quotations/" + parsedQuotationId + "?tab=plate";
                    }, 1000 );
                },

                // MARK: Helpers
                /**
                 * Prepara e restituisce i dati dell'item per l'invio al server.
                 * Copia i dati del form e mappa i frutti con le proprietà essenziali.
                 * @returns {Object} Dati dell'item pronti per la serializzazione.
                 */
                getItemData: function() {
                    const data = { ...this.detailForm.data };
                    data.product = { ...data.product };
                    data.product.items = { _data: data.product.items || [] };
                    data.fruits = {
                        _data: this.detailForm.data.fruits.map( ( f ) => {
                            return {
                                id: f.id,
                                fruitId: f.fruitId,
                                fruit: f.fruit,
                                position: f.position,
                                items: { _data: f.items || [] },
                                positionIds: f.positionIds,
                            };
                        } ),
                    };
                    return data;
                },

                /**
                 * Verifica se le condizioni per il salvataggio sono soddisfatte.
                 * Il salvataggio è abilitato se la quantità è maggiore di zero
                 * e la finitura del prodotto è stata selezionata.
                 */
                checkCanSave: function() {
                    this.detailForm.canSave = this.detailForm.data.quantity > 0 && this.detailForm.data.product.finish.id !== "";
                },

                /**
                 * Resetta i campi di linea, modello e finitura del prodotto nel form.
                 */
                clearForm: function() {
                    this.detailForm.data.product.line.id = "";
                    this.detailForm.data.product.model.id = "";
                    this.detailForm.data.product.finish.id = "";
                },

                /**
                 * Resetta i filtri di linea, modello e finitura.
                 * Cancella le preferenze utente corrispondenti e verifica la possibilità di salvare.
                 */
                clearFilters: function() {
                    this.clearForm();
                    AP.deleteUserPref( "plate.lineId" );
                    AP.deleteUserPref( "plate.modelId" );
                    AP.deleteUserPref( "plate.finishId" );
                    this.checkCanSave();
                },

                /**
                 * Gestisce il cambio di linea selezionata.
                 * Resetta modello, finitura, product items, frutti e la placca.
                 * Svuota il designer e cancella le preferenze utente di modello e finitura.
                 */
                handleLineChange: function() {
                    this.detailForm.data.product.model = { id: "", code: "" };
                    this.detailForm.data.product.finish = { id: "" };
                    this.detailForm.data.product.items = [];
                    this.detailForm.data.fruits = [];
                    this.models = [];
                    this.finishes = [];
                    this.isPlateDefined = false;
                    this.renderPlateWithFruits();
                    AP.deleteUserPref( "plate.modelId" );
                    AP.deleteUserPref( "plate.finishId" );
                },

                /**
                 * Gestisce il cambio di modello selezionato.
                 * Resetta finitura, product items, frutti e la placca.
                 * Svuota il designer e cancella la preferenza utente per la finitura.
                 */
                handleModelChange: function() {
                    this.detailForm.data.product.finish = { id: "" };
                    this.detailForm.data.product.items = [];
                    this.detailForm.data.fruits = [];
                    this.finishes = [];
                    this.isPlateDefined = false;
                    this.renderPlateWithFruits();
                    AP.deleteUserPref( "plate.finishId" );
                },

                /**
                 * Apre la scheda di dettaglio del prodotto corrente in una nuova finestra.
                 */
                goToProduct: function() {
                    const id = this.detailForm.data.product.id;
                    if ( id ) {
                        window.open( "/manager/products/" + id + "/detail", "_blank" );
                    }
                },
            },
        } );

        window.vm.$mount( "#plate-vue-app" );
        window.vm.loadZones();
    }

    /**
     * Apre il modale per la creazione di una nuova placca.
     * Monta l'app Vue, carica linee e zone, applica le preferenze utente
     * e inizializza i campi del form per un nuovo inserimento.
     * @param {Function} [onSave] - Callback opzionale da eseguire dopo il salvataggio.
     */
    pub.new = async function( onSave ) {
        NM.util.openModal( AP.plate.fields.modalRoot );

        await mountVue();

        if ( onSave ) {
            window.vm.detailForm.callback = window.vm.detailForm.callback || {};
            window.vm.detailForm.callback.onSave = onSave;
        }
        await window.vm.loadLines();
        window.vm.resetDetailForm();

        let zoneData = AP.quotation.detail.config().zone;
        if ( !zoneData || zoneData.id === "" ) {
            const nonAss = window.vm.zones.find( ( z ) => { return z.name === "Non assegnato"; } );
            if ( nonAss ) {
                zoneData = nonAss;
            }
        }
        if ( zoneData ) {
            window.vm.detailForm.data.quotationZone = zoneData;
            window.vm.detailForm.data.quotationZoneId = zoneData.id;
        }

        window.vm.isEditMode = false;
        window.vm.detailForm.title = "Carica placca";
        window.vm.detailForm.isClone = false;

        const plateLineId = AP.getUserPref( "plate.lineId" );
        const plateModelId = AP.getUserPref( "plate.modelId" );
        const plateFinishId = AP.getUserPref( "plate.finishId" );

        if ( plateLineId ) {
            const line = window.vm.lines.find( ( l ) => { return l.id == plateLineId; } );
            if ( line ) {
                window.vm.detailForm.data.product.line.id = line.id;
                await window.vm.loadModels();
                if ( plateModelId ) {
                    const model = window.vm.models.find( ( m ) => { return m.id == plateModelId; } );
                    if ( model ) {
                        window.vm.detailForm.data.product.model.id = model.id;
                        await window.vm.loadFinishes();
                        if ( plateFinishId ) {
                            const finish = window.vm.finishes.find( ( f ) => { return f.id == plateFinishId; } );
                            if ( finish ) {
                                window.vm.detailForm.data.product.finish.id = finish.id;
                                await window.vm.loadProduct();
                            }
                        }
                    }
                }
            }
        }

        window.vm.pricing = {
            data: {
                id: "",
                quantity: 1,
                discount1: "",
                discount2: "",
                method: { id: "C", name: "Calcolato" },
                lines: [],
                total: 0,
            },
            priceTypes: [
                { id: "C", name: "Calcolato" },
                { id: "F", name: "Fisso" },
            ],
            isTotalEnabled: false,
        };

        window.vm.positionSearchTerm = "";
        window.vm.fruitSearchTerm = "";

        plateResponse = null;
    };

    /**
     * Apre il modale per la modifica o la clonazione di una placca esistente.
     * Carica i dati della placca dal server, popola il form con i valori esistenti,
     * carica linee, modelli, finiture, product items e frutti.
     * @param {Object} opts - Opzioni per la modifica.
     * @param {string} opts.id - Identificativo della placca da modificare.
     * @param {boolean} [opts.clone=false] - Se true, apre in modalità clonazione.
     * @param {Function} [opts.onSave] - Callback opzionale da eseguire dopo il salvataggio.
     */
    pub.edit = async function( opts ) {
        const id = opts.id;

        NM.util.openModal( AP.plate.fields.modalRoot );

        await new Promise( function( resolve ) { setTimeout( resolve, 100 ); } );
        await mountVue();

        const clone = opts.clone || false;
        const onSave = opts.onSave;

        window.location.hash = "plate/" + id;
        window.vm.resetDetailForm();
        window.vm.isEditMode = true;
        window.vm.detailForm.isClone = clone;
        window.vm.detailForm.title = clone ? "Clona placca" : "Modifica placca";

        plateResponse = await getPlate( id );

        if ( plateResponse.status === "SUCCESS" ) {
            const data = plateResponse.data;
            window.vm.populateProduct( data.quotationItem.product );
            window.vm.detailForm.data.id = data.quotationItem.id;
            window.vm.detailForm.data.position = data.quotationItem.position;
            window.vm.detailForm.data.note = data.quotationItem.note;
            window.vm.detailForm.data.quantity = data.quotationItem.quantity;
            window.vm.detailForm.data.special = data.quotationItem.special === "true";
            window.vm.detailForm.data.customImage = data.quotationItem.customImage === "true";
            window.vm.detailForm.data.plateQuotationItemProductItems = data.quotationItem.items || [];

            const qz = data.quotationItem.quotationZone;
            if ( qz ) {
                if ( qz.origin ) {
                    window.vm.detailForm.data.quotationZone = qz.origin;
                    window.vm.detailForm.data.quotationZoneId = qz.origin.id;
                    window.vm.detailForm.data.quotationSubzone = qz;
                    window.vm.detailForm.data.quotationSubzoneId = qz.id;
                } else {
                    window.vm.detailForm.data.quotationZone = qz;
                    window.vm.detailForm.data.quotationZoneId = qz.id;
                }
            }

            await window.vm.loadBackgroundCustomImage( data.quotationItem.id );

            await window.vm.loadLines();
            await window.vm.loadModels();
            await window.vm.loadFinishes();
            await window.vm.firstLoadProductItems();
            await window.vm.loadPlate( data.quotationItem.frame ? data.quotationItem.frame.orientation : null );
            await window.vm.loadFruits();

            window.vm.positionSearchTerm = data.quotationItem.position ? data.quotationItem.position.code : "";
            window.vm.fruitSearchTerm = "";

            if ( data.quotationItem.price ) {
                window.vm.pricing.data = {  ...window.vm.pricing.data, ...data.quotationItem.price };
                if ( data.quotationItem.price.method ) {
                    window.vm.pricing.data.method = data.quotationItem.price.method;
                }
                window.vm.pricing.isTotalEnabled = data.quotationItem.price.method?.id === "F";
            }
        }

        if ( onSave ) {
            window.vm.detailForm.callback = window.vm.detailForm.callback || {};
            window.vm.detailForm.callback.onSave = onSave;
        }

        AP.loading.hide();
    };

    /**
     * Restituisce i dati correnti del form di dettaglio della placca.
     * @returns {Object|null} Dati del form o null se l'istanza Vue non è montata.
     */
    pub.getItem = function() {
        return window.vm ? window.vm.detailForm.data : null;
    };

    /**
     * Apre il modale in modalità clonazione per una placca esistente.
     * @param {Object} opts - Opzioni per la clonazione.
     * @param {string} opts.id - Identificativo della placca da clonare.
     */
    pub.clone = function( opts ) {
        pub.edit( { id: opts.id, clone: true } );
    };

    return pub;
} () );
