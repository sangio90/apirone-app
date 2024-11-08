<cfoutput>

    <div id="line-combinations-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="mt-1 mb-3 row">
                            <div class="col-9">
                                <span class="red">Non tutte le combinazioni possono essere rimosse se sono state movimentate.</span>
                            </div>
                            <div id="line-combinations-status" class="col-3 text-end h-20"></div>
                        </div>

                        <form name="line-combinations-form" id="line-combinations-form" method="post">

                            <table class="table table-hover">
                                <thead>
                                <tr>
                                    <th></th>
                                    <cfloop array="#prc.sizes#" item="size">
                                        <th>#size.getName()#</th>
                                    </cfloop>
                                </tr>
                                </thead>
                                <tbody>
                                <cfloop array="#prc.finishes#" item="finish">
                                    <cfset  finishName = finish.getMainText().getName()>
                                    <tr>
                                        <td>
                                            #finish.getMainText().getName()# <i class="grey">(#finish.getId()#)</i>
                                        </td>
                                        <cfloop array="#prc.sizes#" item="size">
                                            <td>

                                                <cfset exists = combinationExists( size.getId(), finish.getId() )>

                                                <button class="btn btn-danger btn-sm active" data-bind="click:deactivate" 
                                                    data-values="#size.getId()#__#finish.getId()#"
                                                    <cfif !exists>style="display: none"</cfif>
                                                    >
                                                    Rimuovi
                                                </button>

                                                <button class="btn btn-primary btn-sm deactive" data-bind="click:activate" 
                                                    data-values="#size.getId()#__#finish.getId()#"
                                                    <cfif exists>style="display: none"</cfif>
                                                    >
                                                    Aggiungi
                                                </button>
                                            
                                            </td>
                                        
                                        </cfloop>
                                    </tr>
                                </cfloop>
                                </tbody>
                            </table>

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>
    </div>

</cfoutput>