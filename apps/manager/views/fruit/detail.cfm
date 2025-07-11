<cfoutput>

    <div id="fruit-detail-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end pt-3">
                #addButton( bind="click:new", size="sm" )#
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body row">

                        <div class="col-md-4 mb-4">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>
                        
                        <div class="col-md-12">

                            <div >

                                <div class="row d-flex align-items-center mb-2">

                                    <div class="col-sm-9">

                                        <p>
                                            - <a href=""
                                                class="underline"
                                                data-type="fruit" 

                                                data-fruit-id="#prc.fruit.getId()#"
                                                data-fruit-code="#prc.fruit.getCode()#"
                                                
                                                data-bind="click: openComponentsList">
                                                    Componenti base per questo frutto &raquo;
                                                </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="product" 
                                                data-bind="click:openImagesList">
                                                Aggiungi immagini per questo frutto &raquo;
                                            </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="item" 

                                                data-fruit-id="#prc.fruit.getId()#"
                                                data-parent-id="0"
                                                
                                                data-bind="click: openAttributesList">
                                                    Aggiungi attributo di base &raquo;
                                                </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="product" 
                                                data-bind="click:openReorderingModal">
                                                Riordina attributi &raquo;
                                            </a>
                                        </p>
        
                                        <!---
                                        <div class="mb-3 box-search-small"> 
        
                                            <form id="finish-grid-search-form" 
                                                class="d-flex align-items-center justify-content-end" 
                                                data-bind:'events: { submit: search }'>
        
                                                <input name="str" placeholder="Cerca..." class="form-control me-2" type="text">
        
                                                #searchButton( bind="click:search" )#
                                            
                                            </form>
        
                                        </div>
                                        ----->
        
                                    </div>
                                    <div class="col-sm-3">
                                        <div class="float-end">
                                            #deleteButton(
                                                bind  = "click:removeAttributes",
                                                size  = "sm"
                                            )#
                                        </div>
        
                                        <div class="status float-end me-3" id="status-delete"></div>
                                    </div>
        
                                </div>     
                                
                                <form id="product-grid-form">

                                    #productAttributesList( id="product-items-grid", type="product" )#
                                
                                </form>                                

                                <!----
                                <form id="product-grid-form">

                                    #grid(
                                        id      = "product-items-grid",
                                        class   = "no-pager",

                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Aggiungi immagini', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi altri attributi', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                            { 
                                                'field'           :'', 
                                                'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                'width'           :'40px',
                                                'headerAttributes': { 'class': 'text-center' }
                                            }
                                        ]",
                                        source: "items",
                                        rowTemplate = "product/product-item-row-tmpl"
                                    )#

                                </form>
                                ---->

                            </div>

                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

        #view("product/attributes-list-modal")#
        #view("product/images-list-modal")#
        #view("product/sorting-modal")#
        
    </div>

    #view("attribute/detail-modal")#
    #view("component/list-modal")#

</cfoutput>