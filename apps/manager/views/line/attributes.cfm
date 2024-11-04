<cfoutput>

    <div id="line-attributes-root">

        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="col-md-12">
                            <button class="btn btn-primary btn-sm" data-bind="click:showAttributesList">Aggiungi attributo &raquo;</button>
                        </div>

                        <div class="col-md-3 offset-md-9 float-end">

                            Dimensione:
                            <select name="size" class="form-control">
                                <cfloop array="#prc.sizes#" item="item">
                                    <option value="#item.getId()#" 
                                    <cfif item.getId() EQ prc.sizeId>SELECTED</cfif>
                                    >#item.getName()#</option>
                                </cfloop>
                            </select>

                        </div>

                        <hr>

                        <div class="col-md-12 mt-5">

                            <table width="100%" class="table">
                                <cfloop array="#[]#" index="finish">
                                <tr>
                                    <td colspan="2"></td>
                                </tr>
                                </cfloop>
                            </table>
        
                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

        #view("line/attributes-list-modal")#

    </div>

    #view("attribute/detail-values-modal")#

</cfoutput>