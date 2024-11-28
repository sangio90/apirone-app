<cfoutput>

    <div id="combination-detail-root">

        #pageTitle()#

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="col-md-12">
                            <button class="btn btn-primary btn-sm" data-bind="click:showAttributesList">Aggiungi attributo &raquo;</button>
                            <button class="btn btn-primary btn-sm" data-bind="click:listImages">Aggiungi immagine &raquo;</button>
                        </div>

                        <div class="col-md-12" id="combination-config-row">

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

                            <div data-bind="visible: showTable">

                                #grid(
                                    id      = "combination-items-grid",
                                    class   = "no-pager",
                                    columns = "[
                                        { 'field':'Id', 'title':'ID', width: '20px' },
                                        { 'field':'name', 'title':'Attributo' },
                                        { 'field':'', 'title':'Aggancia altri attributi', width: '55px'},
                                        { 'field':'', 'title':'Aggiungi componenti all attributo', width: '55px'},
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

                            </div>

                            <div class="py-5" data-bind="invisible: showTable" style="display:none">
                                <hr class="mb-5">
                                <p class="text-center pt-5">
                                    Nessuna configurazione presente
                                </p>
                            </div>                            

                            <!----

                            <table class="table table-hover pt-5" style="display:none">
                                <thead>
                                    <tr>
                                        <th scope="col" width="50">ID</th>
                                        <th scope="col">Attributo</th>
                                        <th scope="col" width="50"></th>
                                        <th scope="col" width="50"></th>
                                        <th scope="col" width="50"></th>
                                    </tr>
                                </thead>
                                <tbody data-bind="source:items" data-template="combination-item-row-tmpl">
                                </tbody>
                            </table>

                            ---->

        
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