<cfoutput>

    <div id="system-list-root">

        #pageTitle()#

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <cfloop array="#prc.keys#" item="item">
                                <div class="col-3 text-end">
                                    <b>#item.key#</b>
                                </div>
                                <div class="col-9">
                                    #item.value#
                                </div>
                                <div class="col-12">
                                    <hr class="mt-2 mb-2">
                                </div>
                            </cfloop>

                        </div>
                        
                    </div>
                
                </section>
            </div>
        </div>

    </div>

</cfoutput>