/*
 * Griglia incisioni di un frutto (tab "Griglia incisioni" della scheda prodotto).
 *
 * Per ogni attributo radice dell'incisione (IS, II, IL) mostra l'immagine orizzontale del
 * frutto con i marker: ogni marker è il centro di un'incisione ammessa, trascinabile con
 * il mouse, con le coordinate in px dell'immagine e in mm mostrate in tempo reale. Le stesse
 * coordinate sono modificabili a mano nella tabella a fianco (px e mm restano allineati).
 * Le coordinate sono relative all'angolo in alto a sinistra dell'immagine; la scala px/mm
 * viene dall'immagine stessa e dai moduli del frutto (11,25 × 45 mm per modulo), quindi
 * non dipende da come è visualizzata a video.
 *
 * Dati: AP.page.engraving = { attributes: [{ id, code, name }], rootCodes, positionCount,
 * image: { uri, width, height }, canEdit }. I marker si leggono e si salvano con
 * /ajax/products/:id/engraving-markers (vedi ProductEngravingMarkerAjaxController).
 */
AP.namespace( "productEngravings" );

$( document ).ready( function() {
    if ( $( "#product-engravings" ).length && AP.page.engraving ) {
        AP.productEngravings.init();
    }
} );

AP.productEngravings = ( function() {

    var pub = {};

    var MODULE_MM = { width: 11.25, height: 45 };

    // larghezza massima a video: l'immagine originale è piccola (4 px/mm), la si ingrandisce
    // per lavorarci comodi senza toccare le coordinate salvate (sempre in px dell'originale)
    var MAX_DISPLAY_WIDTH  = 720;
    var MAX_DISPLAY_HEIGHT = 520;
    var MIN_DISPLAY_SCALE  = 1;

    var cfg    = null;
    var blocks = {}; // attributeId -> { attribute, markers, $stage, $img, $coords, displayScale, dirty }

    var esc = function( str ) {
        return $( "<div>" ).text( str == null ? "" : String( str ) ).html();
    };

    var round2 = function( n ) {
        return Math.round( n * 100 ) / 100;
    };

    var pxPerMm = function( block ) {
        var img = block.$img[ 0 ];
        var widthMm = MODULE_MM.width * ( cfg.positionCount || 1 );
        return img.naturalWidth / widthMm;
    };

    var toMm = function( block, px ) {
        return round2( px / pxPerMm( block ) );
    };

    var url = function( attributeId ) {
        return "/manager/ajax/products/" + AP.page.productId + "/engraving-markers" + ( attributeId ? "/" + attributeId : "" );
    };

    // ---- rendering ---------------------------------------------------------------

    var renderBlocks = function( attributes ) {
        var $root = $( "#product-engravings-blocks" ).empty();

        // senza un'immagine del frutto (prodotto o product item) si lavora sul placeholder
        // generico: la scala px/mm resta corretta perché si basa sulla larghezza dell'immagine
        if ( !cfg.image || !cfg.image.uri ) {
            cfg.image = { uri: "/assets/main/img/fruit-generic.png", generic: true };
            $root.append( '<div class="alert alert-warning py-2">Il frutto non ha un\'immagine orizzontale: la griglia viene disegnata sul placeholder generico.</div>' );
        }

        attributes.forEach( function( attribute ) {
            var $block = $(
                '<div class="engraving-block" data-attribute-id="' + esc( attribute.id ) + '">'
                + '<div class="d-flex align-items-center mb-2">'
                + '<h5 class="mb-0 me-3">' + esc( attribute.name ) + ' <small class="text-muted">(' + esc( attribute.code ) + ')</small></h5>'
                + ( cfg.canEdit ? '<button type="button" class="btn btn-primary btn-sm me-2 engraving-add"><i class="fas fa-plus"></i> Aggiungi marker a griglia</button>'
                + '<button type="button" class="btn btn-success btn-sm engraving-save" disabled><i class="fas fa-save"></i> Salva griglia</button>' : '' )
                + '<span class="ms-3 small text-muted engraving-status"></span>'
                + '</div>'
                + '<div class="row"><div class="col-lg-7"><div class="engraving-stage">'
                + '<img src="' + esc( cfg.image.uri ) + '" alt="">'
                + '<div class="engraving-coords" style="display:none"></div>'
                + '</div></div>'
                + '<div class="col-lg-5"><table class="table table-sm engraving-list"><thead><tr><th>N.</th><th>x px</th><th>y px</th><th>x mm</th><th>y mm</th><th></th></tr></thead><tbody></tbody></table></div></div>'
                + '</div>'
            );
            $root.append( $block );

            var block = {
                attribute:    attribute,
                markers:      ( attribute.markers || [] ).map( function( m ) { return { order: m.order, xPx: Number( m.xPx ), yPx: Number( m.yPx ), xMm: Number( m.xMm ), yMm: Number( m.yMm ) }; } ),
                $block:       $block,
                $stage:       $block.find( ".engraving-stage" ),
                $img:         $block.find( "img" ),
                $coords:      $block.find( ".engraving-coords" ),
                $list:        $block.find( "tbody" ),
                displayScale: 1,
                dirty:        false
            };
            blocks[ attribute.id ] = block;

            block.$img.on( "load", function() { layoutBlock( block ); } );
            if ( block.$img[ 0 ].complete ) { layoutBlock( block ); }

            $block.find( ".engraving-add" ).on( "click", function() { addMarker( block ); } );
            $block.find( ".engraving-save" ).on( "click", function() { saveBlock( block ); } );
        } );
    };

    // scala di visualizzazione e primo disegno dei marker, quando l'immagine ha le misure
    var layoutBlock = function( block ) {
        var img = block.$img[ 0 ];
        if ( !img.naturalWidth ) { return; }

        var scale = Math.max( MIN_DISPLAY_SCALE, Math.min( MAX_DISPLAY_WIDTH / img.naturalWidth, MAX_DISPLAY_HEIGHT / img.naturalHeight, 8 ) );
        block.displayScale = scale;
        block.$img.css( { width: Math.round( img.naturalWidth * scale ) + "px", height: Math.round( img.naturalHeight * scale ) + "px" } );

        drawMarkers( block );
    };

    var drawMarkers = function( block ) {
        block.$stage.find( ".engraving-marker" ).remove();

        block.markers.forEach( function( marker, index ) {
            marker.order = index + 1;
            var $m = $( '<div class="engraving-marker" title="Trascina per spostare"><span class="engraving-marker-order">' + marker.order + '</span></div>' );
            $m.data( "index", index );
            positionMarker( block, $m, marker );
            if ( cfg.canEdit ) { bindDrag( block, $m ); }
            block.$stage.append( $m );
        } );

        drawList( block );
    };

    var markerElement = function( block, index ) {
        return block.$stage.find( ".engraving-marker" ).eq( index );
    };

    var positionMarker = function( block, $m, marker ) {
        $m.css( { left: Math.round( marker.xPx * block.displayScale ) + "px", top: Math.round( marker.yPx * block.displayScale ) + "px" } );
    };

    var cell = function( marker, field, step ) {
        if ( !cfg.canEdit ) {
            return '<td>' + marker[ field ] + '</td>';
        }
        return '<td><input type="number" class="form-control form-control-sm engraving-input" data-field="' + field + '"'
            + ' step="' + step + '" min="0" value="' + marker[ field ] + '"></td>';
    };

    var drawList = function( block ) {
        block.$list.empty();
        block.markers.forEach( function( marker, index ) {
            block.$list.append(
                '<tr data-index="' + index + '"><td class="engraving-order">' + marker.order + '</td>'
                + cell( marker, "xPx", 1 ) + cell( marker, "yPx", 1 )
                + cell( marker, "xMm", 0.25 ) + cell( marker, "yMm", 0.25 )
                + '<td>' + ( cfg.canEdit ? '<a href="#" class="text-danger engraving-delete" title="Elimina marker"><i class="fas fa-trash"></i></a>' : '' ) + '</td></tr>'
            );
        } );
        block.$list.find( ".engraving-delete" ).on( "click", function( e ) {
            e.preventDefault();
            var index = Number( $( this ).closest( "tr" ).data( "index" ) );
            block.markers.splice( index, 1 );
            setDirty( block, true );
            drawMarkers( block );
        } );
        bindInputs( block );
    };

    /**
     * Scrive una coordinata digitata sul marker tenendo allineata l'altra unità: px e mm
     * sono la stessa posizione espressa in modo diverso, quindi cambiandone una si ricalcola
     * l'altra. Il valore viene limitato ai bordi dell'immagine.
     * #returns {boolean} false se il testo non è (ancora) un numero, es. campo in scrittura
     */
    var applyField = function( block, marker, field, rawValue ) {
        var value = parseFloat( String( rawValue ).replace( ",", "." ) );
        if ( !isFinite( value ) ) { return false; }

        var img   = block.$img[ 0 ];
        var scale = pxPerMm( block );

        if ( field === "xPx" || field === "yPx" ) {
            var maxPx = ( field === "xPx" ? img.naturalWidth : img.naturalHeight );
            marker[ field ] = Math.max( 0, Math.min( round2( value ), maxPx ) );
            marker[ field === "xPx" ? "xMm" : "yMm" ] = round2( marker[ field ] / scale );
        } else {
            var maxMm = round2( ( field === "xMm" ? img.naturalWidth : img.naturalHeight ) / scale );
            marker[ field ] = Math.max( 0, Math.min( round2( value ), maxMm ) );
            marker[ field === "xMm" ? "xPx" : "yPx" ] = round2( marker[ field ] * scale );
        }

        return true;
    };

    // riallinea gli altri campi della riga senza toccare quello in cui si sta scrivendo
    var syncRow = function( $row, marker, $editing ) {
        $row.find( ".engraving-input" ).each( function() {
            var $input = $( this );
            if ( $editing && $input.is( $editing ) ) { return; }
            $input.val( marker[ $input.data( "field" ) ] );
        } );
    };

    var bindInputs = function( block ) {
        block.$list.find( ".engraving-input" )
            .on( "focus", function() {
                var index  = Number( $( this ).closest( "tr" ).data( "index" ) );
                var marker = block.markers[ index ];
                if ( !marker ) { return; }
                block.$stage.find( ".engraving-marker" ).removeClass( "is-selected" );
                markerElement( block, index ).addClass( "is-selected" );
                showCoords( block, marker );
            } )
            .on( "input", function() {
                var $input = $( this );
                var $row   = $input.closest( "tr" );
                var index  = Number( $row.data( "index" ) );
                var marker = block.markers[ index ];

                if ( !marker || !applyField( block, marker, $input.data( "field" ), $input.val() ) ) { return; }

                syncRow( $row, marker, $input );
                positionMarker( block, markerElement( block, index ), marker );
                showCoords( block, marker );
                setDirty( block, true );
            } )
            .on( "change blur", function() {
                // rimette a posto il campo dopo arrotondamento o limite (o se lasciato vuoto)
                var $input = $( this );
                var index  = Number( $input.closest( "tr" ).data( "index" ) );
                var marker = block.markers[ index ];
                if ( marker ) { $input.val( marker[ $input.data( "field" ) ] ); }
            } )
            .on( "keydown", function( e ) {
                if ( e.key === "Enter" ) {
                    e.preventDefault();
                    $( this ).trigger( "change" );
                }
            } );
    };

    var showCoords = function( block, marker ) {
        block.$coords.show().html( "x " + marker.xPx + " px, y " + marker.yPx + " px<br>x " + marker.xMm + " mm, y " + marker.yMm + " mm" );
    };

    var setDirty = function( block, dirty ) {
        block.dirty = dirty;
        block.$block.find( ".engraving-save" ).prop( "disabled", !dirty );
        block.$block.find( ".engraving-status" ).text( dirty ? "Modifiche non salvate" : "" );
    };

    // ---- azioni ------------------------------------------------------------------

    var addMarker = function( block ) {
        var img = block.$img[ 0 ];
        if ( !img.naturalWidth ) { return; }
        var xPx = round2( img.naturalWidth / 2 );
        var yPx = round2( img.naturalHeight / 2 );
        block.markers.push( { order: block.markers.length + 1, xPx: xPx, yPx: yPx, xMm: toMm( block, xPx ), yMm: toMm( block, yPx ) } );
        setDirty( block, true );
        drawMarkers( block );
        showCoords( block, block.markers[ block.markers.length - 1 ] );
    };

    // Trascinamento con eventi pointer: il marker segue il mouse dentro l'immagine e le
    // coordinate (px originali e mm) si aggiornano a ogni movimento.
    var bindDrag = function( block, $m ) {
        $m.on( "pointerdown", function( e ) {
            if ( e.button !== 0 ) { return; }
            e.preventDefault();

            var index  = Number( $m.data( "index" ) );
            var marker = block.markers[ index ];
            var img    = block.$img[ 0 ];
            var rect   = block.$stage[ 0 ].getBoundingClientRect();

            $m.addClass( "is-dragging" );
            block.$stage.find( ".engraving-marker" ).removeClass( "is-selected" );
            $m.addClass( "is-selected" );
            showCoords( block, marker );

            var onMove = function( ev ) {
                var displayX = Math.max( 0, Math.min( rect.width,  ev.clientX - rect.left ) );
                var displayY = Math.max( 0, Math.min( rect.height, ev.clientY - rect.top ) );
                marker.xPx = round2( displayX / block.displayScale );
                marker.yPx = round2( displayY / block.displayScale );
                marker.xPx = Math.min( marker.xPx, img.naturalWidth );
                marker.yPx = Math.min( marker.yPx, img.naturalHeight );
                marker.xMm = toMm( block, marker.xPx );
                marker.yMm = toMm( block, marker.yPx );
                positionMarker( block, $m, marker );
                showCoords( block, marker );
            };

            var onUp = function() {
                $( document ).off( "pointermove", onMove ).off( "pointerup pointercancel", onUp );
                $m.removeClass( "is-dragging" );
                setDirty( block, true );
                drawList( block );
            };

            $( document ).on( "pointermove", onMove ).on( "pointerup pointercancel", onUp );
        } );
    };

    var saveBlock = function( block ) {
        var payload = { markers: block.markers.map( function( m ) { return { xPx: m.xPx, yPx: m.yPx, xMm: m.xMm, yMm: m.yMm }; } ) };
        block.$block.find( ".engraving-status" ).text( "Salvataggio..." );

        NM.util.ajax( {
            method: "POST",
            url: url( block.attribute.id ),
            data: JSON.stringify( payload ),
            callback: {
                done: function( xhr ) {
                    if ( xhr.status === "INVALID" ) {
                        NM.form.showMessages( xhr.data );
                        block.$block.find( ".engraving-status" ).text( "" );
                        return;
                    }
                    block.markers = ( xhr.data.markers || [] ).map( function( m ) { return { order: m.order, xPx: Number( m.xPx ), yPx: Number( m.yPx ), xMm: Number( m.xMm ), yMm: Number( m.yMm ) }; } );
                    setDirty( block, false );
                    drawMarkers( block );
                    AP.widget.notify( "success", xhr.data.message || "Griglia incisioni salvata." );
                }
            }
        } );
    };

    // ---- init --------------------------------------------------------------------

    pub.init = function() {
        cfg = AP.page.engraving;

        NM.util.ajax( {
            method: "GET",
            url: url(),
            callback: {
                done: function( xhr ) {
                    var attributes = ( xhr.data && xhr.data.attributes ) || cfg.attributes || [];
                    cfg.canEdit = xhr.data && typeof xhr.data.canEdit !== "undefined" ? !!xhr.data.canEdit : !!cfg.canEdit;
                    renderBlocks( attributes );
                }
            }
        } );
    };

    // esposto per test e per la modale placca (stessa scala px/mm)
    pub.moduleMm = MODULE_MM;
    pub.getBlocks = function() { return blocks; };

    return pub;
}() );
