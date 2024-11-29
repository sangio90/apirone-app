<cfoutput>

    <div id="combination-detail-root">

        #pageTitle()#

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="col-md-12">
                            <button class="btn btn-primary btn-sm" data-bind="click:showAttributesList" data-item-id="0">Aggiungi attributo &raquo;</button>
                            <button class="btn btn-primary btn-sm" data-bind="click:listImages">Aggiungi immagine &raquo;</button>
                        </div>

                        <div class="col-md-12 mb-4" id="combination-config-row">

                            <form class="d-flex align-items-center justify-content-end" id="combination-change-form">

                                <label class="me-2">Dimensione:</label>

                                <select name="sizeId" class="form-control w-auto me-4" data-bind="events: { change: loadFishes }" >
                                    <cfloop array="#prc.sizes#" item="item">
                                        <option value="#item.getId()#" 
                                            <cfif item.getId() EQ prc.sizeId>SELECTED</cfif>
                                        >
                                            #item.getCode()#
                                        </option>
                                    </cfloop>
                                </select>
                                
                                <label class="me-2">Finitura:</label>

                                <select name="finishId" class="form-control w-200" data-bind="events: { change: change }" >
                                </select>
                            </form>

                        </div>

                        <div class="col-md-12">

                            <div data-bind="visible: showItems">

                                <div class="row d-flex align-items-center mb-2">

                                    <div class="col-sm-9">
        
                                        <div class="mb-3 box-search-small"> 
        
                                            <form id="finish-grid-search-form" 
                                                class="d-flex align-items-center justify-content-end" 
                                                data-bind:'events: { submit: search }'>
        
                                                <input name="str" placeholder="Cerca" class="form-control me-2" type="text">
        
                                                #searchButton( bind="click:search" )#
                                            
                                            </form>
        
                                        </div>
        
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="float-end">
                                            #deleteButton(
                                                bind  = "click:removeAttributes",
                                                size  = "sm"
                                            )#
                                        </div>
        
                                        <div class="status float-end me-3" id="status-delete"></div>
                                    </div>
        
                                </div>                                

                                <form id="combination-grid-form">

                                    #grid(
                                        id      = "combination-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Aggancia altri attributi', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                            { 
                                                'field'           :'', 
                                                'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                'width'           :'40px',
                                                'headerAttributes': { 'class': 'text-center' }
                                            }
                                        ]",
                                        source: "items",
                                        rowTemplate = "combination/combination-item-row-tmpl"
                                    )#

                                </form>

                            </div>

                            <div class="py-3" data-bind="invisible: showItems" style="display:none">
                                <hr class="mb-5">
                                <p class="text-center pt-3">
                                    Nessuna configurazione presente
                                </p>
                            </div>                            

                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

        #view("combination/attributes-list-modal")#

    </div>

    #view("component/list-modal")#
    #view("attribute/detail-modal")#

</cfoutput>