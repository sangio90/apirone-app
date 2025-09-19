<!-- filepath: s:\workspace\users\roberto\projects\apir\apps\apirone-app\code\apps\manager\views\frame\detail.cfm -->
<cfoutput>
<div class="modal fade" id="frame-detail-modal" tabindex="-1" aria-labelledby="frameDetailLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="frameDetailLabel">Dettaglio Armatura</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
            </div>
            <div class="modal-body">
                <!-- Tabs -->
                <ul class="nav nav-tabs mb-3">
                    <li class="nav-item">
                        <a class="nav-link" href="##" data-bind="click: function() { switchTab('detail') }, css: { active: activeTab === 'detail' }">Anagrafica</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="##" data-bind="click: function() { switchTab('cells') }, css: { active: activeTab === 'cells' }">Posizioni</a>
                    </li>
                </ul>

                <!-- Tab Content: Anagrafica -->
                <div data-bind="visible: activeTab === 'detail'">
                    <form id="frame-detail-form">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="frameCode" class="form-label">Codice</label>
                                <input type="text" class="form-control" id="frameCode" data-bind="value: frame.code" maxlength="5" required>
                            </div>
                            <div class="col-md-6">
                                <label for="frameName" class="form-label">Nome</label>
                                <input type="text" class="form-control" id="frameName" data-bind="value: frame.frame" maxlength="200" required>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="orientationId" class="form-label">Orientamento</label>
                                <select class="form-select" id="orientationId" data-bind="value: frame.orientationId">
                                    <option value="VER">Verticale</option>
                                    <option value="HOR">Orizzontale</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="cellOrientationId" class="form-label">Orientamento celle</label>
                                <select class="form-select" id="cellOrientationId" data-bind="value: frame.cellOrientationId">
                                    <option value="VER">Verticale</option>
                                    <option value="HOR">Orizzontale</option>
                                </select>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Tab Content: Posizioni -->
                <div id="frame-cells-container" data-bind="visible: activeTab === 'cells'">
                    <div class="mb-3 d-flex gap-2">
                        <button id="add-row-btn" class="btn btn-outline-primary" data-bind="click: addRow">Aggiungi riga</button>
                        <button id="remove-row-btn" class="btn btn-outline-danger" data-bind="click: removeRow, enable: gridRows > 1">Rimuovi riga</button>
                        <button id="add-col-btn" class="btn btn-outline-primary" data-bind="click: addCol">Aggiungi colonna</button>
                        <button id="remove-col-btn" class="btn btn-outline-danger" data-bind="click: removeCol, enable: gridCols > 1">Rimuovi colonna</button>
                    </div>
                    
                    <div class="table-responsive">
                        <table id="frame-cells-table" class="table table-bordered">
                            <tbody data-bind="foreach: cellsMatrix">
                                <tr data-bind="foreach: $data">
                                    <td style="width: 60px; height: 60px; text-align: center; vertical-align: middle;">
                                        <input type="text" maxlength="1" style="width: 40px; text-align: center;" 
                                              data-bind="value: $data, event: { change: function(e) { $parent.$parent.editCell($parentContext.$index(), $index(), e.target.value) } }">
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    
                    <div class="alert alert-info mt-3">
                        <small>Inserisci "0" per posizione occupata o "_" per posizione vuota</small>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Chiudi</button>
                <button id="save-grid-btn" type="button" class="btn btn-primary" data-bind="click: save, disable: loading">
                    <span data-bind="visible: loading" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                    Salva
                </button>
            </div>
        </div>
    </div>
</div>
</cfoutput>