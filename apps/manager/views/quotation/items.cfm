<cfoutput>
    <div id="quotation-items-root">
        <div id="quotation-items">
            <div class="row mb-3">
                <div class="col-lg-8">
                    <h2>#prc.title#</h2>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-12">

                    <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-detail-form">

                        <section class="card">

                            <div class="card-body">

                                <div class="row">
                                <div class="col-3">
                                    <select class="form-control">
                                        <option>zona 1</option>
                                        <option>-- sottozona 1.1</option>
                                        <option>-- sottozona 1.2</option>
                                        <option>zona 2</option>
                                        <option>-- sottozona 2.1</option>
                                        <option>-- sottozona 2.2</option>
                                        <option>zona 3</option>
                                    </select>
                                </div>
                                </div>


                                <nav>
                                    <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                        <button class="nav-link" id="nav-general-tab" data-bs-toggle="tab" data-bs-target="##nav-general" type="button" role="tab">Dati generali</button>
                                        <button class="nav-link" id="nav-fiscal-tab" data-bs-toggle="tab" data-bs-target="##nav-fiscal" type="button" role="tab">Dati fiscali</button>
                                        <button class="nav-link" id="nav-print-tab" data-bs-toggle="tab" data-bs-target="##nav-print" type="button" role="tab">Stampa</button>
                                        <button class="nav-link" id="nav-discount-tab" data-bs-toggle="tab" data-bs-target="##nav-discount" type="button" role="tab">Sconti/Costi</button>
                                        <button class="nav-link" id="nav-billing-tab" data-bs-toggle="tab" data-bs-target="##nav-billing" type="button" role="tab">Fatturazione</button>
                                        <button class="nav-link" id="nav-shipment-tab" data-bs-toggle="tab" data-bs-target="##nav-shipment" type="button" role="tab">Spedizione</button>
                                        <button class="nav-link" id="nav-assignment-tab" data-bs-toggle="tab" data-bs-target="##nav-assignment" type="button" role="tab">Assegnatario</button>
                                        <button class="nav-link" id="nav-plan-tab" data-bs-toggle="tab" data-bs-target="##nav-plan" type="button" role="tab">Planimentria</button>
                                        <button class="nav-link active" id="nav-products-tab" data-bs-toggle="tab" data-bs-target="##nav-products" type="button" role="tab">Prodotti</button>
                                        <button class="nav-link" id="nav-shipments-tab" data-bs-toggle="tab" data-bs-target="##nav-shipments" type="button" role="tab">Spedizioni</button>
                                    </div>
                                </nav>
                                <div class="tab-content" id="nav-tabContent">

                                    <nav>
                                        <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                            <button class="nav-link active" id="nav-plates-tab" data-bs-toggle="tab" data-bs-target="##nav-plates" type="button" role="tab">Placche</button>
                                            <button class="nav-link" id="nav-signales-tab" data-bs-toggle="tab" data-bs-target="##nav-signales" type="button" role="tab">Segnaletica</button>
                                            <button class="nav-link" id="nav-accessories-tab" data-bs-toggle="tab" data-bs-target="##nav-accessories" type="button" role="tab">Accessori</button>
                                        </div>
                                    </nav>
                                    <div class="tab-content" id="nav-tabContent">

                                        <div class="tab-pane fade show active" id="nav-plates" role="tabpanel">

                                            <div class="row">

                                                <div class="col-3">

                                                    <div class="mb-3 ">
                                                        <h2>Zone</h2>
                                                        <button type="button" class="btn btn-primary btn-sm" onclick="javascript:addZone()">Aggiungi zona</button>
                                                    </div>

                                                    <!---
                                                    <cfloop array="#prc.zones#" item="item">

                                                        <div class="quotation-zone">
                                                            <div class="row">
                                                                <div class="col-10" style="font-size: 16px; font-weight: bold;">
                                                                    #item.name#
                                                                </div>
                                                                <div class="col-2">
                                                                    #item.qty#
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </cfloop>
                                                    ---->

                                                </div>

                                                <div class="col-9">

                                                    <div class="row">

                                                        <div class="col-12">
                                                            <button type="button" class="col-2 btn btn-primary btn-sm mr-2" data-bind="click:addPlate">Aggiungi placca</button>

                                                            <button type="button" class="col-2 btn btn-primary btn-sm" data-bind="click:addSignage">Aggiungi segnaletica</button>
                                                        </div>

                                                        <cfloop array="#prc.plates#" item="item">

                                                            <div class="quotation-plate col-3">
                                                                <div class="quotation-plate-inner">
                                                                    <div class="row">
                                                                        <div class="col-12" style="font-size: 14px; font-weight: bold;">
                                                                            #item.name#
                                                                        </div>
                                                                        <div class="col-12">
                                                                            <img src="/assets/fakes/img/plate.jpg" style="width: 100%;">
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

                                            </div>

                                        </div>

                                    </div>

                                </div>

                            </div>

                        </section>

                    </form>

                </div>

            </div>

        </div>

        <div class="modal hide fade" tabindex="-1" id="add-zona-modal">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title">Aggiungi zona</h3>
                    </div>
                    <div class="modal-body">

                        <div class="row">

                            <div class="col-12">

                                <input class="form-control" name="zona">

                            </div>

                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary">Aggiungi</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal hide fade" tabindex="-1" id="add-plate-modal">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 class="modal-title">Aggiungi placca</h3>
                    </div>
                    <div class="modal-body">

                        <div class="row">

                            <div class="col-12">

                                <input class="form-control" name="zona">

                            </div>

                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary">Aggiungi</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    #view( "quotation/signage-modal" )#
    <!--- #view( "quotation/plate-modal" )# --->
    #view( "quotation/plate-modal-vue" )#
</cfoutput>
