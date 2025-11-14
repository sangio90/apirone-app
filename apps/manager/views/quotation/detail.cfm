<cfoutput>
    <div id="quotation-detail-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
			<div class="col-6 text-end">
				#button( bind = "click:exportQuotation", size = "md", label = "Esporta preventivo" )#
				#button( bind = "click:list", size = "md", label = "Torna ai preventivi" )#
			</div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                
                <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-header-form">
                    
                    <section class="card">
                        
                        <div class="card-body">

                            <nav>
                                <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                    <button class="nav-link active" id="nav-general-tab" data-bs-toggle="tab" data-bs-target="##nav-general" type="button" role="tab">Dati generali</button>
                                    <button class="nav-link" id="nav-billing-tab" data-bs-toggle="tab" data-bs-target="##nav-billing" type="button" role="tab">Indirizzo di Fatturazione</button>
                                    <button class="nav-link" id="nav-shipment-tab" data-bs-toggle="tab" data-bs-target="##nav-shipment" type="button" role="tab">Indirizzo di Spedizione</button>
                                    <button class="nav-link" id="nav-products-tab" data-bs-toggle="tab" data-bs-target="##nav-products" type="button" role="tab" hidden>Prodotti</button>
                                    <!--- <button class="nav-link" id="nav-fiscal-tab" data-bs-toggle="tab" data-bs-target="##nav-fiscal" type="button" role="tab">Dati fiscali</button> --->
                                    <!--- <button class="nav-link" id="nav-print-tab" data-bs-toggle="tab" data-bs-target="##nav-print" type="button" role="tab">Stampa</button> --->
                                    <!--- <button class="nav-link" id="nav-discount-tab" data-bs-toggle="tab" data-bs-target="##nav-discount" type="button" role="tab">Sconti/Costi</button> --->
                                    <!--- <button class="nav-link" id="nav-assignment-tab" data-bs-toggle="tab" data-bs-target="##nav-assignment" type="button" role="tab">Assegnatario</button> --->
                                    <!--- <button class="nav-link" id="nav-plan-tab" data-bs-toggle="tab" data-bs-target="##nav-plan" type="button" role="tab" hidden>Planimentria</button> --->
                                    <!--- <button class="nav-link" id="nav-shipments-tab" data-bs-toggle="tab" data-bs-target="##nav-shipments" type="button" role="tab" hidden>Spedizioni</button> --->
                                </div>
                            </nav>
                            <div class="tab-content" id="nav-tabContent">
                                
                                <!--- 
                                    general 
                                --->
                                <div class="tab-pane quotation-panel fade show active" id="nav-general" role="tabpanel">

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Cliente </label>
                                            <input type="text" name="customer" class="form-control" id="customer"
                                                data-bind="source: crmCustomers, value: detailForm.data.customer"
                                                data-role="autocomplete"
                                                data-text-field="name"
                                                data-value-primitive="false"
                                                data-minlength="4"
                                                data-filter="contains"
                                            >
                                        </div>
                                        <div class="col-sm-1">
                                            <label class="control-label text-sm-end">Versione </label>
                                            <span class="form-control" data-bind="text: detailForm.data.versionNumber"></span>
                                        </div>
                                        <div class="col-sm-2">
                                            <label class="control-label text-sm-end">Numero </label>
                                            <input type="text" name="number" class="form-control" id="quotationNumber"
                                                data-bind="value: detailForm.data.quotationNumber"
                                                data-rule-required="true"
                                                required
                                            >
                                        </div>
                                        <div class="col-sm-2">
                                            <label class="control-label text-sm-end">Lingua </label>
                                            <select name="langId" class="form-control"
                                                data-placeholder="-- Seleziona lingua"
                                                data-bind="source: languages, value: detailForm.data.lang.id"
                                                data-value-field="id"
                                                data-text-field="name"
                                                required
                                            >
                                            </select>
                                        </div>
                                        <div class="col-sm-2">
                                            <label class="control-label text-sm-end">Data documento</label>
                                            <input type="date" class="form-control" data-bind="value: detailForm.data.quotationDate" disabled>
                                        </div>
                                        <div class="col-sm-2">
                                            <label class="control-label text-sm-end">Data validità </label>
                                            <input type="date" name="validityDate" class="form-control" data-bind="value: detailForm.data.validityDate" required>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Descrizione </label>
                                            <input type="text" name="name" class="form-control" id="name"
                                                data-bind="value: detailForm.data.name"
                                                data-rule-required="true"
                                                required
                                            >
                                        </div>
                                        <div class="col-sm-9">
                                            <label class="control-label text-sm-end">Note</label>
                                            <textarea name="note" class="form-control" rows="1" data-bind="value: detailForm.data.notes"></textarea>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-5">
                                            <label class="control-label text-sm-end">Opportunità </label>
                                            <input type="text" name="opportunity" class="form-control" id="opportunity"
                                                data-bind="source: crmOpportunities, value: detailForm.data.opportunity"
                                                data-role="autocomplete"
                                                data-text-field="name"
                                                data-value-primitive="false"
                                                data-minlength="4"
                                                data-filter="contains"
                                            >
                                        </div>
                                        <div class="col-sm-5">
                                            <label class="control-label text-sm-end">Lead </label>
                                            <input type="text" name="lead" class="form-control" id="lead"
                                                data-bind="source: crmLeads, value: detailForm.data.lead"
                                                data-role="autocomplete"
                                                data-text-field="fullName"
                                                data-value-primitive="false"
                                                data-minlength="4"
                                                data-filter="contains"
                                            >
                                        </div>
                                        <div class="col-sm-2">
                                            <label class="control-label text-sm-end">Stato </label>
                                            <select name="statusId" class="form-control"
                                                data-placeholder="-- Seleziona stato"
                                                data-bind="source: statuses, value: detailForm.data.status.id"
                                                data-value-field="id"
                                                data-text-field="name"
                                                required
                                            >
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group button-box">
                                        <div class="mt-2">
                                           <button class="btn btn-primary changeTab" id="billing">Fatturazione &raquo;</button>
                                           <!--- <button class="btn btn-primary changeTab" id="fiscal">Dati fiscali &raquo;</button> --->
                                           <button class="btn btn-primary" data-bind="click: save"><i class="fa fa-save"></i> Salva</button>
                                        </div>
                                    </div>        

                                </div>
                                <!---
                                    billing
                                --->
                                <div class="tab-pane quotation-panel fade" id="nav-billing" role="tabpanel">
                                    
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.name" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Ragione sociale</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.company" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Partita Iva</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.vatNumber" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Telefono</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.phone" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Indirizzo</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.street" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Città</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.city" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">CAP</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.postalCode" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Nazione</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.country" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Provincia</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.customer.state" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group button-box">
                                        <div class="mt-2">
                                           <button class="btn btn-default changeTab" id="general">&laquo; Precedente</button>
                                           <button class="btn btn-primary changeTab" id="shipment">Spedizione &raquo;</button>
                                           <button class="btn btn-primary" data-bind="click: save"><i class="fa fa-save"></i> Salva</button>
                                        </div>
                                    </div>                            

                                </div>     
                            
                                <!---
                                    shipment
                                --->
                                <div class="tab-pane quotation-panel fade" id="nav-shipment" role="tabpanel">
                                                 
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Indirizzo</label>
                                        <div class="col-sm-7">
                                            <select class="form-control"
                                                data-bind="source: detailForm.data.customer.shippingAddresses, value: detailForm.data.shippingAddress"
                                                data-value-field="id"
                                                data-text-field="name"
                                            >
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Indirizzo</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.via" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Città</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.citta" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">CAP</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.cap" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Nazione</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.paese" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-1 control-label text-sm-end pt-2">Provincia</label>
                                        <div class="col-sm-7">
                                            <input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.provincia" disabled>
                                        </div>
                                    </div>

                                    <div class="form-group button-box">
                                        <div class="mt-2">
                                           <button class="btn btn-default changeTab" id="billing">&laquo; Precedente</button>
                                           <button class="btn btn-primary changeTab" id="products">Prodotti &raquo;</button>
                                           <button class="btn btn-primary" data-bind="click: save"><i class="fa fa-save"></i> Salva</button>
                                        </div>
                                    </div> 
                                </div>

                                <!--- products --->
                                <div class="tab-pane quotation-panel fade" id="nav-products" role="tabpanel">
                                    <div class="form-group row mb-2" style="margin-left: -75px;">
                                        <div class="col-1 mb-2 text-end mt-2">
                                            <label>Zone: </label>
                                        </div>
                                        <div class="col-2 mb-2">
                                            <select class="form-control me-3"
                                                    data-bind="source: zones, value: detailForm.data.zone, events: { change: getItems }"
                                                    data-value-field="id"
                                                    data-text-field="name"
                                                    id="zones-selector"
                                            >
                                            </select>
                                        </div>
                                        <div class="col-2 mb-2 flex">
                                            <button type="button" class="btn btn-primary btn-sm" data-bind="click:openAddZoneModal">Aggiungi zona</button>                                        
                                            <button type="button" class="btn btn-danger btn-sm ms-2" data-bind="click:openDeleteZoneModal">Elimina zona</button>                                        
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
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
                                                    <div class="row">

                                                        <cfloop array="#prc.plates#" item="item">
                                                            <div class="quotation-item col-3">
                                                                <div class="quotation-item-inner">
                                                                    <div class="row">
                                                                        <div class="col-12" style="font-size: 14px; font-weight: bold;">
                                                                            #item.name#
                                                                        </div>
                                                                        <div class="col-12">
                                                                            <img src="/assets/fakes/img/plate.jpg" style="width: 80%;">
                                                                        </div>
                                                                        <div class="col-6">
                                                                            Quantità: #item.qty#<br>
                                                                            Prezzo: #item.price#<br>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>                                                        
                                                        </cfloop>

                                                    </div>
                                                </div>
                                                <div class="tab-pane fade" id="nav-signage" role="tabpanel">
                                                    <div data-role="listview" data-template="quotation-item-signage-preview-tmpl" data-bind="source: quotationItems">
                                                    </div>
                                                </div>
                                                <div class="tab-pane fade" id="nav-accessories" role="tabpanel">
                                                    <div data-role="listview" data-template="quotation-item-accessory-preview-tmpl" data-bind="source: quotationItems">
                                                    </div>
                                                </div>
                                            </div>
                                        </section>
                                    </div>
                                    <div class="form-group button-box">
                                        <div class="mt-2">
                                            <button class="btn btn-default changeTab" id="shipment">&laquo; Precedente</button>
                                            <button class="btn btn-primary" data-bind="click: save"><i class="fa fa-save"></i> Salva</button>
                                        </div>
                                    </div> 
                                    <div id="totalsFloatingTab" class="container py-3">
                                        <div class="d-flex align-items-center">
                                            <table style="width: 100%"></table>
                                        </div>
                                    </div>
                                </div>

                                <!---
                                    dati fiscali 
                                --->
                                <div class="tab-pane fade" id="nav-fiscal" role="tabpanel">
                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Listino </label>
                                            <select name="pricelist" class="form-control"
                                                data-placeholder="-- Seleziona listino"
                                                data-bind="source: pricelists, value: detailForm.data.pricelist"
                                                data-value-field="id"
                                                data-text-field="name"
                                            >
                                            </select>
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Pagamento </label>
                                            <select name="paymentMethod" class="form-control"
                                                data-placeholder="-- Seleziona metodo pagamento"
                                                data-bind="source: paymentMethods, value: detailForm.data.paymentMethod"
                                                data-value-field="id"
                                                data-text-field="name"
                                            >
                                            </select>
                                        </div>
                                        <div class="col-sm-3 pt-2">
                                            <label class="control-label text-sm-end pb-2">Pagamento personalizzato</label>
                                            <input type="text" name="custom_payment_method" class="form-control" id="custom_payment_method" data-bind="value: detailForm.data.customPaymentMethod">
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end pt-2">Aliquota IVA</label>
                                            <input type="text" name="vatNumber" class="form-control" id="vatNumber" data-bind="value: detailForm.data.vatNumber">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Valuta </label>
                                            <select name="currency" class="form-control"
                                                data-placeholder="-- Seleziona valuta"
                                                data-bind="source: currencies, value: detailForm.data.currency"
                                                data-value-field="id"
                                                data-text-field="name"
                                            >
                                            </select>
                                        </div>
                                        <div class="col-sm-3 pt-4">
                                            <button class="btn btn-default changeTab" id="general">&laquo; Precedente &raquo;</button>
                                            <button class="btn btn-primary changeTab" id="billing">Fatturazione &raquo;</button>
                                        </div>
                                    </div>

                                </div>

                                <!---
                                    print
                                --->
                                <div class="tab-pane fade" id="nav-print" role="tabpanel">
                                    <p>print</p>
                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">
                                           <button class="btn btn-default changeTab" id="shipment">&laquo; Precedente &raquo;</button>
                                           <button class="btn btn-primary changeTab" id="discount">Sconti/Costi &raquo;</button>
                                        </div>
                                    </div> 
                                </div>
                            
                                <!---
                                    cost / discount
                                --->
                                <div class="tab-pane fade" id="nav-discount" role="tabpanel">
                                    <p>price / discount</p>
                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">
                                           <button class="btn btn-default changeTab" id="print">&laquo; Precedente &raquo;</button>
                                           <button class="btn btn-primary changeTab" id="assignment">Assegnatario &raquo;</button>
                                        </div>
                                    </div> 
                                </div>

                                <!---
                                    assignment
                                --->
                                <div class="tab-pane fade" id="nav-assignment" role="tabpanel">

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Commerciale</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="REF">22%</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">
                                           <button class="btn btn-primary changeTab" id="discount">Precendete &raquo;</button>
                                            <button class="btn btn-primary" data-bind="click: save"><i class="fa fa-save"></i> Salva</button>

                                        </div>
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
    #template( view="jstemplate/quotation/quotation-item-signage-preview-tmpl" )#
    #template( view="jstemplate/quotation/quotation-item-accessory-preview-tmpl" )#
</cfoutput>

<script>
//TODO: direi di spostarlo nella app-
document.addEventListener("DOMContentLoaded", function () {
    // Cerca tutti i bottoni con classe `changeTab`
    document.querySelectorAll("button.changeTab").forEach(function (button) {
        button.addEventListener("click", function (e) {
            e.preventDefault();

            // Recupera l'id del bottone, es: "fiscal"
            const targetName = this.id;

            // Costruisce l'id del tab corrispondente
            const targetTabId = `nav-${targetName}-tab`;

            // Trova il pulsante di tab nella barra
            const tabTrigger = document.getElementById(targetTabId);

            if (tabTrigger) {
                const tab = new bootstrap.Tab(tabTrigger);
                tab.show();
            } else {
                console.warn(`Nessun tab trovato con id ${targetTabId}`);
            }
        });
    });

    document.querySelector('#nav-plate-tab').addEventListener("click", function (e) {
        e.preventDefault();
        $( "#addSignageButton" ).hide();
        $( "#addAccessoryButton" ).hide();
        $( "#addPlateButton" ).show();
    });
    document.querySelector('#nav-signage-tab').addEventListener("click", function (e) {
        e.preventDefault();
        $( "#addPlateButton" ).hide();
        $( "#addAccessoryButton" ).hide();
        $( "#addSignageButton" ).show();
    });
    document.querySelector('#nav-accessories-tab').addEventListener("click", function (e) {
        e.preventDefault();
        $( "#addPlateButton" ).hide();
        $( "#addSignageButton" ).hide();
        $( "#addAccessoryButton" ).show();
    });
});
</script>
<style>
    #totalsFloatingTab {
        position: fixed;
        bottom: 50px;
        background-color: #2771e8;
        width: 400px;
        color: white;
        padding: 10px 20px;
        border-radius: 10px;
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        z-index: 9999;
    }
    .quotation-panel {
        min-height: 55vh !important;
    }
    .button-box {
        position: absolute;
        bottom: 30px;
        right: 30px;
    }
</style>