<cfoutput>

    <div id="combination-detail-root">

        <cf_pageTitle prc="#prc#">

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="col-md-12">
                            <button class="btn btn-primary btn-sm" data-bind="click:showAttributesList">Aggiungi attributo &raquo;</button>
                        </div>

                        <div class="col-md-6 offset-md-6 float-end">

                            <div class="row" id="combination-config-row">
                            
                                <div class="col-12">


                                <!---
                                    Note: inline form with bootstrap 5 and label
                                    https://codesandbox.io/p/sandbox/bootstrap-5-inline-form-example-065utx
                                --->

                                <form class="d-flex align-items-center justify-content-between">

                                    <label class="">Dimensione:</label>
                                    <select name="sizeId" class="form-control w-auto">
                                        <cfloop array="#prc.sizes#" item="item">
                                            <option value="#item.getId()#" 
                                                <cfif item.getId() EQ prc.sizeId>SELECTED</cfif>
                                            >
                                                #item.getName()#
                                            </option>
                                        </cfloop>
                                    </select>
                                    
                                    <label class="">Finutura:</label>
                                    <select name="finishId" class="form-control w-auto">
                                        <cfloop array="#prc.finishes#" item="item">
                                            <option value="#item.getId()#" 
                                                <cfif item.getId() EQ prc.sizeId>SELECTED</cfif>
                                            >
                                                #item.getName()#
                                            </option>
                                        </cfloop>
                                    </select>
                              
                                    <button type="submit" class="btn btn-primary ml-3">Cambia ></button>
                                  
                                </form>
                              
                            </div>
                            </div>
                        
                        </div>

                        <div class="col-md-12 mt-5">

                            <table class="table table-hover pt-5">
                                <thead>
                                    <tr>
                                        <th scope="col" width="50">ID</th>
                                        <th scope="col">Attributo</th>
                                        <th scope="col" width="50"></th>
                                        <th scope="col" width="50"></th>
                                        <th scope="col" width="50"></th>
                                    </tr>
                                </thead>
                                <tbody data-bind="source:configList" data-template="line-config-row-tmpl">
                                </tbody>
                            </table>
        
                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

        #view("line/attributes-list-modal")#

    </div>

    #view("attribute/detail-values-modal")#
    #view("line/components-list-modal")#

    #template( view="jstemplate/line/line-config-row-tmpl" )#

</cfoutput>