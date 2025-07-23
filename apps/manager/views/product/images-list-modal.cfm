<cfoutput>

    <div id="product-images-list-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="documents-form" name="documents-form" autocomplete="off">

                    <header class="card-header">
                        <h2 class="card-title">Carica immagini</h2>
                    </header>

                    <div class="card-body">

                        <div class="row"
                            data-bind="source: images"
                            data-template="product-images-item-tmpl">
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

        #template("jstemplate/product/product-images-item-tmpl")#

    </div>

</cfoutput>
