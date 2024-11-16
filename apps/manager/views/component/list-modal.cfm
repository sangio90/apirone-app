<cfoutput>

    <div id="component-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Cerca componenti da Verticale</h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-12">

                            <div data-bind="visible: showSearchPanel">

                                <form data-bind="events: { submit: search }" id="component-list-search-form">

                                    <div class="pb-2 d-flex align-items-center justify-content-start">

                                        <input class="form-control me-3" placeholder="Cerca..." id="component-search-input" name="str">

                                        <select class="form-control me-3">
                                            <option value="LV">Lavorazioni</option>
                                            <option value="MP">Materie prime</option>
                                        </select>

                                        <button class="btn btn-primary" data-bind="click: search">Cerca ></button>
                                    
                                    </div>
                                    
                                    <div class="pb-2">
                                        <div class="status">
                                            Fai una ricerca
                                        </div>
                                    </div>

                                </form>
            
                                <form id="component-list-search-result-form" class="row">
            
                                    <div class="col-md-12">
                                        
            
                                        <div data-bind="visible: showSearchResult">

                                            #grid( 
                                                id="component-list-grid",
                                                columns="[
                                                    { 'field':'name', 'title':'Lavorazione/Materia prima'},
                                                    { 'field':'', 'title':'', width: '50px'},
                                                    { 'field':'', 'title':'', width: '50px'},
                                                    { 
                                                        'field':'', 
                                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                        'width':'40px',
                                                        'headerAttributes': { 'class': 'text-center' }
                                                    }
                                                ]",
                                                source="components",
                                                rowTemplate="component/component-row-list-tmpl"
                                            )#
            
                                            <!----
                                            <table class="table table-hover pt-5">
                                                <thead>
                                                    <tr>
                                                        <th scope="col">Lavorazioni</th>
                                                        <th scope="col" width="100"></th>
                                                    </tr>
                                                </thead>
                                                
                                                <tbody data-bind="source:components" data-template="components-list-tmpl">
                                                </tbody>
                                            </table>
                                            ---->
            
                                        </div>
            
                                    </div>
            
                                </form>

                            </div>

                        </div>


                    </div>
                
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 text-end">
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </footer>
            
            </div>
        </selection>
    
    </div>

    #template("jstemplate/color/product-comp-colors-row-tmpl")#
    #template("jstemplate/variant/product-comp-variants-row-tmpl")#
    <!--- #template("jstemplate/component/product-components-list-row-tmpl")# --->
    <!--- #template("jstemplate/component/components-list-tmpl")# --->

</cfoutput>