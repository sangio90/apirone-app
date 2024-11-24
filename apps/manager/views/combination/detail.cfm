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
                                            #item.getName()#
                                        </option>
                                    </cfloop>
                                </select>
                                
                                <label class="me-2">Finitura:</label>
                                <select name="finishId" class="form-control w-200" data-bind="events: { change: change }" >
                                </select>
                            </form>
                              
                        </div>

                        <hr class="my-5">

                        <div class="col-md-12">

                            <table class="table table-hover pt-5" data-bind="visible: showTable" style="display:none">
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

                            <div class="py-5" data-bind="invisible: showTable" style="display:none">
                                <p class="text-center">Nessuna configurazione presente</p>
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

    #template( view="jstemplate/combination/combination-item-row-tmpl" )#

</cfoutput>