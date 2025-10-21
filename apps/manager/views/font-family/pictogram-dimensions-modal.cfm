<cfoutput>
    <div id="pictogram-dimensions-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="pictogram-dimensions-form" method="POST" name="pictogram-dimensions-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:titleDimensionModal"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <div class="col-sm-12">
                                
                                #grid( 
                                    id="font-family-pictogram-dimensions-grid",
                                    class="no-pager",
                                    columns="[
                                        { 'field':'id', 'title':'ID', width: '50'},
                                        { 'field':'size.name', 'title':'Dimensione'},
                                        { 'field':'width', 'title':'Larghezza'},
                                        { 'field':'height', 'title':'Altezza'},
                                        { 'field':'', 'title':'', width: '50'}
                                    ]",
                                    source = "dimensions",
                                    rowTemplate="font-family-pictogram/font-family-pictogram-size-grid-row-tmpl"
                                )#

                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:saveDimensions">
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
