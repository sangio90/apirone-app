<cfoutput>

    <div id="catalog-bundle-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="catalog-bundle-detail-form" method="POST" name="catalog-bundle-detail-form">

                    <header class="card-header d-flex align-elements-center justify-content-between modal-header--sticky">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>

                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Categoria</label>
                            <div class="col-sm-10">
                                <select required class="form-control" name="categoryId"
                                    data-rule-required="true"
                                    data-msg-required="Categoria richiesta"
                                    data-bind="value: detailForm.data.category.id">
                                    <option value="">-- Seleziona la categoria</option>
                                    <cfloop array="#prc.categories#" item="item">
                                        <option value="#item.getId()#">#item.getName()#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Linea</label>
                            <div class="col-sm-10">
                                <select required class="form-control" name="lineId"
                                    data-rule-required="true"
                                    data-msg-required="Linea richiesta"
                                    data-bind="value: detailForm.data.line.id">
                                    <option value="">-- Seleziona la linea</option>
                                    <cfloop array="#prc.lines#" item="item">
                                        <option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Modello</label>
                            <div class="col-sm-10">
                                <select required class="form-control" name="modelId"
                                    data-rule-required="true"
                                    data-msg-required="Modello richiesto"
                                    data-bind="value: detailForm.data.model.id">
                                    <option value="">-- Seleziona il modello</option>
                                    <cfloop array="#prc.models#" item="item">
                                        <option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Markup %</label>
                            <div class="col-sm-4">
                                <input type="text" class="form-control" name="markupValue"
                                    data-rule-number="true"
                                    data-msg-number="Valore numerico"
                                    data-bind="value: detailForm.data.markupValue">
                            </div>
                        </div>

                        <div class="mb-3 row" data-bind="visible: detailForm.data.id">
                            <div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
                                ID: <span data-bind="text: detailForm.data.id"></span>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer modal-footer--sticky">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:saveDetail">
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
