AP.namespace( "plateBuilder" );

/**
 * Builder delle placche (frames) a blocchi di slot.
 *
 * Una placca è composta da blocchi; ogni blocco ha un numero di slot
 * (mezzifrutti), margini TOP/LEFT in millimetri rispetto all'angolo
 * top-left della placca e una modalità di orientamento:
 *  - HAV: il blocco segue l'orientamento della placca
 *  - HOR / VER: il blocco resta sempre nell'orientamento indicato
 *
 * Gli slot sono numerati con interi progressivi (1..N) per placca,
 * uguali in orizzontale e verticale: ruotando la placca i frutti
 * restano associati alle stesse posizioni.
 *
 * Scala di disegno: 1 mm = 1 px (slot 45x180).
 */
AP.plateBuilder = ( function() {

    const BASE = "/manager/ajax";

    const SLOT_WIDTH_MM = 45;
    const SLOT_HEIGHT_MM = 180;

    const ORIENTATION_MODES = [
        { id: "HAV", name: "Segue la placca" },
        { id: "HOR", name: "Fisso orizzontale" },
        { id: "VER", name: "Fisso verticale" },
    ];

    /** Larghezza massima dell'anteprima in px, oltre la quale si riduce la scala. */
    const PREVIEW_MAX_WIDTH = 1000;

    const pub = {};

    function emptyForm() {
        return {
            id: "",
            code: "",
            name: "",
            status: { id: "ACT" },
            orientation: { id: "HAV" },
            marginRightMm: 0,
            marginBottomMm: 0,
            blocks: [],
            legacy: false,
        };
    }

    function emptyBlock() {
        return {
            _key: NM.util.uuid(),
            slotCount: 1,
            marginTopMm: 0,
            marginLeftMm: 0,
            orientationMode: "HAV",
            rotatable: false,
        };
    }

    /**
     * Calcola il layout della placca per l'orientamento richiesto.
     * Replica la logica server di FrameAjaxController.buildBlocksResponse():
     * i blocchi scorrono lungo l'asse della placca (orizzontale in HOR,
     * verticale in VER). Lungo l'asse di flusso il margine è riferito al
     * blocco precedente (LEFT con placca orizzontale, TOP con placca
     * verticale; per il primo blocco al bordo della placca); l'altro
     * margine è sempre riferito al bordo della placca.
     *
     * @param {Array} blocks - blocchi del form ({slotCount, marginTopMm, marginLeftMm, orientationMode})
     * @param {string} frameOrientationId - orientamento della placca (HAV/HOR/VER)
     * @param {string} requestedOrientationId - orientamento da visualizzare (HOR/VER)
     * @param {number} [marginRightMm=0] - margine finale destro della placca in mm
     * @param {number} [marginBottomMm=0] - margine finale inferiore della placca in mm
     * @returns {{width: number, height: number, blocks: Array}}
     */
    function computeLayout( blocks, frameOrientationId, requestedOrientationId, marginRightMm, marginBottomMm ) {
        let requested = requestedOrientationId || ( frameOrientationId === "VER" ? "VER" : "HOR" );
        if ( frameOrientationId !== "HAV" ) {
            requested = frameOrientationId === "VER" ? "VER" : "HOR";
        }

        let slotCounter = 0;
        let flowCursor = 0; // bordo finale (destro o inferiore) del blocco precedente
        let plateWidth = 0;
        let plateHeight = 0;
        const layoutBlocks = [];

        for ( const block of blocks ) {
            const slotCount = Math.max( 1, parseInt( block.slotCount, 10 ) || 1 );
            const mode = block.orientationMode || "HAV";
            const effectiveOrientation = mode === "HAV" ? requested : mode;

            const marginTop = Number( block.marginTopMm ) || 0;
            const marginLeft = Number( block.marginLeftMm ) || 0;

            let width, height;
            if ( effectiveOrientation === "HOR" ) {
                width = slotCount * SLOT_WIDTH_MM;
                height = SLOT_HEIGHT_MM;
            } else {
                width = SLOT_HEIGHT_MM;
                height = slotCount * SLOT_WIDTH_MM;
            }

            let left, top;
            if ( requested === "HOR" ) {
                left = flowCursor + marginLeft;
                top = marginTop;
                flowCursor = left + width;
            } else {
                top = flowCursor + marginTop;
                left = marginLeft;
                flowCursor = top + height;
            }

            const slots = [];
            for ( let i = 0; i < slotCount; i++ ) {
                slotCounter++;
                slots.push( { id: slotCounter, order: slotCounter - 1 } );
            }

            layoutBlocks.push( {
                _key: block._key,
                orientationMode: mode,
                rotatable: !!block.rotatable,
                cellOrientation: effectiveOrientation,
                left: left,
                top: top,
                width: width,
                height: height,
                slots: slots,
            } );

            plateWidth = Math.max( plateWidth, left + width );
            plateHeight = Math.max( plateHeight, top + height );
        }

        // dimensioni dei singoli slot per il rendering
        for ( const block of layoutBlocks ) {
            const slotWidth = block.cellOrientation === "HOR" ? SLOT_WIDTH_MM : SLOT_HEIGHT_MM;
            const slotHeight = block.cellOrientation === "HOR" ? SLOT_HEIGHT_MM : SLOT_WIDTH_MM;

            block.slots = block.slots.map( ( slot ) => {
                return { ...slot, width: slotWidth, height: slotHeight };
            } );
        }

        plateWidth  += Number( marginRightMm )  || 0;
        plateHeight += Number( marginBottomMm ) || 0;

        return { width: plateWidth, height: plateHeight, blocks: layoutBlocks };
    }

    /**
     * Ricava i blocchi da una griglia legacy (file grid_*.json.cfm):
     * ogni sequenza consecutiva di celle "_" in una riga diventa un blocco.
     * I margini restano 0 e vanno rifiniti a mano.
     */
    function blocksFromLegacyGrid( grid ) {
        const blocks = [];

        for ( const row of grid ) {
            let runLength = 0;

            for ( const cell of row ) {
                if ( cell.type === "_" ) {
                    runLength++;
                } else if ( runLength ) {
                    blocks.push( { ...emptyBlock(), slotCount: runLength } );
                    runLength = 0;
                }
            }

            if ( runLength ) {
                blocks.push( { ...emptyBlock(), slotCount: runLength } );
            }
        }

        return blocks;
    }

    const vm = new Vue( {
        el: "#plate-builder-app",

        data: {
            view: "list",
            loading: false,
            saving: false,

            frames: [],
            filters: {
                str: "",
                orientationId: "",
                statusId: "",
            },

            statuses: AP.page.statuses || [],
            orientations: AP.page.orientations || [],
            orientationModes: ORIENTATION_MODES,

            form: emptyForm(),
            codeError: "",

            previewOrientation: "HOR",
        },

        computed: {
            previewLayout: function() {
                return computeLayout(
                    this.form.blocks,
                    this.form.orientation.id,
                    this.previewOrientation,
                    this.form.marginRightMm,
                    this.form.marginBottomMm
                );
            },

            previewScale: function() {
                if ( !this.previewLayout.width ) {
                    return 1;
                }
                return Math.min( 1, PREVIEW_MAX_WIDTH / this.previewLayout.width );
            },

            previewScalePercent: function() {
                return Math.round( this.previewScale * 100 );
            },
        },

        mounted: function() {
            this.search();
        },

        methods: {
            // MARK: elenco
            search: function() {
                this.loading = true;

                const params = new URLSearchParams();
                params.set( "limit", "500" );
                if ( this.filters.str ) { params.set( "str", this.filters.str ); }
                if ( this.filters.orientationId ) { params.set( "orientationId", this.filters.orientationId ); }
                if ( this.filters.statusId ) { params.set( "statusId", this.filters.statusId ); }

                NM.util.ajax( {
                    method: "GET",
                    url: BASE + "/frames?" + params.toString(),
                    callback: {
                        done: ( xhr ) => {
                            this.frames = xhr.data || [];
                            this.loading = false;
                        },
                        fail: () => {
                            this.loading = false;
                        },
                    },
                } );
            },

            newFrame: function() {
                this.form = emptyForm();
                this.form.blocks.push( emptyBlock() );
                this.codeError = "";
                this.previewOrientation = "HOR";
                this.view = "edit";
            },

            editFrame: function( frameId ) {
                NM.util.ajax( {
                    method: "GET",
                    url: BASE + "/frames/" + frameId,
                    callback: {
                        done: ( xhr ) => {
                            const data = xhr.data;
                            const form = emptyForm();

                            form.id = data.id;
                            form.code = data.code;
                            form.name = data.name || "";
                            form.status = { id: data.status ? data.status.id : "ACT" };
                            form.marginRightMm  = Number( data.marginRightMm )  || 0;
                            form.marginBottomMm = Number( data.marginBottomMm ) || 0;

                            // l'orientamento della placca (HAV/HOR/VER): in risposta
                            // orientation è quello corrente, availableOrientations dice se è HAV
                            if ( ( data.availableOrientations || [] ).length > 1 ) {
                                form.orientation = { id: "HAV" };
                            } else {
                                form.orientation = { id: data.orientation.id };
                            }

                            if ( ( data.blocks || [] ).length ) {
                                form.blocks = data.blocks.map( ( block ) => {
                                    return {
                                        _key: NM.util.uuid(),
                                        slotCount: block.slotCount,
                                        marginTopMm: Number( block.marginTopMm ) || 0,
                                        marginLeftMm: Number( block.marginLeftMm ) || 0,
                                        orientationMode: block.orientationMode || "HAV",
                                        rotatable: !!block.rotatable,
                                    };
                                } );
                            } else if ( ( data.grid || [] ).length ) {
                                // placca legacy su file: proponi i blocchi ricavati dalla griglia
                                form.blocks = blocksFromLegacyGrid( data.grid );
                                form.legacy = true;
                            }

                            this.form = form;
                            this.codeError = "";
                            this.previewOrientation = form.orientation.id === "VER" ? "VER" : "HOR";
                            this.view = "edit";
                        },
                    },
                } );
            },

            deleteFrame: function( frame ) {
                if ( !confirm( "Eliminare la placca " + frame.code + ( frame.name ? " (" + frame.name + ")" : "" ) + "?" ) ) {
                    return;
                }

                NM.util.ajax( {
                    method: "DELETE",
                    url: BASE + "/frames",
                    data: frame.id,
                    callback: {
                        done: ( xhr ) => {
                            const payload = xhr.data && xhr.data.payload;
                            if ( payload && payload.errors && payload.errors.length ) {
                                AP.widget.notify( "error", "Impossibile eliminare la placca: potrebbe essere in uso." );
                            } else {
                                AP.widget.notify( "success", "Placca eliminata." );
                            }
                            this.search();
                        },
                    },
                } );
            },

            backToList: function() {
                this.view = "list";
                this.search();
            },

            // MARK: blocchi
            addBlock: function() {
                this.form.blocks.push( emptyBlock() );
            },

            removeBlock: function( index ) {
                this.form.blocks.splice( index, 1 );
            },

            moveBlock: function( index, direction ) {
                const target = index + direction;
                if ( target < 0 || target >= this.form.blocks.length ) {
                    return;
                }
                const blocks = this.form.blocks;
                const tmp = blocks[ target ];
                this.$set( blocks, target, blocks[ index ] );
                this.$set( blocks, index, tmp );
            },

            /** Etichetta "slot 1-4" per la riga del blocco nell'editor. */
            blockSlotRange: function( index ) {
                let first = 1;
                for ( let i = 0; i < index; i++ ) {
                    first += Math.max( 1, parseInt( this.form.blocks[ i ].slotCount, 10 ) || 1 );
                }
                const count = Math.max( 1, parseInt( this.form.blocks[ index ].slotCount, 10 ) || 1 );
                const last = first + count - 1;
                return count === 1 ? "slot " + first : "slot " + first + " - " + last;
            },

            // MARK: validazione / salvataggio
            checkCode: function() {
                this.codeError = "";

                if ( !this.form.code ) {
                    return;
                }

                if ( this.form.code.length < 2 ) {
                    this.codeError = "Il codice deve avere almeno 2 caratteri.";
                    return;
                }

                NM.util.ajax( {
                    method: "GET",
                    url: BASE + "/frames/code-exists?code=" + encodeURIComponent( this.form.code ) + "&id=" + ( this.form.id || "_" ),
                    callback: {
                        done: ( xhr ) => {
                            if ( xhr.data === true ) {
                                this.codeError = "Codice già in uso da un'altra placca.";
                            }
                        },
                    },
                } );
            },

            validate: function() {
                const errors = [];

                if ( !this.form.name ) { errors.push( "Il nome è obbligatorio." ); }
                if ( !this.form.code || this.form.code.length < 2 ) { errors.push( "Il codice è obbligatorio (2-5 caratteri)." ); }
                if ( this.codeError ) { errors.push( this.codeError ); }
                if ( !this.form.blocks.length ) { errors.push( "Aggiungi almeno un blocco di slot." ); }

                this.form.blocks.forEach( ( block, index ) => {
                    if ( !block.slotCount || block.slotCount < 1 ) {
                        errors.push( "Blocco " + ( index + 1 ) + ": numero di slot non valido." );
                    }
                    if ( block.marginTopMm < 0 || block.marginLeftMm < 0 ) {
                        errors.push( "Blocco " + ( index + 1 ) + ": i margini non possono essere negativi." );
                    }
                } );

                return errors;
            },

            saveFrame: function() {
                const errors = this.validate();
                if ( errors.length ) {
                    AP.widget.notify( "error", errors.join( "<br>" ) );
                    return;
                }

                this.saving = true;

                const payload = {
                    id: this.form.id,
                    code: this.form.code,
                    name: this.form.name,
                    status: { id: this.form.status.id },
                    orientation: { id: this.form.orientation.id },
                    marginRightMm: this.form.marginRightMm || 0,
                    marginBottomMm: this.form.marginBottomMm || 0,
                    blocks: this.form.blocks.map( ( block, index ) => {
                        return {
                            order: index,
                            slotCount: block.slotCount,
                            marginTopMm: block.marginTopMm || 0,
                            marginLeftMm: block.marginLeftMm || 0,
                            orientationMode: block.orientationMode,
                            rotatable: !!block.rotatable,
                        };
                    } ),
                };

                NM.util.ajax( {
                    method: "POST",
                    url: BASE + "/frames",
                    data: JSON.stringify( payload ),
                    callback: {
                        done: ( xhr ) => {
                            this.saving = false;

                            if ( xhr.status == "INVALID" ) {
                                NM.form.showMessages( xhr.data );
                                return;
                            }

                            AP.widget.notify( "success", "Placca salvata." );
                            this.backToList();
                        },
                        fail: () => {
                            this.saving = false;
                            AP.widget.notify( "error", "Errore durante il salvataggio della placca." );
                        },
                    },
                } );
            },
        },
    } );

    pub.vm = vm;
    pub.computeLayout = computeLayout;

    return pub;

} )();
