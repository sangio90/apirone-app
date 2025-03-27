<cfoutput>

    <div id="fruit-items-combinations-images-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="combination-reordering-modal-form" name="combination-reordering-modal-form" autocomplete="off">
                
                    <header class="card-header">
                        <h2 class="card-title">Tutte le combinazioni degli attributi</h2>
                    </header>
                    
                    <div class="card-body">                
                        
                        <div class="col-12 text-end mb-2" id="fruit-items-combinations-status">
                        </div>

                        <cfset combinations = [
                            "LED per levetta: BIANCO - Tipo led: 230 V",
                            "LED per levetta: BIANCO - Tipo led: 12-24Vcc/ca",
                            "LED per levetta: ROSSO - Tipo led: 230 V",
                            "LED per levetta: ROSSO - Tipo led: 12-24Vcc/ca",
                            "LED per levetta: BLU - Tipo led: 230 V",
                            "LED per levetta: BLU - Tipo led: 12-24Vcc/ca",
                        ]>
                                                
                        <div class="col-12">

                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Combinazione</th>
                                        <th>Immagini</th>
                                        <th>Componenti</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop array="#combinations#" item="item">
                                        <tr>
                                            <td>
                                                #item#
                                            </td>
                                            <td width="50">
                                                <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="item">
                                                    <i class="fas fa-image"></i>
                                                </button>
                                            </td>
                                            <td width="50">
                                                <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="item">
                                                    <i class="fas fa-window-restore"></i>
                                                </button>
                                            </td>
                                            <td width="30">
                                                <input name="" type="checkbox">
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>

                            <!---
                            #grid(
                                id      = "combination-ordering-items-grid",
                                class   = "no-pager",
                                columns = "[
                                    { 'field':'Id', 'title':'ID', width: '60px' },
                                    { 'field':'name', 'title':'Attributo' },
                                    { 'field':'', 'title':'Riordina', width: '55px'},
                                ]",
                                source: "items",
                                rowTemplate = "combination/combination-ordering-item-row-tmpl"
                            )#
                            --->

                        </div>
                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 text-end">
                                <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            </div>
                        </div>
                    </footer>                    
                
                </form>

            </div>
        </section>

    </div>

</cfoutput>
