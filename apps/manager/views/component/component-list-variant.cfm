<cfoutput>
    <div data-bind="visible: showVariants">
        
        <p class="mb-0"><a role="button" data-bind="click:showComponentsList">&laquo; Torna ai componenti</a></p>

        <span class="title-intro">Varianti per</span>
        <h3 class="mt-1" data-bind="html:variantsTitle"></h3>
    
        <div class="row">

            <div class="col-6">

                <table class="table table-hover pt-5">
                    <thead>
                        <tr>
                            <th scope="col">Varianti</th>
                            <th scope="col" width="30"></th>
                        </tr>
                        <tr>
                            <th scope="col" colspan="2">
                                <input class="form-control form-control-sm" name="str" 
                                    id="component-variant-search-str" 
                                    placeholder = "Filtra..." 
                                    data-bind="events: { keyup: filterVariants }"
                                    >
                            </th>
                        </tr>
                    </thead>
                    <tbody data-bind="source:variants" data-template="component-variants-row-tmpl">
                    </tbody>
                </table>
                
            </div>

            <div class="col-6">

                <table class="table table-hover pt-5">
                    <thead>
                        <tr>
                            <th scope="col">Colori</th>
                            <th scope="col" width="30"></th>
                        </tr>
                        <tr>
                            <th scope="col" colspan="2">
                                <input class="form-control form-control-sm" name="str" 
                                    id="component-color-search-str" 
                                    placeholder = "Filtra..." 
                                    data-bind="events: { keyup: filterColors }"
                                    >
                            </th>
                        </tr>
                    </thead>
                    
                    <tbody data-bind="source:colors" data-template="component-colors-row-tmpl">
                    </tbody>
                </table>
                
            </div>

        </div>
    
    </div> 
    
	#template( "jstemplate/component/component-variants-row-tmpl" )#
	#template( "jstemplate/component/component-colors-row-tmpl" )#
    
</cfoutput>