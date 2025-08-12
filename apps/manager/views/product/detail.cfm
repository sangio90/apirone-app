<cfimport prefix="ap" taglib="/apps/utils/ctags">

<cfoutput>

    <div id="product-detail-root">

        <div class="row">
            <div class="col-10">
                #pageTitle()#
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">

                    <div class="card-body row">

                        <div class="col-md-4 mb-3">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>

                        <div class="col-md-8 mb-4" id="product-config-row">

                            <cfif prc.product.getCategory().getMode().getId() <> "BAS">

                                <form class="d-flex align-items-center justify-content-end" id="product-change-form">

                                    <label class="me-2">Finitura:</label>

                                    <select name="finishId" class="form-control w-250 me-4"
                                        data-bind="events: { change: loadModels }"
                                            <!--- data-bind="events: { change: change }" ---->
                                        >

                                        <cfloop array="#prc.finishes#" item="item">
                                            <option value="#item.getId()#"
                                                <cfif item.getId() EQ prc.finish.getId()>SELECTED</cfif>
                                            >
                                                #item.getName()#
                                            </option>
                                        </cfloop>

                                    </select>

                                    <label class="me-2">Modello:</label>

                                    <select name="modelId" class="form-control w-auto" data-bind="events: { change: change }">
                                    </select>

                                </form>

                            </cfif>

                        </div>

                        <div class="col-md-12">

                            <div>

                                <div class="row d-flex align-items-center mb-2">

                                    <div class="col-sm-12">

                                        <p>

                                            <cfif prc.product.getCategory().getType().getId() == "SEG">
                                                - <a href="/manager/signages/row-config?lineId=#prc.line.getId()#&modelId=#prc.model.getId()#&categoryId=#prc.product.getCategory().getId()#" target="_blank" class="underline">
                                                    Configurazione font #prc.line.getName()# / #prc.model.getCode()# &raquo;
                                                    </a>

                                                <br>
                                            </cfif>

                                            <cfif prc.product.getCategory().getMode().getId() <> "BAS">
                                                - <a href="" class="underline" data-type="lineModel"
                                                    data-model-id="#prc.model.getId()#"
                                                    data-model-name="#prc.model.getCode()#"
                                                    data-line-id="#prc.line.getId()#"
                                                    data-line-name="#prc.line.getName()#"
                                                    data-bind="click:openComponentsList">
                                                        Componenti per #prc.line.getName()# / #prc.model.getCode()# &raquo;
                                                    </a>
                                                
                                                <br>
                                            </cfif>

                                            - <a href="" class="underline" 
                                                data-type="product" 
                                                data-product-id="#rc.id#"
                                                data-product-name="#prc.textLink#"
                                                data-bind="click: openComponentsList">
                                                    #prc.textLink# &raquo;
                                                </a>
                                                
                                            <br>

                                            - <a href="" class="underline"
                                                data-type="product"
                                                data-bind="click: openReorderingModal">
                                                    Riordina attributi &raquo;
                                                </a>

                                            <br>

                                            <cfif prc.product.getCategory().getMode().getId() <> "BAS">

                                                - <a href="" class="underline"
                                                    data-type="product"
                                                    data-bind="click:openImagesList">
                                                        Aggiungi immagini per questo articolo &raquo;
                                                    </a>

                                                <br>

                                                - <a href="/manager/products/#rc.id#/combinations" class="underline"
                                                    data-type="product"
                                                    data-bind="click:open">
                                                        Tutte le combinazioni &raquo;
                                                    </a>

                                            </cfif>
                                        </p>

                                    </div>
                                    <div class="col-sm-12 text-end">

                                        <a href=""
                                            class="underline"
                                            data-type="item"

                                            data-product-id="0"
                                            data-product-name="Attributo radice"

                                            data-bind="click:openAttributesList">
                                                Aggiungi attributo di base
                                        </a>

                                        #deleteButton(
                                            bind  = "click:removeAttributes",
                                            size  = "sm",
                                            class = "ms-2"
                                        )#

                                    </div>

                                </div>

                                <!---- <ap:productItemList grid="#variables.grid#"> ---->

                                <form id="product-grid-form">

                                    #productAttributesList( id="product-items-grid", type="product" )#

                                </form>


                            </div>

                        </div>

                    </div>

                </section>

            </div>
        </div>

        #view("product/attributes-list-modal")#
        #view("product/images-list-modal")#
        #view("product/sorting-modal")#

    </div>

    #view("attribute/detail-modal")#
    #view("component/list-modal")#

</cfoutput>