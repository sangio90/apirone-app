<cfoutput>

    <div id="attribute-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>                

                <nav>

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="attribute-nav-detail-but" data-bs-toggle="tab" 
                                href="##attribute-nav-detail-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                Dettaglio
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="attribute-nav-values-but" data-bs-toggle="tab" 
                                href="##attribute-nav-values-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                Valori
                            </a>
                        </li>
                    </ul>

                </nav>

                <div class="tab-content" id="nav-tabContent">

                    <!--- panel 1 ---->
                    <div class="tab-pane fade show active" id="attribute-nav-detail-tab" role="tabpanel" aria-labelledby="attribute-nav-detail-but">                

                        <form id="attribute-detail-form" method="POST" name="attribute-detail-form">
                        
                            <div class="card-body">

                                <div class="mb-3 row">
                                    <label for="attr" class="col-sm-2 col-form-label text-end">Codice</label>
                                    <div class="col-sm-10">
                                        <input type="text" required class="form-control col-sm-4 uppercase" id="code" name="code" maxlength="5"
                                            data-bind="value: detailForm.data.code"
                                        >
                                    </div>
                                </div>

                                <div class="mb-3 row">
                                    <label for="attr" class="col-sm-2 col-form-label text-end">Descrizione (it)</label>
                                    <div class="col-sm-10">
                                        <input type="text" required class="form-control col-sm-4 uppercase" id="attr" name="attr"
                                            data-bind="value: detailForm.data.nameItem.name"
                                        >
                                    </div>
                                </div>

                                <div class="mb-3 row">
                                    <label for="categories" class="col-sm-2 col-form-label text-end">Disponili per</label>
                                    <div class="col-sm-10">
                                        <select id="categories" 
                                            data-placeholder="Seleziona le categorie"
                                            data-role="multiselect" 
                                            data-bind="source: categories, value: detailForm.data.selectedCategories" 
                                            data-value-field="id"
                                            data-text-field="name"
                                            >
                                        </select>
    
                                    </div>
                                </div>

                                <div class="mb-3 row">
                                    <label for="statusId" class="col-sm-2 col-form-label text-end">Stato</label>
                                    <div class="col-sm-10">
                                        <select type="text" class="form-control" name="statusId"
                                            required
                                            data-bind="source: statusList, value: detailForm.data.status.id"
                                            data-value-field="id"
                                            data-text-field="name">
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3 row" data-bind="visible: isUpdate">
                                    <div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
                                        ID: <span data-bind="text: detailForm.data.id"></span><br>
                                        Creato: <span data-bind="text: detailForm.data.createdAt"></span>
                                    </div>
                                </div>

                                <div class="row mb-3" data-bind="invisible: isUpdate">
                                    <label class="col-sm-2">&nbsp;</label>
                                    <div class="col-sm-10 grey">
                                        Successivamente potrai caricare i valori dell'attributo
                                    </div>
                                </div>

                            </div>

                        </form>

                    </div>

                    <!--- panel 2 ---->
                    <div class="tab-pane fade" id="attribute-nav-values-tab" role="tabpanel" aria-labelledby="attribute-nav-values-but">

                        <div class="card-body">

                            <div class="col-12">

                                <div class="divider mb-3">aggiungi valore</div>

                                <form id="attribute-values-suggest-form" method="POST" name="attribute-values-suggest-form">

                                    <div class="col-sm-7 col-sx-12 mb-3  box-search-small">

                                        <input type="text" name="attribute-suggest-raw-values" class="form-control" id="attribute-suggest-raw-values" 
                                            maxlength="150" placeholder="Cerca e aggiungi un valore..."
                                            data-bind="value: suggestForm.data.name"
                                            data-rule-required="true"
                                            data-msg-required="Valore richiesto">

                                    </div>
                                    
                                </form>

                            </div>

                            <div data-bind="invisible: isValuesGridVisible" class="mb-3 alert alert-warning">
                                <span>Nessun valore ancora caricato</span>
                            </div>

                            <form id="attribute-values-form" method="POST" name="attribute-values-form" data-bind="visible: isValuesGridVisible">

                                <div class="row mb-2">
                                    <div class="status col-6">
                                    </div>
                                    <div class="text-end col-6">
                                        <button type="button" class="btn btn-default btn-sm float-end" data-bind="click:deleteValues">
                                            <i class="fas fa-trash"></i> <span>Cancella valori</span>
                                        </button>

                                        <div class="status-delete mt-1 float-end me-3" id="attribute-values-delete-status"></div>
                                    </div>
                                </div>

                                #grid( 
                                    id="attribute-values-grid",
                                    class="no-pager",
                                    columns="[
                                        { 'field':'id', 'title':'ID', width: '60px' },
                                        { 'field':'code', 'title':'Codice', width: '100px' },
                                        { 'field':'name', 'title':'Descrizione', 'sortable': 'true'},
                                        { 'field':'', 'width':'40px', 'title':'Attiva note' },
                                        { 'field':'', 'width':'40px', 'title':'Questo valore modifica l\'immagine' },
                                        { 'field':'', 'width':'50px', 'title':'Numeri di componenti'},
                                        { 
                                            'field':'', 
                                            'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>',
                                            'width':'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
                                    source="detailForm.data.values",
                                    rowTemplate="attribute/attribute-values-list-row-tmpl"
                                )#

                            </form>

                        </div>

                    </div>
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 d-flex justify-content-end">
                            <div class="status errors-counter mt-1 me-3"></div>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            #saveButton(bind="click:save", size="sm")#
                        </div>
                    </div>
                </footer>

            </div>
        </selection>

    </div>

    #template( view="jstemplate/raw-value/raw-value-suggest-row-tmpl" )#

</cfoutput>