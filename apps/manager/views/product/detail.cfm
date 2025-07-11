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

                        <div class="col-md-4">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>
                        
                        <div class="col-md-8 mb-4" id="product-config-row">

                            <form class="d-flex align-items-center justify-content-end" id="product-change-form">
                                
                                <label class="me-2">Finitura:</label>

                                <select name="finishId" class="form-control w-250 me-4" 
                                    data-bind="events: { change: loadSizes }"
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

                                <label class="me-2">Dimensione:</label>

                                <select name="sizeId" class="form-control w-auto" data-bind="events: { change: change }">
                                </select>

                            </form>

                        </div>

                        <div class="col-md-12">

                            <!--- 
                                data-bind="visible: showItems" 
                                TODO: add this. remove from above menu 
                            ---->
                            <div >

                                <div class="row d-flex align-items-center mb-2">

                                    <div class="col-sm-12">

                                        <p>
                                            - <a href=""
                                                class="underline"
                                                data-type="lineSize" 

                                                data-size-id="#prc.size.getId()#"
                                                data-size-name="#prc.size.getCode()#"

                                                data-line-id="#prc.line.getId()#"
                                                data-line-name="#prc.line.getName()#"
                                                
                                                data-bind="click: openComponentsList">
                                                    Componenti per #prc.line.getName()# / #prc.size.getCode()# &raquo;
                                                </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="product" 

                                                data-product-id="#rc.id#"
                                                data-product-name="#prc.subtitle# / #prc.title#"
                                                
                                                data-bind="click: openComponentsList">
                                                    Componenti base per questa placca &raquo;
                                                </a>
                                            <br>

                                            - <a href=""
                                                class="underline"
                                                data-type="product" 
                                                data-bind="click:openImagesList">
                                                Aggiungi immagini per questa placca &raquo;
                                            </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="product" 
                                                data-bind="click:openReorderingModal">
                                                Riordina attributi &raquo;
                                            </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="product" 
                                                data-bind="click:openFruitItemsImagesModal">
                                                Tutte le combinazioni &raquo;
                                            </a>
                                        </p>
        
                                        <!---
                                        <div class="mb-3 box-search-small"> 
        
                                            <form id="finish-grid-search-form" 
                                                class="d-flex align-items-center justify-content-end" 
                                                data-bind:'events: { submit: search }'>
        
                                                <input name="str" placeholder="Cerca..." class="form-control me-2" type="text">
        
                                                #searchButton( bind="click:search" )#
                                            
                                            </form>
        
                                        </div>
                                        ----->
        
                                    </div>
                                    <div class="col-sm-12 text-end">

                                        <a href=""
                                            class="underline"
                                            data-type="item" 

                                            data-product-id="0"
                                            data-product-name="Attributo radice"
                                        
                                            data-bind="click: openAttributesList">
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

                            <!---
                            <div class="py-3" data-bind="invisible: showItems" style="display:none">
                                <hr class="mb-5">
                                <p class="text-center pt-3">
                                    Nessuna configurazione presente
                                </p>
                            </div>
                            ---->

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
    <!---
    #view("fruit/fruit-items-products-images-modal")#
    ---->
</cfoutput>