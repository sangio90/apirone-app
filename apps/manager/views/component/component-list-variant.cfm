<cfoutput>
    <div data-bind="visible: showVariants">
        
        <p><a role="button" data-bind="click:backToComponents">&laquo; Torna ai componenti</a></p>

        <h3 data-bind="html:variantsTitle"></h3>
    
        <div class="row">

            <div class="col-6">

                <table class="table table-hover pt-5">
                    <thead>
                        <tr>
                            <th scope="col">Variante</th>
                            <th scope="col" width="30"></th>
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
                            <th scope="col">Colore</th>
                            <th scope="col" width="30" style="text-align: right"><a href="">Tutti</a></th>
                        </tr>
                    </thead>
                    
                    <tbody data-bind="source:colors" data-template="component-colors-row-tmpl">
                    </tbody>
                </table>
                
            </div>

        </div>
    
    </div> 
    
	#template( "jstemplate/component/component-colors-row-tmpl" )#
	#template( "jstemplate/component/component-variants-row-tmpl" )#
    
</cfoutput>