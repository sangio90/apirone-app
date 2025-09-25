<cfoutput>
    <div id="reassign-component-root">

        <div class="row">
            <div class="col-6 pt-2">
				#pageTitle()#
            </div>
        </div>

        <div class="row">
			<div class="col-lg-12">
				<section class="card">
                    <form id="reassign-component-form">
                        <div class="card-body">
                            <div class="mb-3 row">
                                <div class="col-3">
                                    <label>Categoria</label>
                                    <div>
                                        <select class="form-control me-2" name="category" data-bind="value: category">
                                            <option value="">Seleziona parametro dove cercare</option>
                                            <option value="rawProductId">Prodotto</option>
                                            <option value="variantId">Variante</option>
                                            <option value="colorId">Colore</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="col-3">
                                    <label>Vecchio parametro</label>
                                    <input class="form-control" name="oldParam" data-bind="value: oldParam">
                                </div>
                                <div class="col-3">
                                    <label>Nuovo parametro</label>
                                    <input class="form-control" name="newParam" data-bind="value: newParam">
                                </div>
                                <div class="col-3">
                                    <div class="mt-4">
                                        <button type="button" class="btn btn-primary btn-sm" data-bind="click:save">
                                            <i class="fas fa-save"></i> Riassegna
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <div class="col-12">
                                    <span id="resultMessage"></span>
                                </div>
                            </div>
                        </div>
                    </form>
				</section>
			</div>
		</div>
    </div>
</cfoutput>