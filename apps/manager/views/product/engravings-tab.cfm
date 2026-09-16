<cfoutput>
    <!---
        Griglia incisioni: per ogni attributo radice dell'incisione (IS, II, IL) l'immagine
        orizzontale del frutto con i marker (posizioni ammesse per il simbolo inciso).
        I blocchi sono disegnati da app-product-engravings.js a partire da AP.page.engraving.
    --->
    <div class="tab-pane p-2 fade" id="product-engravings" role="tabpanel" aria-labelledby="product-engravings-tab">
        <div class="row" data-bind="role: this" data-role-list="ADM/TCD">
            <div class="col-12">
                <p class="text-muted small mb-3">
                    Ogni marker è il centro di un'incisione ammessa. Trascina la "x" nel riquadro: le coordinate
                    (px dell'immagine e mm, origine al CENTRO dell'immagine) sono mostrate in tempo reale. Il
                    riquadro rappresenta l'area di lavoro completa, ±80mm dal centro in ogni direzione (160×160mm):
                    un marker può stare anche fuori dall'immagine del frutto, ad esempio per una scritta sopra
                    al pulsante e non dentro. Per una posizione precisa puoi anche scrivere le coordinate nella
                    tabella: px e mm restano allineati e il marker si sposta mentre digiti. Un modulo frutto
                    misura 11,25 × 45 mm.
                </p>
                <div id="product-engravings-blocks"></div>
            </div>
        </div>
    </div>

    <style>
        .engraving-block { margin-bottom: 2rem; }
        .engraving-stage {
            position: relative;
            display: inline-block;
            background: ##f4f4f4;
            border: 1px solid ##ddd;
            overflow: hidden;
            user-select: none;
            -webkit-user-select: none;
            touch-action: none;
        }
        /* l'immagine è centrata nel quadrato (area di lavoro 160x160mm), non ancorata in alto a sinistra */
        .engraving-stage img { display: block; position: absolute; pointer-events: none; }
        .engraving-center-mark {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 16px;
            height: 16px;
            margin: -8px 0 0 -8px;
            pointer-events: none;
            z-index: 5;
        }
        .engraving-center-mark::before, .engraving-center-mark::after {
            content: "";
            position: absolute;
            background: rgba(0, 0, 0, .35);
        }
        .engraving-center-mark::before { left: 50%; top: 0; width: 1px; height: 100%; margin-left: -.5px; }
        .engraving-center-mark::after  { top: 50%; left: 0; height: 1px; width: 100%; margin-top: -.5px; }
        .engraving-coords {
            position: absolute;
            top: 4px;
            left: 4px;
            padding: 2px 6px;
            background: rgba(0, 0, 0, .7);
            color: ##fff;
            font-size: 11px;
            line-height: 1.3;
            border-radius: 3px;
            pointer-events: none;
            white-space: nowrap;
            z-index: 20;
        }
        .engraving-marker {
            position: absolute;
            width: 22px;
            height: 22px;
            margin: -11px 0 0 -11px;
            cursor: grab;
            z-index: 10;
        }
        .engraving-marker.is-dragging { cursor: grabbing; z-index: 11; }
        .engraving-marker::before, .engraving-marker::after {
            content: "";
            position: absolute;
            left: 50%;
            top: 50%;
            width: 22px;
            height: 3px;
            margin: -1.5px 0 0 -11px;
            background: ##d9230f;
            box-shadow: 0 0 0 1px rgba(255, 255, 255, .8);
        }
        .engraving-marker::before { transform: rotate(45deg); }
        .engraving-marker::after  { transform: rotate(-45deg); }
        .engraving-marker .engraving-marker-order {
            position: absolute;
            top: -10px;
            right: -12px;
            min-width: 16px;
            height: 16px;
            padding: 0 4px;
            border-radius: 8px;
            background: ##d9230f;
            color: ##fff;
            font-size: 10px;
            line-height: 16px;
            text-align: center;
            font-weight: bold;
        }
        .engraving-marker.is-selected::before, .engraving-marker.is-selected::after { background: ##0d6efd; }
        .engraving-marker.is-selected .engraving-marker-order { background: ##0d6efd; }
        .engraving-list td, .engraving-list th { font-size: 12px; padding: .25rem .35rem; vertical-align: middle; }
        .engraving-list .engraving-input {
            width: 74px;
            font-size: 12px;
            padding: .1rem .3rem;
            text-align: right;
        }
        /* le frecce del campo numerico restano, servono per spostare il marker di un passo */
        .engraving-list .engraving-input:focus { border-color: ##0d6efd; box-shadow: none; }
    </style>
</cfoutput>
