<cfoutput>

    <div id="component-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                #addButton( bind="click:new", size="sm" )#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3">

                            <div class="col-sm-10">

                                <div class="mb-3 box-search-small"> 

                                    <form id="component-grid-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <div class="col">
                                            <span>Articolo</span>
                                            <input name="str" placeholder="Codice articolo" class="form-control me-2" type="text">
                                        </div>

                                        <div class="col">
                                            <span>Variante</span>
                                            <input name="str" placeholder="Codice variante" class="form-control me-2" type="text">
                                        </div>

                                        <div class="col">
                                            <span>Colore</span>
                                            <input name="str" placeholder="Codice colore" class="form-control me-2" type="text">
                                        </div>

                                        <div class="align-self-end">
                                            #searchButton( bind="click:search" )#
                                        </div>
                                    
                                    </form>

                                </div>

                            </div>

                        </div>
                        
                        <form name="component-grid-form" id="component-grid-form" method="post">

                            #grid( 
                                id="component-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '80px' },
                                    { 'field':'rawProduct.name', 'title':'Articolo'},
                                    { 'field':'variant.name', 'title':'Variante'},
                                    { 'field':'color.name', 'title':'Colore'},
                                    { 'field':'color.name', 'title':'Tipo', width: '35px'},
                                    { 'field':'cost.amount', 'title':'Costo', width: '75px'},
                                ]",
                                rowTemplate="component/component-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view("component/detail-modal")#

    </div>

</cfoutput>