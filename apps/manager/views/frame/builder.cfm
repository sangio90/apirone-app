<cfoutput>
<!---
    FRAME/BUILDER.CFM
    =================
    Pagina di gestione delle placche (frames) a blocchi di slot.
    App Vue 2 montata su ##plate-builder-app (logica in app-plate-builder.js).

    - Vista "list": elenco placche con ricerca, nuova/modifica/elimina.
    - Vista "edit": form placca (nome, codice, stato, orientamento) +
      editor dei blocchi (n. slot, margini mm, modalità orientamento) +
      anteprima in scala con numerazione degli slot.
--->
<script src="/assets/#prc.staticVersion#/main/js/vue2.js"></script>

<div id="plate-builder-root">
<div id="plate-builder-app" v-cloak>

    <!--- ======================= ELENCO ======================= --->
    <div v-if="view === 'list'">

        <div class="row">
            <div class="col-6">
                #pageTitle()#
            </div>
            <div class="col-6 text-end pb-3">
                <button type="button" class="btn btn-primary btn-sm" @click="newFrame">
                    <i class="fas fa-plus"></i> Nuova placca
                </button>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <section class="card">
                    <div class="card-body">

                        <form class="row d-flex align-items-end mb-3" @submit.prevent="search">
                            <div class="col-sm-4">
                                <label class="col-form-label">Cerca</label>
                                <input type="text" class="form-control" v-model="filters.str" placeholder="Codice o nome">
                            </div>
                            <div class="col-sm-3">
                                <label class="col-form-label">Orientamento</label>
                                <select class="form-select" v-model="filters.orientationId">
                                    <option value="">-- tutti</option>
                                    <option v-for="ori in orientations" :value="ori.id" :key="ori.id">{{ ori.name }}</option>
                                </select>
                            </div>
                            <div class="col-sm-3">
                                <label class="col-form-label">Status</label>
                                <select class="form-select" v-model="filters.statusId">
                                    <option value="">-- tutti</option>
                                    <option v-for="status in statuses" :value="status.id" :key="status.id">{{ status.name }}</option>
                                </select>
                            </div>
                            <div class="col-sm-2">
                                <button type="submit" class="btn btn-primary">Cerca</button>
                            </div>
                        </form>

                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th style="width: 100px;">Codice</th>
                                    <th>Nome</th>
                                    <th style="width: 200px;">Orientamento</th>
                                    <th style="width: 130px;">Status</th>
                                    <th style="width: 110px;" class="text-end">&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-if="loading">
                                    <td colspan="5" class="text-center text-muted">Caricamento...</td>
                                </tr>
                                <tr v-else-if="!frames.length">
                                    <td colspan="5" class="text-center text-muted">Nessuna placca trovata.</td>
                                </tr>
                                <tr v-for="frame in frames" :key="frame.id" style="cursor: pointer;" @click="editFrame( frame.id )">
                                    <td><strong>{{ frame.code }}</strong></td>
                                    <td>{{ frame.name }}</td>
                                    <td>{{ frame.orientation ? frame.orientation.name : '' }}</td>
                                    <td>
                                        <span class="badge" :class="frame.status && frame.status.id === 'ACT' ? 'bg-success' : 'bg-secondary'">
                                            {{ frame.status ? frame.status.name : '' }}
                                        </span>
                                    </td>
                                    <td class="text-end">
                                        <button type="button" class="btn btn-sm btn-outline-primary me-1" title="Modifica" @click.stop="editFrame( frame.id )">
                                            <i class="fas fa-pencil-alt"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-danger" title="Elimina" @click.stop="deleteFrame( frame )">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                    </div>
                </section>
            </div>
        </div>

    </div>

    <!--- ======================= CREAZIONE / MODIFICA ======================= --->
    <div v-else>

        <div class="row">
            <div class="col-6">
                <h2 class="card-title">{{ form.id ? 'Modifica placca ' + form.code : 'Nuova placca' }}</h2>
            </div>
            <div class="col-6 text-end pb-3">
                <button type="button" class="btn btn-secondary btn-sm me-2" @click="backToList">
                    <i class="fas fa-arrow-left"></i> Torna all'elenco
                </button>
                <button type="button" class="btn btn-primary btn-sm" :disabled="saving" @click="saveFrame">
                    <i class="fas fa-save"></i> Salva
                </button>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                <section class="card mb-3">
                    <div class="card-body">

                        <div v-if="form.legacy" class="alert alert-warning">
                            Questa placca usa ancora la configurazione su file: i blocchi proposti sono ricavati
                            automaticamente dalla vecchia griglia. Verifica numero slot e margini, poi salva per
                            migrarla alla configurazione su database.
                        </div>

                        <div class="row mb-3">
                            <div class="col-sm-4">
                                <label class="col-form-label">Nome *</label>
                                <input type="text" class="form-control" v-model.trim="form.name" maxlength="200">
                            </div>
                            <div class="col-sm-2">
                                <label class="col-form-label">Codice *</label>
                                <input type="text" class="form-control" v-model.trim="form.code" maxlength="5" @blur="checkCode" :class="{ 'is-invalid': codeError }">
                                <div class="invalid-feedback" v-if="codeError">{{ codeError }}</div>
                            </div>
                            <div class="col-sm-3">
                                <label class="col-form-label">Orientamento placca</label>
                                <select class="form-select" v-model="form.orientation.id">
                                    <option v-for="ori in orientations" :value="ori.id" :key="ori.id">{{ ori.name }}</option>
                                </select>
                            </div>
                            <div class="col-sm-3">
                                <label class="col-form-label">Status</label>
                                <select class="form-select" v-model="form.status.id">
                                    <option v-for="status in statuses" :value="status.id" :key="status.id">{{ status.name }}</option>
                                </select>
                            </div>
                        </div>

                        <hr>

                        <div class="row mb-3">
                            <div class="col-sm-3">
                                <label class="col-form-label">Margine finale RIGHT (mm)</label>
                                <input type="number" min="0" step="0.5" class="form-control" v-model.number="form.marginRightMm">
                                <div class="form-text">Spazio dopo l'ultimo blocco verso il bordo destro.</div>
                            </div>
                            <div class="col-sm-3">
                                <label class="col-form-label">Margine finale BOTTOM (mm)</label>
                                <input type="number" min="0" step="0.5" class="form-control" v-model.number="form.marginBottomMm">
                                <div class="form-text">Spazio dopo l'ultimo blocco verso il bordo inferiore.</div>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <h4 class="mb-0">Blocchi di slot</h4>
                            <button type="button" class="btn btn-sm btn-outline-primary" @click="addBlock">
                                <i class="fas fa-plus"></i> Aggiungi blocco
                            </button>
                        </div>

                        <p class="text-muted" v-if="!form.blocks.length">
                            Nessun blocco: aggiungi almeno un blocco di slot.
                        </p>

                        <table class="table align-middle" v-if="form.blocks.length">
                            <thead>
                                <tr>
                                    <th style="width: 60px;">##</th>
                                    <th style="width: 140px;">N. slot (mezzifrutti)</th>
                                    <th style="width: 160px;">Margine TOP (mm)</th>
                                    <th style="width: 160px;">Margine LEFT (mm)</th>
                                    <th style="width: 200px;">Orientamento blocco</th>
                                    <th style="width: 120px;">Ruotabile prev.</th>
                                    <th>Slot</th>
                                    <th style="width: 140px;" class="text-end">&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="( block, index ) in form.blocks" :key="block._key">
                                    <td>{{ index + 1 }}</td>
                                    <td><input type="number" min="1" step="1" class="form-control form-control-sm" v-model.number="block.slotCount"></td>
                                    <td><input type="number" min="0" step="0.5" class="form-control form-control-sm" v-model.number="block.marginTopMm"></td>
                                    <td><input type="number" min="0" step="0.5" class="form-control form-control-sm" v-model.number="block.marginLeftMm"></td>
                                    <td>
                                        <select class="form-select form-select-sm" v-model="block.orientationMode" :disabled="!!block.rotatable" v-if="!block.rotatable">
                                            <option v-for="mode in orientationModes" :value="mode.id" :key="mode.id">{{ mode.name }}</option>
                                        </select>
                                        <span v-else class="text-muted small">Con la placca</span>
                                    </td>
                                    <td class="text-center">
                                        <input type="checkbox" class="form-check-input" v-model="block.rotatable" title="Se spuntato, l'utente può ruotare questo blocco in modo indipendente nel preventivo" @change="block.rotatable ? (block.orientationMode = 'HAV') : null">
                                    </td>
                                    <td class="text-muted">{{ blockSlotRange( index ) }}</td>
                                    <td class="text-end">
                                        <button type="button" class="btn btn-sm btn-outline-secondary me-1" title="Sposta su" :disabled="index === 0" @click="moveBlock( index, -1 )">
                                            <i class="fas fa-arrow-up"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-secondary me-1" title="Sposta giù" :disabled="index === form.blocks.length - 1" @click="moveBlock( index, 1 )">
                                            <i class="fas fa-arrow-down"></i>
                                        </button>
                                        <button type="button" class="btn btn-sm btn-outline-danger" title="Rimuovi" @click="removeBlock( index )">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                    </div>
                </section>

                <!--- ======================= ANTEPRIMA ======================= --->
                <section class="card" v-if="form.blocks.length">
                    <div class="card-body">

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="mb-0">
                                Anteprima
                                <small class="text-muted">
                                    ({{ previewLayout.width }} x {{ previewLayout.height }} mm, scala {{ previewScalePercent }}%)
                                </small>
                            </h4>
                            <div class="btn-group" v-if="form.orientation.id === 'HAV'">
                                <button type="button" class="btn btn-sm" :class="previewOrientation === 'HOR' ? 'btn-primary' : 'btn-outline-primary'" @click="previewOrientation = 'HOR'">Orizzontale</button>
                                <button type="button" class="btn btn-sm" :class="previewOrientation === 'VER' ? 'btn-primary' : 'btn-outline-primary'" @click="previewOrientation = 'VER'">Verticale</button>
                            </div>
                        </div>

                        <div class="plate-builder-preview-wrapper">
                            <div class="plate-builder-preview"
                                :style="{ width: ( previewLayout.width * previewScale ) + 'px', height: ( previewLayout.height * previewScale ) + 'px' }">

                                <div v-for="block in previewLayout.blocks"
                                    :key="'preview-' + block._key"
                                    class="plate-builder-block"
                                    :class="{ 'fixed-block': block.orientationMode !== 'HAV' }"
                                    :style="{
                                        left: ( block.left * previewScale ) + 'px',
                                        top: ( block.top * previewScale ) + 'px',
                                        width: ( block.width * previewScale ) + 'px',
                                        height: ( block.height * previewScale ) + 'px',
                                        flexDirection: block.cellOrientation === 'HOR' ? 'row' : 'column'
                                    }">

                                    <div v-for="slot in block.slots"
                                        :key="'slot-' + slot.id"
                                        class="plate-builder-slot"
                                        :style="{
                                            width: ( slot.width * previewScale ) + 'px',
                                            height: ( slot.height * previewScale ) + 'px'
                                        }">
                                        {{ slot.id }}
                                    </div>

                                </div>

                            </div>
                        </div>

                        <p class="text-muted mt-2 mb-0">
                            <small>
                                I numeri identificano gli slot (mezzifrutti) e restano gli stessi in orizzontale e verticale.
                                I blocchi con bordo tratteggiato hanno orientamento fisso e non ruotano con la placca.<br>
                                Margini blocco: con placca orizzontale il margine LEFT è riferito al blocco precedente (per il primo
                                blocco al bordo della placca) e il TOP al bordo superiore; con placca verticale è il TOP a
                                essere riferito al blocco precedente e il LEFT al bordo sinistro.<br>
                                Margini finali: RIGHT e BOTTOM aggiungono spazio dopo l'ultimo blocco verso i rispettivi bordi della placca.
                            </small>
                        </p>

                    </div>
                </section>

            </div>
        </div>

    </div>

</div>
</div>

<style>
    ##plate-builder-app[v-cloak] { display: none; }

    .plate-builder-preview-wrapper {
        overflow: auto;
        padding: 10px;
        background: ##f4f4f4;
        border: 1px solid ##ddd;
        border-radius: 4px;
    }

    .plate-builder-preview {
        position: relative;
        background: ##fff;
        border: 2px solid ##666;
        box-sizing: content-box;
    }

    .plate-builder-block {
        position: absolute;
        display: flex;
        border: 1px solid ##2a7ab9;
        background: rgba(42, 122, 185, 0.06);
        box-sizing: border-box;
    }

    .plate-builder-block.fixed-block {
        border-style: dashed;
        border-color: ##b9622a;
        background: rgba(185, 98, 42, 0.06);
    }

    .plate-builder-slot {
        display: flex;
        align-items: center;
        justify-content: center;
        border: 1px dotted ##999;
        box-sizing: border-box;
        font-size: 11px;
        color: ##555;
        background: ##fdfdfd;
    }
</style>
</cfoutput>
