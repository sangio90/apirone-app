<cfoutput>

    <div id="pictogram-root">
        
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
                                <div class="col-sm-12">
                                    
                                    #grid( 
                                        id="font-family-pictogram-grid",
                                        class="no-pager",
                                        columns="[
                                            { 'field':'id', 'title':'ID', width: '50'},
                                            { 'field':'code', 'title':'Codice'},
                                            { 'field':'name', 'title':'Nome'},
                                            { 'field':'image', 'title':'Immagine'},
                                            { 'field':'', 'title':'Dimensioni', width: '50'},
                                            { 'field':'', 'title':'', width: '50'}
                                        ]",
                                        source = "detailForm.data.fontFamilyPictograms",
                                        rowTemplate="font-family-pictogram/font-family-pictogram-grid-row-tmpl"
                                    )#

                                </div>
                            </div>

                            <div class="row align-items-center">
                                <label class="col-sm-1 col-form-label text-start">Carica</label>
                                <div class="col-sm-3">
                                    <select
                                        class="form-control"
                                        name="pictogramCode"
                                        data-bind="source: pictograms, value: detailForm.data.pictogram"
                                        data-value-field="id"
                                        data-text-field="id"
                                    >
                                    </select>
                                </div>
                                <div class="col-sm-3">
                                    <label data-bind="text:detailForm.data.pictogram.name"></span>
                                </div>
                                <div class="col-sm-5">
                                    <input type="file" 
                                        id="pictogramFileUpload" 
                                        name="pictogramFileUpload"
                                        class="mb-1 file-upload form-control">
                                </div>
                            </div>
                            <div class="mb-3 row align-items-center">
                                <div class="col-sm-3 offset-md-1" id="pictogramCode-error">
                                </div>
                                <div class="col-sm-5 offset-md-3" id="pictogramFileUpload-error">
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
            </section>
        
        </div>

        #view( "font-family/pictogram-dimensions-modal" )#

    </div>

</cfoutput>