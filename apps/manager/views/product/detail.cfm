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

                    <div class="card-body">

                        <div class="mb-0 row" id="product-config-row">

                            <cfif prc.product.getCategory().getMode().getId() <> "BAS">

                                <form class="d-flex align-items-center justify-content-end" id="product-change-form">

                                    <label class="me-2">Finitura:</label>

                                    <select name="finishId" class="form-control width-250 me-4"
                                        data-bind="events: { change: changeUri }">
                                        <option value="">-- non trovato</option>
                                        <cfloop array="#prc.finishes#" item="item">
                                            <option value="#item.getId()#"
                                                <cfif item.getId() EQ prc.finish.getId()>SELECTED</cfif>
                                            >
                                                #item.getName()#
                                            </option>
                                        </cfloop>

                                    </select>

                                    <label class="me-2">Modello:</label>

                                    <select name="modelId" class="form-control w-auto" 
                                        data-bind="events: { change: changeUri }">
                                        <option value="">-- non trovato</option>
                                        <cfloop array="#prc.models#" item="item">
                                            <option value="#item.getId()#"
                                                <cfif item.getId() EQ prc.model.getId()>SELECTED</cfif>
                                            >
                                                #item.getCode()#
                                            </option>
                                        </cfloop>
                                    </select>

                                </form>

                            </cfif>

                        </div>

                        <div class="row">

                            <div class="col-12">

                                <ul class="nav nav-tabs" role="tablist">
                                    <li class="nav-item active">
                                        <a class="nav-link active" role="tab" data-bs-toggle="tab" aria-selected="true"
                                            id="product-general-tab"  
                                            href="##product-general" 
                                            aria-controls="product-general">
                                                Generale
                                        </a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link" role="tab"data-bs-toggle="tab"  aria-selected="true"
                                            id="product-detail-tab"  
                                            href="##product-detail" 
                                            aria-controls="product-detail">
                                                Altri dati
                                        </a>
                                    </li>
                                </ul>

                            </div>

                        </div>

                        <div class="row mb-3">

                            <div class="col-12">

                                <div class="tab-content">

                                    <div class="tab-pane p-2 fade show active" id="product-general" role="tabpanel" aria-labelledby="product-general-tab">

                                        <div class="col-md-4 mb-3">
                                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                                        </div>

                                        <div class="col-md-12">

                                            <div>

                                                <div class="row d-flex mb-2">

                                                    <div class="col-sm-6">

                                                        <p>

                                                            <cfif prc.product.getCategory().getType().getId() == "SEG">
                                                                - <a href="/manager/signages/rows-config?lineId=#prc.line.getId()#&modelId=#prc.model.getId()#&categoryId=#prc.product.getCategory().getId()#" target="_blank" class="underline">
                                                                    Configurazione font #prc.line.getName()# / #prc.model.getCode()# &raquo;
                                                                    </a>

                                                                <br>
                                                            </cfif>

                                                            <cfif prc.product.getCategory().getMode().getId() <> "BAS">
                                                                - <a href="" class="underline" data-type="catalogBundle"
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

                                                            - <a href="" class="underline"
                                                                data-type="product"
                                                                data-bind="click:openImagesList">
                                                                    Aggiungi immagini per questo articolo &raquo;
                                                                </a>

                                                            <br>

                                                            - <a href="/manager/products/#rc.id#/combinations" class="underline">
                                                                    Tutte le combinazioni &raquo;
                                                                </a>
                                                        </p>

                                                    </div>

                                                    <div class="col-sm-6">
                                                    
                                                        <div class="row">
                                                        
                                                            <div class="col-12  d-flex gap-2 justify-content-end align-items-center">

                                                                <div id="product-simulate-loading"></div>
                                                                
                                                                <input class="form-control col-sm-2 text-end" style="width: 100px" id="product-simulate-quantity" value="1" type="number" min="1" />

                                                                #button(
                                                                    label="Simula prezzo",
                                                                    bind  = "click:simulatePrice",
                                                                    size  = "sm",
                                                                    class = "ms-2"
                                                                )#

                                                            </div>

                                                        </div>
                                                    
                                                    </div>

                                                </div>

                                            </div>

                                        </div>

                                    </div>

                                    <div class="tab-pane p-2 fade" id="product-detail" role="tabpanel" aria-labelledby="product-detail-tab">
                                        
                                        <div class="row">

                                            <div class="col-md-6 mb-3">

                                                <form id="product-detail-form">

                                                    <div class="form-group pb-3 row align-items-center">
                                                        <label class="col-3" for="qta">Status</label>
                                                        <div class="col-9">
                                                            <select type="text" class="form-control" name="statusId"
                                                                required
                                                                data-bind="source: statuses, value: product.status.id"
                                                                data-value-field="id"
                                                                data-text-field="name">
                                                            </select>
                                                        </div>
                                                    </div>

                                                    <div class="form-group pb-3 row align-items-center">
                                                        <label class="col-3" for="qta">Quantità minima</label>
                                                        <div class="col-9">
                                                            <input class="form-control col-9" name="minQuantity" id="minQuantity" 
                                                                data-bind="value: product.minQuantity"
                                                                >
                                                        </div>
                                                    </div>

                                                    <div class="form-group pb-3 row align-items-center">
                                                        <label class="col-3" for="qta">Quantità massima</label>
                                                        <div class="col-9">
                                                            <input class="form-control col-9" name="maxQuantity" id="maxQuantity" 
                                                                data-bind="value: product.maxQuantity"
                                                                >
                                                        </div>
                                                    </div>

                                                    <div class="form-group pb-3 row align-items-center">
                                                        <label class="col-3" for="special">Speciale</label>
                                                        <div class="col-9">
                                                            <input class="me-4 ms-2" type="checkbox" name="special" id="special" 
                                                                data-bind="checked: product.special">                                                        
                                                        </div>
                                                    </div>

                                                    <div class="form-group pb-3 row align-items-center">
                                                        <label class="col-3" for="special"></label>
                                                        <div class="col-9 d-flex align-items-center">
                                                            #saveButton( bind="click:save", size="sm" )#
                                                            <div class="status errors-counter ms-2"></div>
                                                        </div>
                                                    </div>
                                                
                                                </form>

                                            </div>

                                        </div>


                                    </div>

                                </div>
                            
                            </div>

                        </div>

                        <div class="row">

                            <!---- product grid ---->

                            <div class="col-6 mb-2">

                                <a href=""
                                    class="underline"
                                    id="toggle-unlinked-attributes"
                                    data-bind="click:toggleUnlinked, text: textToggleLink">
                                </a>

                                |

                                <a href="" class="underline" data-type="item" data-product-id="0" 
                                    data-product-name="Attributo radice" 
                                    data-bind="click:openAttributesList">
                                    Aggiungi attributo di base
                                </a>

                            </div>                                    

                            <div class="text-end col-6 mb-2">

                                #updateButton(
                                    bind  = "click:updateItems",
                                    size  = "sm",
                                    class = "ms-2"
                                )#

                                #deleteButton(
                                    bind  = "click:removeAttributes",
                                    size  = "sm",
                                    class = "ms-2"
                                )#

                            </div>                                    

                            <form id="product-grid-form">

                                <!---
                                TODO: remove productAttributesList
                                #productAttributesList( 
                                    id="product-items-grid", 
                                    type="product", 
                                    onDataBound="AP.product.items.onDataBound",
                                    pageSizes=false
                                )#
                                ---->

                                #grid(
                                    id      = "product-items-grid",
                                    class   = "no-pager",
                                    columns = "[
                                        { 'field':'Id', 'title':'ID', width: '70px' },
                                        { 'field':'name', 'title':'Attributo' },
                                        { 'field':'', 'title':'Prezzo', width: '180px'},
                                        { 'field':'', 'title':'Aggiungi immagini', width: '55px'},
                                        { 'field':'', 'title':'Aggiungi altri attributi', width: '55px'},
                                        { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                        { 'field':'', 'title':'Importante', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
                                    source: "items",
                                    rowTemplate = "product/product-item-row-tmpl"
                                )#

                            </form>

                            <!---- // product grid ---->

                        </div>                        
                    
                    </div>

                </section>

            </div>
        </div>

        #view("product/attributes-list-modal")#
        <!--- #view("product/images-list-modal")# ---->
        #view("product/sorting-modal")#

    </div>

    #view("attribute/detail-modal")#
    #view("component/list-modal")#
    #view("file/list-modal")#
    #view("price/list-modal")#
    #view("price/simulate-modal")#

</cfoutput>