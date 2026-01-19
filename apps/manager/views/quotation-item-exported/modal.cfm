<cfoutput>
    <div id="modal-root" class="modal fade">
        
        <section class="modal-dialog modalxl">

            <div class="modal-content">
                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" id="modalTitle"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>
                
                <body>
                    <div class="card-body">
                        <form name="modal-grid-form" id="modal-grid-form" method="get">
                            <div class="col-12">
                                #grid(
                                    id      = "modal-grid",
                                    columns = "[
                                        { 'field':'rowNumber', 'title':'Num', width: '5%', 'headerAttributes': { 'class': 'justify-content-center' }},
                                        { 'field':'code', 'title':'Codice', width: '10%' },
                                        { 'field':'variant', 'title':'Variante', width: '10%' },
                                        { 'field':'color', 'title':'Colore', width: '10%' },
                                        { 'field':'um', 'title':'UM', width: '10%'},
                                        { 'field':'quantity', 'title':'Quantità', width: '10%', 'headerAttributes': { 'class': 'justify-content-end' }},
                                        { 'field':'note', 'title':'Note', width: '20%'},
                                        { 'field':'', 'title':'Azioni', width: '10%', 'headerAttributes': { 'class': 'justify-content-center' }}
                                    ]",
                                    source = "detailForm.items",
                                    rowTemplate = "quotation-item-exported/quotation-item-exported-diba-grid-row-tmpl"
                                )#
                            </div>

                        </form>
                    </div>
                </body>

            </div>
        </section>
    
    </div>
</cfoutput>