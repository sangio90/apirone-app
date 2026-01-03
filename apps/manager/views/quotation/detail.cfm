<cfoutput>
    <div id="quotation-detail-root">
        <div class="row mb-3">
            <div class="col-lg-3">
                <h2>#prc.title#</h2>
            </div>
			
            <div class="col-9 text-end mt-3">
				#button( href = "/manager/quotations", size = "sm", label = "Torna ai preventivi", icon="arrow-left", class="me-4" )#
				#button( bind = "click:showHeader", size = "sm", label = "Dettaglio", icon="edit" )#
                #button( bind = "click:exportProducts", size = "sm", label = "Esporta articoli", icon="file-export", class="export-button" )#
                #button( bind = "click:export", size = "sm", label = "Esporta preventivo", icon="file-export", class="export-button" )#
				#button( bind = "click:openStatusModal", size = "sm", label = "Status: #prc.quotation.getStatusHistory().getStatus().getName()#", icon="check-circle" )#
				#button( bind = "click:openPrintModal", size = "sm", label = "Stampa", icon="print" )#
			</div>
            <div class="export-button-tooltip col-6 text-end">
				<p class="export-button-tooltip" style="color: red; display: none">Il preventivo è già stato esportato</p>
			</div>
        
        </div>

        <div class="row">
            <div class="col-lg-12">

                <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-detail-header-form">

                    <section class="card">

                        <div class="card-body">

                            <div class="row">

                                <div class="col-6">

                                    <div class="mb-3 d-flex ">
                                        <div class="row align-items-center">
                                        
                                            <div class="col-12 d-flex align-items-center">
                                                <label class="me-2">Zone: </label>
                                                <select 
                                                    class="form-control me-3"
                                                    data-bind="source: zones, value: detailForm.data.zone, events: { change: getItems }"
                                                    data-value-field="id"
                                                    data-text-field="name"
                                                    id="zones-selector">
                                                </select>
                                                <div class="col-2 d-flex">
                                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:openAddZoneModal">Aggiungi zona</button>
                                                    <button type="button" class="btn btn-danger btn-sm ms-2" data-bind="click:openDeleteZoneModal">Elimina zona</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                </div>

                            </div>

                            <div class="form-group row mb-3">
                                <section class="card">
                                    <div class="card-body">
                                    <nav>
                                        <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                            <div class="col-4 d-flex">
                                                <button class="nav-link active" data-bs-toggle="tab" type="button" role="tab" 
                                                    id="nav-plate-tab" 
                                                    data-type="PLA"
                                                    data-bs-target="##nav-plate" 
                                                    data-bind="click:changeType">
                                                    Placche
                                                </button>
                                                
                                                <button class="nav-link" data-bs-toggle="tab" type="button" role="tab" 
                                                    id="nav-signage-tab" 
                                                    data-type="SEG"
                                                    data-bs-target="##nav-signage" 
                                                    data-bind="click:changeType">
                                                    Segnaletiche
                                                </button>
                                                
                                                <button class="nav-link" data-bs-toggle="tab" type="button" role="tab" 
                                                    id="nav-accessories-tab"
                                                    data-type="ACC"
                                                    data-bs-target="##nav-accessories" 
                                                    data-bind="click:changeType">
                                                    Accessori
                                                </button>

                                            </div>
                                            <div class="col-8 text-end mb-2">
                                                <button id="qt-add-plate" type="button" class="btn btn-primary" data-bind="click:addPlate">Aggiungi placca</button>
                                                <button id="qt-add-signage" type="button" class="btn btn-primary" data-bind="click:addSignage" style="display: none" disabled>Aggiungi segnaletica</button>
                                                <button id="qt-add-accessory" type="button" class="btn btn-primary" data-bind="click:addAccessory" style="display: none" disabled>Aggiungi accessorio</button>
                                            </div>
                                        </div>
                                    </nav>
                                    <div class="tab-content" id="nav-tabContent">
                                        <div class="tab-pane fade show active" id="nav-plate" role="tabpanel">
                                            <div data-bind="visible: showItems">
                                                <div data-template="quotation-item-plate-preview-tmpl" data-bind="source: quotationItems" class="row">
                                                </div>
                                            </div>
                                            <div data-bind="visible: hideItems">
                                                <div class="qt-no-items">NESSUNA PLACCA</div>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="nav-signage" role="tabpanel">
                                            <div data-bind="visible: showItems">
                                                <div data-template="quotation-item-signage-preview-tmpl" data-bind="source: quotationItems" class="row">
                                                </div>
                                            </div>
                                            <div data-bind="visible: hideItems">
                                                <div class="qt-no-items">NESSUNA SEGNALATICA</div>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="nav-accessories" role="tabpanel">
                                            <div data-bind="visible: showItems">
                                                <div data-template="quotation-item-accessory-preview-tmpl" data-bind="source: quotationItems" class="row">
                                                </div>
                                            </div>
                                            <div data-bind="visible: hideItems">
                                                <div class="qt-no-items">NESSUN ACCESSORIO</div>
                                            </div>
                                        </div>
                                        <!---
                                        <div class="tab-pane fade" id="nav-articles" role="tabpanel">
                                            <div data-template="quotation-item-article-preview-tmpl" data-bind="source: quotationItems" class="row">
                                            </div>
                                        </div>
                                        --->
                                    </div>
                                </section>
                            </div>

                        </div>

                    </section>

                </form>

            </div>

        </div>

    </div>
    
    #view( "quotation/header-modal" )#

    #view( "quotation/signage-modal" )#
    #view( "quotation/accessory-modal" )#
    #view( "quotation/plate-modal" )#

    #view( "quotation/zone-modal" )#
    #view( "quotation/print-modal" )#
    #view( "quotation/status-modal" )#

    #view( "quotation/totals" )#

    #template( view="jstemplate/quotation/quotation-item-plate-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-item-signage-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-item-accessory-preview-tmpl" )#
    
    #template( view="jstemplate/quotation/quotation-pricing-totals-item-tmpl" )#

</cfoutput>
