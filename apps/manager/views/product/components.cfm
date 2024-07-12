<cfoutput>

    <div id="product-components-root">

        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                
                <form action="/manager/products/save" class="form-horizontal" method="post" id="product-detail-form">
                    
                    <section class="card">
                        
                        <div class="card-body">

                            <a href="##" data-bind="click:showComponentsList">+ Aggiungi materia prima</a>
                            |
                            <a href="javascript:addComponents()">+ Aggiungi lavorazione</a>
                            |
                            <a href="javascript:addProduct()">+ Aggiungi altro prodotto</a>
                            <br>
                            <br>
                            
                            <!----
                            <cfloop array="#prc.components#" item="item">
                                <div class="form-group row pb-3 ">
                                    <div class="col-sm-12">
                                        <b>#item.name#</b>
                                        <br>
                                        <cfloop array="#item.values#" item="value">
                                            #value.name# <a href="javascript:addProducts()">+ Aggiungi prodotto</a> | <a href="javascript:addComponents()">+ Aggiungi componente</a><br>
                                        </cfloop>

                                    </div>
                                </div>

                            </cfloop>
                            ---->
                        
                        </div>

                        <footer class="card-footer">
                            <div class="row justify-content-end">
                                <div class="col-sm-9">
                                    <button class="btn btn-primary">Salva &raquo;</button>
                                    <input type="hidden" name="id" value="" />
                                </div>
                            </div>
                        </footer>
                    
                    </section>
                
                </form>
            
            </div>

        </div>

        #view("product/components-list-modal")#
        <!---
        #view("product/components-colors-list-modal")#
        #view("product/components-variants-list-modal")#
        ---->

    </div>

    <script>
        var components = #SerializeJSON( prc.components )#;
    </script>

</cfoutput>