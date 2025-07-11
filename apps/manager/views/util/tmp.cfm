<cfoutput>

    <div id="product-detail-root">

        #pageTitle()#

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body row">

                        <div class="col-md-4">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>
                        
                    </div>
            
                </section>

            </div>
        </div>

        #view("product/attributes-list-modal")#
        
    </div>

    
    #view("attribute/detail-modal")#

</cfoutput>