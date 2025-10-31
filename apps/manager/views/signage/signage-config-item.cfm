<cfimport prefix="ap" taglib="/apps/utils/ctags">

<cfoutput>

    <div id="signage-config-item-detail-root">

        <div class="row">
            <div class="col-10">
                #pageTitle()#
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">

                    <div class="card-body row">

                        <div class="col-md-12">

                            <div>

                                <div class="row d-flex mb-2">

                                    <div class="col-sm-12">
                                    
                                        <div class="row">
                                        
                                            <div class="col-12  mb-3 text-end">
                                                <a class="underline" href="/manager/products/#prc.product.getId()#/detail" target="_blank">Vai all'articolo &raquo;</a>
                                            </div>
                                            <div class="col-12  d-flex gap-2 justify-content-end align-items-center">

                                                <form class="d-flex align-items-center justify-content-end" id="signage-config-item-change-form">

                                                    <label class="me-2">Dimensioni:</label>

                                                    <select name="itemId" class="form-control width-250 me-3">
                                                        <cfloop array="#prc.signageItems#" item="signage">
                                                            <cfloop array="#signage.getItems()#" item="item">
                                                                <option value="#item.getId()#"
                                                                    <cfif item.getId() EQ prc.signageConfigItemId>SELECTED</cfif>
                                                                >
                                                                    #signage.getFont().getName()# - #item.getSize().getName()#mm
                                                                </option>
                                                            </cfloop>
                                                        </cfloop>

                                                    </select>

                                                    <label class="me-2">Finitura:</label>

                                                    <select name="finishId" class="form-control width-250 me-3"
                                                        data-bind="events: { change: changeProduct }">
                                                        <option value="">-- non trovato</option>
                                                        <cfloop array="#prc.finishes#" item="item">
                                                            <option value="#item.getId()#"
                                                                <cfif item.getId() EQ prc.product.getFinish().getId()>SELECTED</cfif>
                                                            >
                                                                #item.getName()#
                                                            </option>
                                                        </cfloop>

                                                    </select>

                                                    <label class="me-2">Modello:</label>

                                                    <!----
                                                        il lettering è configurato per modello, quindi
                                                        non ha senso cambiare modello se non si cambia prodotto
                                                    ---->

                                                    <select name="modelId" class="form-control w-auto" disabled>
                                                        <option value="">-- non trovato</option>
                                                        <cfloop array="#prc.models#" item="item">
                                                            <option value="#item.getId()#"
                                                                <cfif item.getId() EQ prc.product.getModel().getId()>SELECTED</cfif>
                                                            >
                                                                #item.getCode()#
                                                            </option>
                                                        </cfloop>
                                                    </select>

                                                    <button type="submit" class="btn btn-primary ms-3" data-bind="events: { click: changeUri }">
                                                        Cambia
                                                    </button>

                                                </form>                                                

                                            </div>

                                        </div>
                                    
                                    </div>

                                </div>

                                <form id="signage-config-item-grid-form">

                                    #grid(
                                        id      = "signage-config-item-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '70px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                        ]",
                                        source: "items",
                                        rowTemplate = "signage/signage-config-item-product-item-list-row-tmpl"
                                    )#

                                </form>

                            </div>

                        </div>

                    </div>

                </section>

            </div>
        </div>

    </div>

    #view("component/list-modal")#

</cfoutput>