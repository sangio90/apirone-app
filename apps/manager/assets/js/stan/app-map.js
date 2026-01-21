AP.plate = AP.plate || {};

AP.plate.fields = {
    designerRoot: $( "#plate-designer-root" ),
    mapRoot: $( "#plates-map-root" ),
};


$( document ).ready( function() {

    if ( AP.plate.fields.mapRoot.length ) {
        AP.plate.map.init( {
            container: AP.plate.fields.mapRoot,
        } );
    }
} );

AP.plate.map = ( function() {
    const { MarkerArea, CustomImageMarker, ImageMarkerEditor } = markerjs3;

    // Seguendo la guida: https://markerjs.com/docs-v3/documents/guides_and_tutorials.tutorials.custom_marker_types
    // Estendo CustomImageMarker per sapere quale PlateMarker appartiene a quale Plate
    class PlateMarker extends CustomImageMarker {
        static typeName = "PlateMarker";
        static title = "Plate marker";

        #plateUUID = "";

        get plateUUID() {
            return this.#plateUUID;
        }

        set plateUUID( value ) {
            this.#plateUUID = value;
        }

        constructor( container ) {
            super( container );
        }

        getState() {
            const result = Object.assign(
                {
                    plateUUID: this.plateUUID,
                },
                super.getState(),
            );

            return result;
        }

        restoreState( state ) {
            const plateMarkerState = state;

            if ( plateMarkerState.plateUUID !== undefined ) {
                this.plateUUID = plateMarkerState.plateUUID;
            }

            super.restoreState( state );
        }
    }

    const pub = {};
    const priv = {
        container: null,
        markerArea: null,
    };

    priv.vm = new kendo.data.ObservableObject( {
        // DATA
        plates: [],
        selectedPlate: null,
        selectedPlateMarkersQuantity: 0,
        // CONDITIONS
        isEnabledUndo: false,
        isEnabledRedo: false,
        isEnabledRemoveMarker: false,
        isEnabledAddMarker() {
            return this.get( "selectedPlateMarkersQuantity" ) > 0;
        },
        // ACTIONS
        updateUndoRedoButtons( event ) {
            this.set( "isEnabledUndo", priv.markerArea.isUndoPossible );
            this.set( "isEnabledRedo", priv.markerArea.isRedoPossible );
        },
        updateRemoveMarkerButton( event ) {
            this.set( "isEnabledRemoveMarker", priv.markerArea.selectedMarkerEditors.length > 0 );
        },
        updatePlateMarkersQuantity( event ) {
            const plate = this.plates.find( x => x.uuid == event.detail.markerEditor.marker.plateUUID );
            const selectedPlate = this.get( "selectedPlate" );

            if ( plate ) {
                const oldQuantity = plate.get( "availableQuantity" );

                let newQuantity = oldQuantity;

                if ( event.type == "markerdelete" ) {
                    newQuantity = oldQuantity + 1;
                } else if ( event.type == "markercreate" ) {
                    if ( oldQuantity > 0 ) {
                        newQuantity = oldQuantity - 1;
                    }
                }

                if ( newQuantity != oldQuantity ) {
                    plate.set( "availableQuantity", newQuantity );

                    if ( selectedPlate === plate ) {
                        this.set( "selectedPlateMarkersQuantity", newQuantity );
                    }
                }
            }
        },
        postUndoRedo() {
            const selectedPlate = this.get( "selectedPlate" );
            const plateAvailableQuantitiesMap = new Map();

            for ( const plate of this.get( "plates" ) ) {
                plate.set( "availableQuantity", plate.totalQuantity );

                plateAvailableQuantitiesMap.set( plate.uuid, plate.availableQuantity );
            }

            for ( const editor of priv.markerArea.editors ) {
                const currentPlateAvailableQuantity = plateAvailableQuantitiesMap.get( editor.marker.plateUUID );

                plateAvailableQuantitiesMap.set( editor.marker.plateUUID, currentPlateAvailableQuantity - 1 );
            }

            for ( const plate of this.get( "plates" ) ) {
                const newQuantity = plateAvailableQuantitiesMap.get( plate.uuid );

                plate.set( "availableQuantity", newQuantity );

                if ( selectedPlate === plate ) {
                    this.set( "selectedPlateMarkersQuantity", newQuantity );
                }
            }
        },
        // GETTERS
        getSelectedPlateMarkerImg( event ) {
            let result = "../../../../assets/main/img/red_pin.png";

            const selectedPlate = this.get( "selectedPlate" );

            if ( selectedPlate != null ) {
                result = selectedPlate.marker.img;
            }

            return result;
        },
        // EVENTS
        onClickAddMarker( event ) {
            const selectedPlate = this.get( "selectedPlate" );

            if ( selectedPlate != null ) {
                const markerEditor = priv.markerArea.createMarker( PlateMarker );

                markerEditor.marker.plateUUID = selectedPlate.uuid;
                markerEditor.marker.defaultSize = selectedPlate.marker.size;
                markerEditor.marker.imageSrc = selectedPlate.marker.img;
            }
        },
        onClickRemoveMarker( event ) {
            priv.markerArea.deleteSelectedMarkers();
        },
        onClickUndo( event ) {
            if ( priv.markerArea.isUndoPossible ) {
                priv.markerArea.undo();

                this.postUndoRedo();
            }
        },
        onClickRedo( event ) {
            if ( priv.markerArea.isRedoPossible ) {
                priv.markerArea.redo();

                this.postUndoRedo();
            }
        },
        onClickZoomIn( event ) {
            priv.markerArea.zoomLevel += 0.1;
        },
        onClickZoomOut( event ) {
            if ( priv.markerArea.zoomLevel > 0.2 ) {
                priv.markerArea.zoomLevel -= 0.1;
            }
        },
        onClickZoomReset( event ) {
            priv.markerArea.zoomLevel = 1;
        },
        onClickExport( event ) {
            priv.state = JSON.stringify( priv.markerArea.getState() );
        },
        onClickImport( event ) {
            priv.markerArea.restoreState( JSON.parse( priv.state ) );
        },
        onSelectPlate( event ) {
            this.set( "selectedPlateMarkersQuantity", event.dataItem.availableQuantity );
        },
        // INITS
    } );

    pub.init = function( setup ) {

        console.log( "map:init" );

        priv.container = setup.container;

        priv.vm.set( "plates", pageData.plates );

        kendo.bind( setup.container, priv.vm );

        priv.targetImg = document.createElement( "img" );
        priv.targetImg.src = pageData.platesMap.img;

        const platesMap = document.querySelector( ".plates-map-body" );

        priv.markerArea = new MarkerArea();
        priv.markerArea.registerMarkerType( PlateMarker, ImageMarkerEditor );
        priv.markerArea.targetImage = priv.targetImg;
        platesMap.appendChild( priv.markerArea );

        priv.markerArea.addEventListener( "areastatechange", priv.vm.updateUndoRedoButtons.bind( priv.vm ) );

        priv.markerArea.addEventListener( "markerdelete", priv.vm.updateRemoveMarkerButton.bind( priv.vm ) );
        priv.markerArea.addEventListener( "markerselect", priv.vm.updateRemoveMarkerButton.bind( priv.vm ) );
        priv.markerArea.addEventListener( "markerdeselect", priv.vm.updateRemoveMarkerButton.bind( priv.vm ) );

        priv.markerArea.addEventListener( "markerdelete", priv.vm.updatePlateMarkersQuantity.bind( priv.vm ) );
        priv.markerArea.addEventListener( "markercreate", priv.vm.updatePlateMarkersQuantity.bind( priv.vm ) );
    };

    return pub;
}() );