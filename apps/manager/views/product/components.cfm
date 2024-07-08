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

                            <a href="##" data-bind="click: showComponentsList">+ Aggiungi materia prima</a>
                            !
                            <a href="javascript:addComponents()">+ Aggiungi lavorazione</a>
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
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Lista delle materie prime</h3>
                </div>
                <div class="modal-body">

                    <div class="row">
                        
                        <div class="col-7">


                            <table class="table table-striped mb-0" id="datatable-ecommerce-list">
                                <thead>
                                    <tr>
                                        <th width="5%">ID</th>
                                        <th>Nome</th>
                                        <th width="3%">
                                            <input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop array="#prc.rawMaterials#" item="item">
                                        <tr>
                                            <td>#item.id#</td>
                                            <td>#item.name#</td>
                                            <td width="150" nowrap>
                                                - <a class="underline">Aggiungi &raquo;</a><br>
                                                - <a class="underline" onclick="showVariants()">Varianti &raquo;</a><br>
                                                - <a class="underline" onclick="showColors()">Colori &raquo;</a><br>
                                            </td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            
                            </table>


                        </div>

                        <div class="col-5">

                            <div id="table-variant-colors" style="display: none;" class="general-variant">

                                <h3>Colori</h3>

                                <table class="table table-striped mb-0">
                                    <thead>
                                        <tr>
                                            <th width="5%">ID</th>
                                            <th>Nome</th>
                                            <th width="3%">
                                                <input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop array="#prc.variants#" item="item">
                                            <tr>
                                                <td>#item.id#</td>
                                                <td>#item.name#</td>
                                                <td width="150" nowrap>
                                                    <input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" />
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                
                                </table>

                            </div>

                            <div id="table-variant-variants" style="display: none;" class="general-variant">

                                <h3>Varianti</h3>

                                <table class="table table-striped mb-0">
                                    <thead>
                                        <tr>
                                            <th width="5%">ID</th>
                                            <th>Nome</th>
                                            <th width="3%">
                                                <input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" />
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop array="#prc.colors#" item="item">
                                            <tr>
                                                <td>#item.id#</td>
                                                <td>#item.name#</td>
                                                <td width="150" nowrap>
                                                    <input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" />
                                                </td>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                
                                </table>

                            </div>
                        
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