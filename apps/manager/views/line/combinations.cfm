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

                        <form name="line-combinations-form" id="line-combinations-form" method="post">

                            <table class="table">
                                <tr>
                                    <td></td>
                                    <cfloop array="#prc.sizes#" item="size">
                                        <td>#size.getName()#</td>
                                    </cfloop>
                                </tr>
                                <cfloop array="#prc.finishes#" item="finish">
                                
                                    <cfset  finishName = finish.getMainText().getName()>
                                    
                                    <tr>
                                        <td>
                                            #finish.getMainText().getName()#
                                        </td>
                                        <cfloop array="#prc.sizes#" item="size">
                                            <td>
                                                #finishName# -                                                 #size.getName()#
                                            </td>
                                        </cfloop>
                                    </tr>
                                </cfloop>
                            </table>

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>
    </div>

</cfoutput>