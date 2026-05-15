<cfoutput>
<!---
    PLATE-MODAL-VUE.CFM
    ====================
    Modale Bootstrap (classe .modal) per la configurazione di un articolo "placca"
    all'interno di un preventivo. Il markup dichiara un'app Vue 2 montata su
    #plate-vue-app; tutti i binding dinamici (v-model, v-for, @change, ecc.)
    sono gestiti dall'istanza Vue definita in un file JS esterno.

    Struttura generale:
        - #plate-modal-root           : contenitore modale Bootstrap (fade, aria-hidden)
        - #plate-vue-app              : punto di montaggio dell'app Vue
            - form#line-detail-form   : form principale (metodo POST)
                - header.card-header  : titolo + pulsante chiusura
                - div.card-body       : corpo del modale
            - Riga superiore          : quantità, linea, modello, finitura
            - Riga principale         :
                - col-2               : albero prodotto (tabs: placca / frutti)
                - col-8               : designer visivo + ricerca frutti
                - col-2               : dettaglio riga + prezzi (pricing)
            - footer.card-footer      : pulsanti di salvataggio e chiusura
--->
<script src="/assets/#prc.staticVersion#/main/js/vue2.debug.js"></script>
<!--- #prc.staticVersion#: versione cache-busting degli asset, impostata dal controller ColdBox tramite prc (private request collection) --->
    <div id="plate-modal-root" class="modal fade quotation-item-modal">
    <!--- Contenitore modale Bootstrap 5. La classe .modal .fade abilita l'animazione di apertura/chiusura. quotation-item-modal è una classe custom per lo stile specifico del modale articolo. id="plate-modal-root" : usato da jQuery/KendoUI per attivare il modale. --->

        <section class="modal-dialog modal-xl">
        <!--- Dialogo extra-large (modal-xl) di Bootstrap per ospitare il layout a tre colonne --->
            <div class="modal-content">

                <div id="plate-vue-app">
                <!--- Punto di montaggio dell'applicazione Vue 2. L'istanza Vue gestisce tutti i dati e gli eventi del form. --->

                    <form id="line-detail-form" method="POST" name="line-detail-form">
                    <!--- Form principale. method="POST" per compatibilità server-side. I dati vengono inviati lato server tramite chiamata AJAX dal codice Vue, non da submit nativo. --->

                        <header class="card-header d-flex align-elements-center justify-content-between">
                        <!--- Intestazione del modale con layout flex. d-flex allinea gli elementi orizzontalmente. --->
                            <h2 class="card-title">{{ detailForm.title }}</h2>
                            <!--- detailForm.title: titolo dinamico della finestra, aggiornato da Vue. Mostra "Carica placca" in creazione o "Modifica placca" in modifica. --->
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
                            <!--- Pulsante di chiusura standard Bootstrap 5. data-bs-dismiss="modal" chiude il modale tramite Bootstrap (non Vue). aria-label="Chiudi": accessibilità per screen reader. --->
                        </header>

                        <div class="card-body">
                        <!--- Corpo del modale: contiene tutti i campi di configurazione dell'articolo placca. --->

                            <!--- bundle / categorie --->
                            <div class="mb-3 row">
                            <!--- Riga superiore: selettori principali del prodotto (quantità, linea, modello, finitura). Layout orizzontale a 4 colonne (col-1, col-3, col-4, col-4) su 12 totali. --->
                                <div class="col-1">
                                    <label class="col-sm-12 col-form-label text-start">Quantit&agrave;</label>
                                    <input class="form-control" type="number" v-model.number="detailForm.data.quantity" min="1">
                                    <!--- v-model.number: modificatore Vue che converte automaticamente il valore in numero. detailForm.data.quantity: quantità dell'articolo nel preventivo. min="1": validazione HTML5, la quantità minima è 1. --->
                                </div>
                                <div class="col-3">
                                    <label class="col-sm-2 col-form-label">Linea</label>
                                    <select id="plate-line"
                                        required
                                        class="form-control"
                                        v-model="detailForm.data.product.line.id"
                                        @change="loadModels(); handleLineChange()">
                                        <!--- id="plate-line": identifica il select per eventuali selettori jQuery/CSS. required: validazione HTML5, la linea è obbligatoria. v-model: binding bidirezionale con l'ID linea. @change: due chiamate sequenziali — loadModels() carica i modelli della linea, handleLineChange() resetta i campi dipendenti (modello, finitura, attributi). --->
                                        <option value="">-- Seleziona la linea</option>
                                        <option v-for="line in lines" :value="line.id" :key="line.id">{{ line.name }}</option>
                                        <!--- lines: array di oggetti linea popolato da Vue al caricamento iniziale del modale. line.id: valore inviato al v-model. line.name: etichetta visualizzata. --->
                                    </select>
                                </div>

                                <div class="col-4">
                                    <label class="col-sm-2 col-form-label">Modello</label>
                                    <select id="plate-model"
                                        required
                                        class="form-control"
                                        v-model="detailForm.data.product.model.id"
                                        @change="loadFinishes(); handleModelChange()">
                                        <!--- id="plate-model": identificativo per CSS/jQuery. v-model: binding bidirezionale con l'ID modello. @change: due chiamate sequenziali — loadFinishes() carica le finiture del modello, handleModelChange() resetta i campi dipendenti (finitura, attributi). --->
                                        <option value="">-- Seleziona il modello</option>
                                        <option v-for="model in models" :value="model.id" :key="model.id">{{ model.code }}</option>
                                        <!--- models: array di modelli filtrato in base alla linea selezionata. model.code: codice del modello (es. "P100", "P200") visualizzato nell'elenco. --->
                                    </select>
                                </div>

                                <div class="col-4">
                                    <label class="col-sm-2 col-form-label">Finitura</label>
                                    <select id="plate-finish"
                                        required
                                        class="form-control"
                                        v-model="detailForm.data.product.finish.id"
                                        @change="loadProduct">
                                        <!--- id="plate-finish": identificativo per CSS/jQuery. v-model: binding bidirezionale con l'ID finitura. @change="loadProduct": carica il prodotto completo con tutti gli attributi configurabili (detailForm.data.product.items) e le opzioni per il designer. --->
                                        <option value="">-- Seleziona la finitura</option>
                                        <option v-for="finish in finishes" :value="finish.id" :key="finish.id">{{ finish.name }}</option>
                                        <!--- finishes: array di finiture disponibili per il modello selezionato. --->
                                    </select>
                                </div>
                            </div>

                            <div class="row mb-2 pb-2 bb-1">
                            <!--- Riga "Pulisci configurazione". bb-1: bordo inferiore per separazione visiva. --->
                                <div class="col-12 text-end">
                                    <a class="underline hand" @click="clearFilters" v-if="visibleUpperClearButton">Pulisci configurazione</a>
                                    <!--- v-if="visibleUpperClearButton": mostra il link solo quando ci sono selezioni attive da resettare. visibleUpperClearButton: proprietà computata Vue, true quando id è vuoto (nuova placca). @click="clearFilters": resetta tutte le selezioni (linea, modello, finitura, attributi, designer). --->
                                </div>
                            </div>

                            <div class="mb-3 row">
                            <!--- Riga principale a tre colonne (12 unità totali): col-2 (sinistra) : albero prodotto con tabs (placca / frutti). col-8 (centro) : designer visivo e ricerca frutti. col-2 (destra) : dettaglio riga e blocco pricing. --->

                                <!--- albero --->
                                <div class="col-2">
                                <!--- Colonna sinistra: navigazione ad albero del prodotto. Contiene tabs Bootstrap per alternare tra attributi della placca e dei frutti. --->

                                    <nav>
                                        <ul class="nav nav-tabs" role="tablist" id="quotation-plate-product-items-tabs">
                                        <!--- Navigazione a tabs Bootstrap 5 (nav-tabs). role="tablist": accessibilità per screen reader. --->
                                            <li class="nav-item">
                                                <a class="nav-link active" id="plate-product-items-but" data-bs-toggle="tab"
                                                    href="##plate-product-items-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                                    Placca
                                                </a>
                                            </li>
                                            <!--- Tab "Placca": mostra gli attributi configurabili della placca. .active di default perché la placca è il pannello principale. --->
                                            <li class="nav-item">
                                                <a class="nav-link" id="plate-fruit-product-items-but" data-bs-toggle="tab"
                                                    href="##plate-fruit-product-items-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                                    Frutti <span>(<span>{{ getFruitCount }}</span>)</span>
                                                </a>
                                                <!--- Tab "Frutti": mostra i frutti configurati per la placca. {{ getFruitCount }}: proprietà computata Vue che restituisce il numero di frutti aggiunti. Il conteggio è aggiornato automaticamente quando l'utente aggiunge/rimuove frutti. --->
                                            </li>
                                        </ul>
                                    </nav>

                                    <div class="tab-content" id="quotation-nav-tab-content">
                                    <!--- Contenitore dei pannelli tab. Ogni .tab-pane corrisponde a un tab sopra definito. --->

                                        <!--- plate --->
                                        <div class="tab-pane fade show active" id="plate-product-items-tab" role="tabpanel" aria-labelledby="plate-product-items-but">
                                        <!--- Pannello "Placca": elenca gli attributi configurabili della placca. .show .active: visibile di default. --->
                                            <div class="text-end mb-2">
                                                <a href="##" @click.prevent="goToProduct" target="_blank">Vai al prodotto</a>
                                                <!--- goToProduct: apre la scheda prodotto completa nel backoffice in una nuova finestra (target="_blank"). @click.prevent: previene il comportamento predefinito del link. --->
                                            </div>
                                            <div id="quotation-plate-product-items" style="max-width: 100%">
                                            <!--- style="max-width: 100%": impedisce overflow orizzontale dovuto a select indentate. --->
                                                <template v-for="item in detailForm.data.product.items">
                                                <!--- Itera sugli attributi del prodotto. Ogni oggetto item ha: attributeId (ID numerico), attributeName (nome descrittivo), level (livello gerarchico, 0 = radice), values (array di opzioni con productItemId, selected, attributeValue). --->
                                                    <div v-if="item.values && item.values.length" :id="'attribute-container-' + item.attributeId" :key="item.attributeId">
                                                    <!--- v-if: mostra il container solo se ci sono opzioni disponibili. :id dinamico per manipolazione DOM. --->
                                                        <label class="mb-1" :style="{ marginLeft: (1.5 * item.level) + 'rem' }">{{ item.attributeName }}</label>
                                                        <!--- :style: indentazione dinamica basata sul livello dell'attributo (level 0 = 0rem, level 1 = 1.5rem, ecc.). Crea un effetto ad albero visivo. --->
                                                        <select
                                                            class="form-control form-control-sm select-item me-3 mb-2"
                                                            :data-attribute-id="item.attributeId"
                                                            :style="{ marginLeft: (1.5 * item.level) + 'rem', width: 'calc(100% - ' + (1.5 * item.level) + 'rem)' }"
                                                            @change="handleProductItemSelect($event.target.value, item.attributeId, item.values.find(function(v) { return v.productItemId == $event.target.value }))">
                                                            <!--- :data-attribute-id: attributo data-* che identifica l'attributo a livello DOM. :style condizionale: se il livello è > 0, la larghezza del select viene ridotta della stessa quantità dell'indentazione. handleProductItemSelect: gestisce la selezione caricando i figli e aggiornando l'immagine. --->
                                                            <option
                                                                v-for="val in item.values"
                                                                :value="val.productItemId"
                                                                :key="val.productItemId"
                                                                :selected="val.selected">
                                                                {{ val.attributeValue && val.attributeValue.rawValue ? val.attributeValue.rawValue.name : (val.attributeValue && val.attributeValue.name ? val.attributeValue.name : '') }}
                                                                <!--- Visualizzazione del nome dell'opzione con fallback a cascata: 1. attributeValue.rawValue.name (preferito), 2. attributeValue.name, 3. stringa vuota. --->
                                                            </option>
                                                        </select>
                                                    </div>
                                                </template>
                                            </div>
                                        </div>

                                        <!--- fruits --->
                                        <div class="tab-pane" id="plate-fruit-product-items-tab" role="tabpanel" aria-labelledby="plate-fruit-product-items-but">
                                        <!--- Pannello "Frutti": elenco dei frutti configurati per la placca. Ogni frutto può essere espanso per mostrarne gli attributi configurabili. --->
                                            <div class="text-end"><a href="##" @click.prevent="toggleFruits" class="hand">{{ toggleFruitsLabel }}</a></div>
                                            <!--- toggleFruits: espande o contrae TUTTI i frutti contemporaneamente. toggleFruitsLabel: proprietà computata Vue, restituisce "Espandi tutti" o "Comprimi tutti". --->
                                            <div id="quotation-plate-fruits-product-items" style="max-width: 100%">
                                                <div v-for="fruit in detailForm.data.fruits" :key="fruit.id" class="quotation-fruit-row" :data-fruit-id="fruit.id">
                                                <!--- v-for: itera sui frutti configurati. Ogni oggetto fruit ha: id (univoco), fruit (anagrafica con name/code), items (attributi configurabili), expanded (stato espansione). :data-fruit-id: attributo data-* per identificazione DOM e hover effects. --->
                                                    <div class="quotation-fruit-row-header d-flex align-items-center justify-content-between mb-2" @click="toggleFruit(fruit)" style="cursor: pointer;">
                                                    <!--- Intestazione del frutto cliccabile. toggleFruit(fruit): espande/contrae il singolo frutto. d-flex: layout flex orizzontale con nome a sinistra e cestino a destra. --->
                                                        <div class="quotation-fruit-row-name">
                                                            <b>{{ fruit.fruit ? fruit.fruit.name : '' }}</b>
                                                            <span class="small-code">(<span>{{ fruit.fruit ? fruit.fruit.code : '' }}</span>)</span>
                                                            <!--- Nome del frutto in grassetto e codice tra parentesi. fruit.fruit.name/code: accesso annidato (fruit contiene un sotto-oggetto .fruit con i dati anagrafici). --->
                                                        </div>
                                                        <div @click.stop="removeFruit(fruit)" class="quotation-fruit-row-remove flex-shrink-1" style="cursor: pointer;">
                                                        <!--- @click.stop: .stop impedisce la propagazione al genitore (evita toggleFruit). removeFruit(fruit): rimuove il frutto dalla configurazione. --->
                                                            #iconButton(icon="trash")#
                                                            <!--- #iconButton(icon="trash")#: funzione CFML che genera il markup HTML di un pulsante icona cestino (FontAwesome). --->
                                                        </div>
                                                    </div>
                                                    <div v-if="fruit.expanded" :id="'quotation-fruit-row-items_' + fruit.id" class="fruit-product-items">
                                                    <!--- v-if="fruit.expanded": mostra gli attributi del frutto SOLO quando è espanso. :id dinamico per identificare il contenitore. --->
                                                        <template v-for="fi in fruit.items">
                                                        <!--- Itera sugli attributi del frutto (stessa struttura degli attributi placca). --->
                                                            <div v-if="fi.values && fi.values.length" :id="'fruit-attribute-container-' + fi.attributeId" :key="fi.attributeId">
                                                                <label class="mb-1" :style="{ marginLeft: (1.5 * (fi.level || 0)) + 'rem' }">{{ fi.attributeName }}</label>
                                                                <select
                                                                    class="form-control form-control-sm select-item me-3 mb-2"
                                                                    :data-attribute-id="fi.attributeId"
                                                                    :style="{ marginLeft: (1.5 * (fi.level || 0)) + 'rem', width: 'calc(100% - ' + (1.5 * (fi.level || 0)) + 'rem)' }"
                                                                    @change="handleFruitProductItemSelect(fruit.id, $event.target.value, fi.attributeId, fi.values.find(function(v) { return v.productItemId == $event.target.value }))">
                                                                    <!--- handleFruitProductItemSelect: come handleProductItemSelect ma specifico per attributi frutto. Riceve: fruit.id, valore selezionato, attributeId, oggetto valore completo. --->
                                                                                                                                        <option
                                                                        v-for="val in fi.values"
                                                                        :value="val.productItemId"
                                                                        :key="val.productItemId"
                                                                        :selected="val.selected">
                                                                        {{ val.attributeValue && val.attributeValue.rawValue ? val.attributeValue.rawValue.name : (val.attributeValue && val.attributeValue.name ? val.attributeValue.name : '') }}
                                                                    </option>
                                                                </select>
                                                            </div>
                                                        </template>
                                                    </div>
                                                </div>
                                                <div v-if="getFruitCount === 0" class="text-center mt-4">
                                                <!--- Messaggio placeholder quando non ci sono frutti configurati. getFruitCount (proprietà computata) === 0 significa nessun frutto. --->
                                                    <h3 style="opacity: 0.5;">Nessun frutto ancora aggiunto</h3>
                                                </div>
                                            </div>
                                        </div>

                                    </div>

                                </div>

                                <!--- designer placca --->
                                <div class="col-8">
                                <!--- Colonna centrale: area principale del modale. Contiene i comandi del designer (orientamento, ricerca frutti) e l'area di visualizzazione grafica della placca. --->
                                    <div id="plate-designer-header" class="mb-2 pb-2">
                                        <div class="row">
                                            <div class="col-md-2 float-end">
                                                <select id="plate-orientation"
                                                    required
                                                    class="form-control"
                                                    v-model="detailForm.data.product.orientation.id"
                                                    @change="changeOrientation">
                                                    <!--- detailForm.data.product.orientation.id: ID dell'orientamento selezionato (es. O/H = orizzontale, VERT = verticale). changeOrientation: ricarica il designer con il nuovo orientamento. required: l'orientamento è obbligatorio. --->
                                                    <option value="">-- Seleziona orientamento --</option>
                                                    <option v-for="o in availableOrientations" :value="o.id" :key="o.id">{{ o.name }}</option>
                                                    <!--- availableOrientations: lista degli orientamenti disponibili per la linea/modello correnti. --->
                                                </select>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="fruit-suggest-wrapper" style="position: relative;">
                                                <!--- position: relative necessario per posizionare il dropdown dei suggerimenti (position: absolute) subito sotto l'input. --->
                                                    <input
                                                        type="text"
                                                        id="plate-fruit-suggest"
                                                        class="fruit-suggest-widget-input"
                                                        placeholder="Aggiungi un frutto..."
                                                        v-model="fruitSearchTerm"
                                                        @input="onFruitSearchInput"
                                                        autocomplete="off">
                                                    <!--- v-model="fruitSearchTerm": termine di ricerca digitato dall'utente. @input="onFruitSearchInput": chiama la funzione di ricerca a ogni variazione del testo (chiamata API con soglia minima 3 caratteri). autocomplete="off": disabilita l'autocompletamento nativo del browser. --->
                                                    <div v-if="fruitSuggestions.length" style="position: absolute; top: 100%; left: 0; right: 0; z-index: 1000; background: white; border: 1px solid ##ccc; max-height: 200px; overflow-y: auto;">
                                                    <!--- Dropdown dei suggerimenti frutto. v-if="fruitSuggestions.length": mostra solo quando ci sono risultati. position: absolute e top: 100%: posizionato subito sotto l'input. max-height: 200px; overflow-y: auto: scroll verticale. NOTA: ## nel valore HTML è un escape di # per CFML (## produce # nell'output). --->
                                                        <div
                                                            v-for="suggestion in fruitSuggestions"
                                                            :key="suggestion.id"
                                                            @click="selectFruitSuggestion(suggestion)"
                                                            style="padding: 4px 8px; cursor: pointer; border-bottom: 1px solid ##eee;">
                                                            <!--- Ogni suggerimento cliccabile. selectFruitSuggestion(suggestion): aggiunge il frutto selezionato alla configurazione (detailForm.data.fruits). --->
                                                            {{ suggestion.name }} ({{ suggestion.code }})
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div id="plate-designer-root">
                                    <!--- Contenitore principale del designer visivo. Alterna tra disegno tecnico della placca (plate-designer) e immagine personalizzata (plate-custom-designer), controllato dal flag detailForm.data.customImage. --->
                                        <div class="plate-designer" id="plate-designer" v-show="!detailForm.data.customImage">
                                        <!--- v-show="!detailForm.data.customImage": visibile SOLO quando NON è attiva l'immagine personalizzata. Usa v-show (non v-if) per mantenere il DOM e non distruggere/ricreare il canvas a ogni toggle. --->
                                            <div class="plate-designer-canvas" id="plate-designer-canvas">
                                            <!--- Contenitore canvas SVG/HTML dove il designer disegna la placca in base alle selezioni. Il contenuto viene gestito da JavaScript esterno (modulo grid/fruitsController). --->
                                                <h1 style="opacity: 0.5;">Definisci le impostazioni in alto per iniziare</h1>
                                                <!--- Placeholder mostrato quando non ci sono ancora selezioni sufficienti per disegnare la placca. --->
                                            </div>
                                        </div>
                                        <div class="plate-custom-designer" id="plate-custom-designer" v-show="detailForm.data.customImage">
                                        <!--- v-show="detailForm.data.customImage": visibile SOLO quando è attiva l'immagine personalizzata. Sostituisce il disegno tecnico con un'immagine caricata dall'utente. --->
                                            <img id="plate-custom-image" :src="backgroundCustomImage.url" v-if="backgroundCustomImage.url" />
                                            <!--- :src="backgroundCustomImage.url": binding dinamico dell'URL dell'immagine. v-if="backgroundCustomImage.url": evita la renderizzazione del tag <img> se l'URL è vuoto (previene richieste HTTP fallite). --->
                                        </div>
                                    </div>
                                </div>

                                <!--- dettaglio riga / pricing --->
                                <div class="col-2" style="z-index: 1">
                                <!--- Colonna destra: opzioni articolo (speciale, immagine custom, stato), zona/sottozona/posizione, note, blocco prezzi. z-index: 1: garantisce che eventuali dropdown siano sopra l'area del designer. --->
                                    <div class="h-100">

                                        <div class="row">
                                            <div class="col-3">
                                                <div class="mb-1">Speciale:</div>
                                                <div>
                                                    <input class="form-check-input" type="checkbox" name="special" v-model="detailForm.data.special">
                                                    <!--- detailForm.data.special: flag booleano. Se true, indica che l'articolo ha un prezzo speciale/personalizzato (non calcolato automaticamente dal listino). --->
                                                </div>
                                            </div>

                                            <div class="col-3">
                                                <div v-if="detailForm.data.id">
                                                <!--- Sezione visibile SOLO in modifica (quando detailForm.data.id esiste, ossia l'articolo è già stato salvato). In creazione l'immagine custom non è ancora disponibile. --->
                                                    <div class="mb-1">Immagine Custom:</div>
                                                    <div>
                                                        <input class="form-check-input me-4" type="checkbox" name="customImage" v-model="detailForm.data.customImage" @change="toggleCustomImage">
                                                        <!--- detailForm.data.customImage: flag per attivare/disattivare l'immagine personalizzata. @change="toggleCustomImage": gestisce il passaggio tra designer tecnico e immagine personalizzata. --->
                                                        <a type="button" class="btn btn-primary btn-sm" data-type="quotationItem" @click="openImagesList" v-if="detailForm.data.customImage" style="font-size: 10px;">
                                                        <!--- Pulsante visibile solo quando la checkbox "Immagine Custom" è attiva. openImagesList: apre la galleria di selezione immagini. data-type="quotationItem": identifica il tipo di entità per il gestore della galleria. --->
                                                            Aggiungi <i class="fas fa-image"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="col-6 mb-2">
                                                <div class="mb-1">Stato:</div>
                                                <div>
                                                    <select name="status" class="form-control form-control-sm" id="input-price-status" v-model="detailForm.data.status.id">
                                                    <!--- detailForm.data.status.id: ID dello stato dell'articolo nel preventivo (es. "ACT" = attivo, "BOZ" = bozza). --->
                                                        <option v-for="s in detailForm.itemStatuses" :value="s.id" :key="s.id">{{ s.name }}</option>
                                                        <!--- detailForm.itemStatuses: array di stati disponibili per gli articoli di preventivo, popolato da Vue. --->
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="col-12">
                                                <div class="row mb-2">
                                                    <div class="col-4 mt-2">Zona:</div>
                                                    <div class="col-8">
                                                        <select class="form-control my-2" name="zona" v-model="detailForm.data.quotationZoneId" id="zones-selector" @change="onZoneChange">
                                                        <!--- detailForm.data.quotationZoneId: ID della zona geografica. @change="onZoneChange": carica le sottozone corrispondenti e aggiorna l'oggetto quotationZone. --->
                                                            <option value="">-- Seleziona una zona --</option>
                                                            <option v-for="zone in zones" :value="zone.id" :key="zone.id">{{ zone.name }}</option>
                                                            <!--- zones: array di zone geografiche (solo zone padre, senza origin). --->
                                                        </select>
                                                    </div>
                                                    <div class="col-4 mt-2">Sottozona:</div>
                                                    <div class="col-8">
                                                        <select class="form-control form-control my-2" name="sottozona" v-model="detailForm.data.quotationSubzoneId" :disabled="!detailForm.data.quotationZoneId" id="subzones-selector">
                                                        <!--- detailForm.data.quotationSubzoneId: ID della sottozona. :disabled="!detailForm.data.quotationZoneId": disabilitato finché non viene selezionata una zona padre. --->
                                                            <option value="">-- Seleziona sottozona --</option>
                                                            <option v-for="sz in subzones" :value="sz.id" :key="sz.id">{{ sz.name }}</option>
                                                            <!--- subzones: array di sottozone filtrato in base alla zona selezionata, popolato da loadSubZones. --->
                                                        </select>
                                                    </div>
                                                    <div class="col-4 mt-2">Posizione:</div>
                                                    <div class="col-8" style="position: relative;">
                                                    <!--- position: relative: necessario per posizionare il dropdown dei suggerimenti posizione in absolute. --->
                                                        <input class="form-control form-control-sm" name="position" placeholder="Posizione" id="qt-plate-position-suggest" v-model="positionSearchTerm" @input="onPositionSearchInput" @blur="syncPositionFromSearchTerm" autocomplete="off">
                                                        <!--- Campo di ricerca posizione con autocompletamento. positionSearchTerm: termine di ricerca. @input="onPositionSearchInput": cerca posizioni (min 2 caratteri, richiede zona). @blur="syncPositionFromSearchTerm": sincronizza il valore selezionato quando l'input perde il focus. --->
                                                        <div v-if="positionSuggestions.length" style="position: absolute; top: 100%; left: 0; right: 0; z-index: 1000; background: white; border: 1px solid ##ccc; max-height: 150px; overflow-y: auto;">
                                                        <!--- Dropdown suggerimenti posizione (stessa logica del dropdown frutti). max-height: 150px: più compatto perché i codici posa sono brevi. --->
                                                            <div v-for="suggestion in positionSuggestions" :key="suggestion.id" @click="selectPositionSuggestion(suggestion)" style="padding: 4px 8px; cursor: pointer; border-bottom: 1px solid ##eee;">
                                                            <!--- selectPositionSuggestion(suggestion): imposta la posizione selezionata in detailForm.data.position. --->
                                                                {{ suggestion.code }}
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12 mb-2">
                                            <textarea class="form-control" name="notes" placeholder="Note" rows="4" v-model="detailForm.data.note"></textarea>
                                            <!--- detailForm.data.note: note testuali opzionali per l'articolo (es. istruzioni speciali per la produzione). rows="4": altezza di 4 righe. --->
                                        </div>

                                        <!--- pricing inlined --->
                                        <div class="pricing-box" id="plate-quotation-item-pricing-box">
                                        <!--- Blocco prezzi: dettaglio costi calcolati, sconti, tipo prezzo e totale. I dati sono gestiti dal sotto-oggetto pricing dell'istanza Vue, separato da detailForm per chiarezza logica. pricing contiene: data (lines, discount1/2, method, total), priceTypes (tipi prezzo disponibili), isTotalEnabled (abilita/disabilita campo totale). --->
                                            <div class="row mb-2">
                                                <div class="col-12">
                                                    <table style="width: 100%" class="quotation-table-item-prices-totals">
                                                        <tbody>
                                                            <tr v-for="line in pricing.data.lines" :key="line.name">
                                                            <!--- Itera sulle righe di dettaglio del prezzo calcolato. Ogni riga (line) ha: name (descrizione voce di costo), amount (importo formattato). --->
                                                                <td><span>{{ line.name }}</span></td>
                                                                <td width="30" class="text-end" nowrap><span>{{ line.amount }}</span> &euro;</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-12">Sconti:</div>
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-6"><input class="form-control" name="discount1" style="font-size: 12px;" placeholder="%" v-model="pricing.data.discount1"></div>
                                                <div class="col-6"><input class="form-control" name="discount2" style="font-size: 12px;" placeholder="%" v-model="pricing.data.discount2"></div>
                                                <!--- pricing.data.discount1/2: sconti percentuali applicati al prezzo base. style="font-size: 12px": carattere piccolo per la colonna stretta. --->
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-12">Tipo Prezzo:</div>
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-12">
                                                    <select name="priceMethod" class="form-control" id="input-price-method" style="font-size: 12px;" v-model="pricing.data.method.id" @change="changePricingMethod">
                                                    <!--- pricing.data.method.id: ID del metodo di calcolo prezzo ("C" = Calcolato, "F" = Fisso). @change="changePricingMethod": abilita/disabilita il campo totale in base al metodo scelto. --->
                                                        <option v-for="pt in pricing.priceTypes" :value="pt.id" :key="pt.id">{{ pt.name }}</option>
                                                        <!--- pricing.priceTypes: array dei tipi prezzo disponibili. --->
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-12">Totale:</div>
                                            </div>
                                            <div class="row mb-2">
                                                <div class="col-12">
                                                    <div class="input-group">
                                                    <!--- input-group Bootstrap: accosta il campo input al simbolo € come add-on. --->
                                                        <input class="form-control text-end" name="total" id="input-item-total" style="font-size: 12px;" placeholder="Totale" v-model="pricing.data.total" :disabled="!pricing.isTotalEnabled">
                                                        <!--- pricing.data.total: importo totale dell'articolo (al netto degli sconti). :disabled="!pricing.isTotalEnabled": disabilitato quando il totale è calcolato automaticamente (metodo "C"). isTotalEnabled è true solo per il metodo "F" (Fisso). --->
                                                        <span class="input-group-text"><i class="fas fa-euro-sign"></i></span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row mb-2 mt-2">
                                                <div class="col-12 d-flex align-items-center">
                                                    <button type="button" class="btn btn-primary btn-sm mt-3" @click="updatePricing">
                                                    <!--- updatePricing: ricalcola i prezzi chiamando il servizio di pricing via AJAX. --->
                                                        <i class="fas fa-sync"></i> Aggiorna prezzi
                                                    </button>
                                                    <div class="ms-2 mt-3 status" id="quotation-item-pricing-status"></div>
                                                    <!--- Elemento DOM per mostrare lo stato dell'operazione di aggiornamento prezzi (caricamento, successo, errore). --->
                                                </div>
                                            </div>
                                        </div>

                                    </div>
                                </div>
                            </div>

                        <footer class="card-footer">
                        <!--- Footer del modale: informazioni sull'articolo (ID/data creazione) e pulsanti di azione. --->
                            <div class="row">
                                <div class="col-md-6 fs-10">
                                    <div v-if="detailForm.data.id">
                                    <!--- Sezione visibile SOLO in modifica (quando l'articolo ha un ID). Mostra ID e data di creazione. --->
                                        ID: <span>{{ detailForm.data.id }}</span> - Creato: <span>{{ detailForm.data.createdAt }}</span>
                                        <!--- detailForm.data.id: ID univoco dell'articolo. detailForm.data.createdAt: timestamp di creazione. --->
                                    </div>
                                </div>
                                <div class="col-md-6 float-end">
                                <!--- Colonna destra del footer: pulsanti di azione allineati a destra. --->
                                    <button id="saveButton" type="button" class="btn btn-primary btn-sm float-end" @click="save">
                                    <!--- save: salva l'articolo (creazione o aggiornamento) tramite chiamata AJAX. btn-primary: stile Bootstrap pulsante primario (blu). --->
                                        <i class="fas fa-save"></i> Salva
                                    </button>
                                    <button id="cloneButton" type="button" class="btn btn-warning btn-sm float-end" style="display: none" @click="save">
                                    <!--- cloneButton: pulsante per clonare l'articolo. style="display: none": nascosto di default, mostrato da Vue in contesto clone. btn-warning: stile Bootstrap giallo. @click="save": anche il clone usa la stessa funzione save. --->
                                        <i class="fas fa-save"></i> Clona
                                    </button>
                                    <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                    <!--- data-bs-dismiss="modal": chiude il modale Bootstrap 5 senza JavaScript Vue. btn-default: stile Bootstrap pulsante neutro. --->
                                    <button type="button" class="btn btn-primary btn-sm me-2 float-end" @click="clearFilters" v-if="visibleLowerClearButton">Pulisci Configurazione</button>
                                    <!--- clearFilters: stesso comportamento del pulsante "Pulisci configurazione" superiore. v-if="visibleLowerClearButton": variante inferiore dello stesso pulsante logico. --->
                                    <div class="save-status errors-counter mt-1 float-end me-3"></div>
                                    <!--- Elemento DOM per mostrare il conteggio errori di validazione o stato del salvataggio. Gestito da Vue/jQuery dopo save. --->
                                </div>
                            </div>
                        </footer>

                    </form>

                </div>

            </div>
        </section>

    </div>
</cfoutput>
