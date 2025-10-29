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

                                    <div class="col-sm-6">


                                    </div>

                                    <div class="col-sm-6">
                                    
                                        <div class="row">
                                        
                                            <div class="col-12  d-flex gap-2 justify-content-end align-items-center">

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


                                            </div>

                                        </div>
                                    
                                    </div>

                                    <div class="col-sm-12 text-end">

                                        <a href=""
                                            class="underline"
                                            id="toggle-unlinked-attributes"
                                            data-bind="click:toggleUnlinked, text: textToggleLink">
                                        </a>

                                        |

                                        <a href="" class="underline" data-type="item" data-signage-config-item-id="0" 
                                            data-signage-config-item-name="Attributo radice" 
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

                                <form id="signage-config-item-grid-form">

                                    <!---
                                    TODO: remove productAttributesList
                                    #productAttributesList( 
                                        id="signage-config-item-items-grid", 
                                        type="product", 
                                        onDataBound="AP.product.items.onDataBound",
                                        pageSizes=false
                                    )#
                                    ---->

                                    #grid(
                                        id      = "signage-config-item-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '70px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Prezzo', width: '180px'},
                                            { 'field':'', 'title':'Aggiungi immagini', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi altri attributi', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                            { 
                                                'field'           :'', 
                                                'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                'width'           :'40px',
                                                'headerAttributes': { 'class': 'text-center' }
                                            }
                                        ]",
                                        source: "items",
                                        rowTemplate = "product/signage-config-item-item-row-tmpl"
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