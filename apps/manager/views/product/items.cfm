<cfimport prefix="ap" taglib="/apps/utils/ctags">

<cfoutput>

    <div id="product-detail-items-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body row">

                        <div class="col-md-4">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>
                        
                        <div class="col-md-12">

                            <cfloop array="#items#" index="item">
                                <div class="row">
                                </div>
                            </cfloop>

                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

    </div>
    
</cfoutput>