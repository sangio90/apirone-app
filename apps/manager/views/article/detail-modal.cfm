<cfoutput>
    <div id="article-detail-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="article-detail-form" method="POST" name="article-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Codice</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4" 
                                    name="code"
                                    maxlength="10"
                                    data-bind="value: detailForm.data.code"
                                    onkeyup="this.value = this.value.toUpperCase();">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Codice esterno</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control col-sm-4 uppercase" 
                                    name="externalId"
                                    maxlength="15"
                                    data-bind="value: detailForm.data.externalId"
                                    onkeyup="this.value = this.value.toUpperCase();">
                            </div>
                            <div class="col-sm-10 offset-sm-2">
                                <span class="field-note">Lo stesso codice usato in Verticale</span>
                            </div>

                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Nome</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4 uppercase" name="name"
                                    data-msg-required="Nome richiesto"
                                    maxlength="125"
                                    data-bind="value: detailForm.data.nameItem.name">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Descrizione</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control col-sm-4 uppercase" name="description"
                                    data-msg-required="Descrizione richiesta"
                                    maxlength="125"
                                    data-bind="value: detailForm.data.descriptionItem.name">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Tipo</label>
                            <div class="col-sm-10">
                                <select id="typeId" class="form-control"
                                    required
                                    data-placeholder="-- Seleziona il tipo"
                                    data-bind="source: detailForm.types, value: detailForm.data.type" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Stato</label>
                            <div class="col-sm-10">
                                <select id="statusId" class="form-control"
                                    required
                                    data-bind="source: detailForm.statuses, value: detailForm.data.status.id" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Prezzo</label>
                            <div class="col-sm-10">
                                <div class="input-group">
                                    <input type="text" class="form-control" name="price" data-bind="value: detailForm.data.price.amount">
                                    <span class="input-group-text">
                                        <i class="fas fa-euro-sign text-4"></i>
                                    </span>
                                </div>
                                <div id="price-error"></div>
                            </div>
                        </div>

                        <div class="mb-3 row" data-bind="visible: detailForm.data.id">
                            <div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
                                ID: <span data-bind="text: detailForm.data.id"></span><br>
                                Creato: <span data-bind="text: detailForm.data.createdAt"></span>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

</cfoutput>