<cfoutput>

    <div id="product-component-root">

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

                            <a href="javascript:addProducts()">+ Aggiungi prodotto</a> | 
                            <a href="javascript:addComponents()">+ Aggiungi materia prima</a>
                            <br>
                            <br>
                            
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

    </div>

    <div class="modal hide fade" tabindex="-1" id="list-compoments-modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Lista delle materie prime</h3>
                </div>
                <div class="modal-body">

                    <div class="row">
                        
                        <div class="col-6">

                            <select class="form-control" size=15 onclick="getCompValues(this.value)">
                                <cfloop array="#prc.components#" item="item" >
                                    <option value="#item.id#">#item.name#</option>
                                </cfloop>
                            </select>


                        </div>

                        <div class="col-6">

                            <select class="form-control" size=15 multiple id="list-values">
                                <cfloop array="#prc.components[1].values#" item="item">
                                    <option>#item.name#</option>
                                </cfloop>
                            </select>

                        </div>
                    
                    </div>



                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary">Salva</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal hide fade" tabindex="-1" id="list-products-modal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Lista dei prodotti</h3>
                </div>
                <div class="modal-body">

                    <div class="row">
                        
                        <div class="col-12">

                            <select class="form-control" size=15>
                                <cfloop array="#prc.products#" item="item">
                                    <option>#item.name#</option>
                                </cfloop>
                            </select>


                        </div>

                    </div>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary">Salva</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        var components = #SerializeJSON( prc.components )#;
    </script>


</cfoutput>