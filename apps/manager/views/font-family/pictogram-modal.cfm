<cfoutput>
    <div id="pictogram-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="pictogram-form" method="POST" name="pictogram-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-start">Pittogrammi</label>
                            <div class="col-sm-12">
                                <form name="font-family-pictogram-grid-form" id="font-family-pictogram-grid-form" method="get">
                                    #grid( 
                                        id="font-family-pictogram-grid",
                                        columns="[
                                            { 'field':'id', 'title':'ID', width: '10%'},
                                            { 'field':'code', 'title':'Codice', width: '10%'},
                                            { 'field':'name', 'title':'Nome', width: '20%'},
                                            { 'field':'image', 'title':'', width: '30%'},
                                            { 'field':'', 'title':'', width: '30%'}
                                        ]",
                                        source = "detailForm.data.fontFamilyPictograms",
                                        rowTemplate="font-family-pictogram/font-family-pictogram-grid-row-tmpl"
                                    )#

                                </form>
                            </div>
                        </div>


                        <div class="mb-3 row">
                            <label class="col-sm-1 col-form-label text-start">Carica</label>
                            <div class="col-sm-3">
                                <select
                                    class="form-control"
                                    data-placeholder="-- Seleziona pittogramma"
                                    data-bind="source: pictograms, value: detailForm.data.pictogram, events: { change: setDescription }"
                                    data-value-field="id"
                                    data-text-field="id"
                                >
                                </select>
                            </div>
                            <div class="col-sm-2">
                                <label id="pictogramDescription"> -- </span>
                            </div>
                            <div class="col-sm-5">
                                <input type="file" id="pictogramFileUpload" class="mb-1 file-upload form-control">
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save, disabled: checkCanSave }">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </selection>
    
    </div>

</cfoutput>
<style>
    #font-family-pictogram-grid .k-grid-pager {
        display: none !important;
    }
</style>