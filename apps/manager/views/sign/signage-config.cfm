<cfoutput>

    <div id="signage-config-root">

        <div class="row">
            <div class="col-10">
                #pageTitle()#
            </div>
        </div>

        <div class="row">
            <div class="col-md-12">

                <section class="card">
                    
                    <div class="card-body row">

                        <div class="col-md-5">
                            <h3>Lista dei font</h3>

                            <div class="signage-list">

                                #table(
                                    rowTemplate="signage-config-font-list-row-tmpl",
                                    source="fontList"
                                )#

                            </div>

                        </div>
                        
                        <div class="col-md-7">
                            <h3>Font selezionati</h3>

                            <form name="signage-config-selected-form" id="signage-config-selected-form">

                                <div data-bind="visible: showSelectedList">

                                    <div class="signage-list">

                                        <table class="table" style="margin:0;padding:0">
                                            <tbody data-template="signage-config-font-selected-list-row-tmpl" data-bind="source: fontSelected">
                                            </tbody>
                                        </table>
                                        <div class="white-small mb-1">jstemplate/signage/signage-config-font-selected-list-row-tmpl</div>
                                    </div>

                                    <div class="pt-3 pb-3 text-center">
                                        <button class="btn btn-primary" data-bind="click:save">Salva configurazione &raquo;</button>
                                        <p class="mt-2">
                                            <input type="hidden" name="findDuplicateHeights"
                                                data-rule-findDuplicateHeights="true"
                                                data-msg="Ho trovato altezze duplicate"
                                            >  
                                        </p>                                  
                                    </div>

                                </div>

                                <div data-bind="invisible: showSelectedList">
                                    <p class="p-4 text-center">Nessun font selezionato</p>
                                </div>

                            </form>

                        </div>
                        
                    </div>
            
                </section>

            </div>
        </div>

        #template(view="jstemplate/sign/signage-config-font-list-row-tmpl")#
        #template(view="jstemplate/sign/signage-config-font-selected-list-row-tmpl")#
        
    </div>
    
    <!--- #view("attribute/detail-modal")# ---->

</cfoutput>