<cfoutput>

    <div id="combination-detail-root">

        #pageTitle()#

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body row">

                        <div class="col-md-4">
                            <button class="btn btn-primary btn-sm" data-bind="click:openAttributesList">Gestisci attributi &raquo;</button>
                        </div>
                        
                        <div class="col-md-8 mb-4" id="combination-config-row">

                            <form class="d-flex align-items-center justify-content-end" id="combination-change-form">

                                <label class="me-2">Dimensione:</label>

                                <select name="sizeId" class="form-control w-auto me-4" data-bind="events: { change: loadFinishes }">
                                    <cfloop array="#prc.sizes#" item="item">
                                        <option value="#item.getId()#" 
                                            <cfif item.getId() EQ prc.size.getId()>SELECTED</cfif>
                                        >
                                            #item.getCode()#
                                        </option>
                                    </cfloop>
                                </select>
                                
                                <label class="me-2">Finitura:</label>

                                <select name="finishId" class="form-control w-200" data-bind="events: { change: change }" >
                                </select>
                            </form>

                        </div>

                        <div class="col-md-12">

                            <!--- 
                                data-bind="visible: showItems" 
                                TODO: add this. remove from above menu 
                            ---->
                            <div >

                                <div class="row d-flex align-items-center mb-2">

                                    <div class="col-sm-9">

                                        <p>
                                            - <a href=""
                                                class="underline"
                                                data-type="lineSize" 

                                                data-size-id="#prc.size.getId()#"
                                                data-size-name="#prc.size.getCode()#"

                                                data-line-id="#prc.line.getId()#"
                                                data-line-name="#prc.line.getName()#"
                                                
                                                data-bind="click: openComponentsList">
                                                    Componenti per #prc.line.getName()# / #prc.size.getCode()# &raquo;
                                                </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="combination" 

                                                data-combination-id="#rc.id#"
                                                data-combination-name="#prc.subtitle# / #prc.title#"
                                                
                                                data-bind="click: openComponentsList">
                                                    Componenti base per questa combinazione &raquo;
                                                </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="combination" 
                                                data-bind="click:openImagesList">
                                                Aggiungi immagini per questa placca &raquo;
                                            </a>
                                            <br>
                                            - <a href=""
                                                class="underline"
                                                data-type="combination" 
                                                data-bind="click:openReorderingModal">
                                                Riordina elementi &raquo;
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

                                <form id="combination-grid-form">

                                    #grid(
                                        id      = "combination-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Aggiungi immagini', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                            { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
                                            { 
                                                'field'           :'', 
                                                'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                'width'           :'40px',
                                                'headerAttributes': { 'class': 'text-center' }
                                            }
                                        ]",
                                        source: "items",
                                        rowTemplate = "combination/combination-item-row-tmpl"
                                    )#

                                </form>

                            </div>

                            <!---
                            <div class="py-3" data-bind="invisible: showItems" style="display:none">
                                <hr class="mb-5">
                                <p class="text-center pt-3">
                                    Nessuna configurazione presente
                                </p>
                            </div>
                            ---->

                        </div>
    
                    </div>
            
                </section>

            </div>
        </div>

        <!--- #view("combination/attributes-list-modal")# --->
        #view("combination/images-list-modal")#
        #view("combination/reordering-modal")#
        
    </div>

    #view("attribute/detail-modal")#
    #view("component/list-modal")#

</cfoutput>