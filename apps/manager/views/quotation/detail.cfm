<cfoutput>
    <div id="quotation-detail-root">
        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
			
            <div class="col-6 text-end mt-3">
				#button( bind = "click:list", size = "sm", label = "Torna ai preventivi" )#
				#button( bind = "click:exportQuotation", size = "sm", label = "Esporta preventivo" )#
				#button( bind = "click:openPrintModal", size = "sm", label = "Stampa preventivo" )#
			</div>
        
        </div>

        <div class="row">
            <div class="col-lg-12">

                <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-header-form">

                    <section class="card">

                        <div class="card-body">

                            <div>

                                <div class="form-group row mb-3" style="margin-left: -75px;">
                                    <div class="col-1 mb-3 text-end mt-2">
                                        <label>Zone: </label>
                                    </div>
                                    <div class="col-2 mb-3">
                                        <select class="form-control me-3"
                                                data-bind="source: zones, value: detailForm.data.zone, events: { change: getItems }"
                                                data-value-field="id"
                                                data-text-field="name"
                                                id="zones-selector"
                                        >
                                        </select>
                                    </div>
                                    <div class="col-2 mb-3 flex">
                                        <button type="button" class="btn btn-primary btn-sm" data-bind="click:openAddZoneModal">Aggiungi zona</button>
                                        <button type="button" class="btn btn-danger btn-sm ms-2" data-bind="click:openDeleteZoneModal">Elimina zona</button>
                                    </div>
                                </div>
                                <div class="form-group row mb-3">
                                    <section class="card">
                                        <div class="card-body">
                                        <nav>
                                            <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                                <div class="col-4 flex" id="quotationItemsMode">
                                                    <button class="nav-link active" id="nav-plate-tab" data-bs-toggle="tab" data-bs-target="##nav-plate" type="button" role="tab" data-bind="click:changeMode">Placche</button>
                                                    <button class="nav-link" id="nav-signage-tab" data-bs-toggle="tab" data-bs-target="##nav-signage" type="button" role="tab" data-bind="click:changeMode">Segnaletiche</button>
                                                    <button class="nav-link" id="nav-accessories-tab" data-bs-toggle="tab" data-bs-target="##nav-accessories" type="button" role="tab" data-bind="click:changeMode">Accessori</button>
                                                </div>
                                                <div class="col-6 text-start">
                                                    <button id="addPlateButton" type="button" class="col-3 btn btn-primary btn-sm mr-2" data-bind="click:addPlate">Aggiungi placca</button>
                                                    <button id="addSignageButton" type="button" class="col-4 btn btn-primary btn-sm" data-bind="click:addSignage" style="display: none" disabled>Aggiungi segnaletica</button>
                                                    <button id="addAccessoryButton" type="button" class="col-4 btn btn-primary btn-sm" data-bind="click:addAccessory" style="display: none" disabled>Aggiungi accessorio</button>
                                                </div>
                                            </div>
                                        </nav>
                                        <div class="tab-content" id="nav-tabContent">
                                            <div class="tab-pane show active" id="nav-plate" role="tabpanel">
                                                <div data-template="quotation-item-signage-preview-tmpl" data-bind="source: quotationItems">
                                                </div>
                                            </div>
                                            <div class="tab-pane fade" id="nav-signage" role="tabpanel">
                                                <div data-template="quotation-item-signage-preview-tmpl" data-bind="source: quotationItems">
                                                </div>
                                            </div>
                                            <div class="tab-pane fade" id="nav-accessories" role="tabpanel">
                                                <div data-template="quotation-item-accessory-preview-tmpl" data-bind="source: quotationItems">
                                                </div>
                                            </div>
                                        </div>
                                    </section>
                                </div>

                                #view( "quotation/totals" )#
                                
                            
                            </div>

                            <div class="form-group button-box">
                                <div class="mt-2">
                                    <button class="btn btn-primary" data-bind="click:save"><i class="fa fa-save"></i> Salva</button>
                                </div>
                            </div>

                        </div>

                    </section>

                </form>

            </div>

        </div>

    </div>
    
    #view( "quotation/signage-modal" )#
    #view( "quotation/accessory-modal" )#
    #view( "quotation/plate-modal" )#
    #view( "quotation/zone-modal" )#
    #view( "quotation/print-modal" )#

    #template( view="jstemplate/quotation/quotation-item-plate-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-item-signage-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-item-accessory-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-pricing-totals-item-tmpl" )#
</cfoutput>
