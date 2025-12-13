<cfoutput>

    <div id="files-list-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="documents-form" name="documents-form" autocomplete="off">

                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>

                    <div class="card-body">

                        <div class="row" data-bind="source: files" data-template="files-list-row-tpl">
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

    <!--- NOTE: tpl: with "tmpl" not found :-( --->
    #template( view="jstemplate/file/file-list-row-tpl" )# 

</cfoutput>
