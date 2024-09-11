<cfoutput>

    <div id="product-components-root">

        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <div class="tab-content"  id="size-tabs-content">

                    <div class="col-lg-12 text-end mt-3 mb-5">
                        <button class="btn btn-primary btn-sm" data-bind="click:showAttributesList">Aggiungi attributo &raquo;</button>
                    </div>

                    <table class="table table-hover pt-5">
                        <thead>
                            <tr>
                                <th scope="col" width="100"></th>
                                <th scope="col"></th>
                                <th scope="col"></th>
                            </tr>
                        </thead>
                        
                        <tbody data-bind="source:componentsForProduct" data-template="product-attributes-list-row-tmpl">
                        </tbody>

                    </table>

                </div>
            
            </div>

        </div>

        #view("product/attributes-list-modal")#
        #view("product/components-values-list-modal")#
        #view("product/components-list-modal")#

        #template("jstemplate/product/product-attributes-list-row")#
        #template("jstemplate/product/values-list-row")#

    </div>

    <script>
        var attributes = #SerializeJSON( prc.components )#;
    </script>

</cfoutput>