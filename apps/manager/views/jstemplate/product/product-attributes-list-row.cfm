<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-attributes-list-row-tmpl">
        <tr class="k-master-row">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                
                <table class="table table-hover pt-5">
                    <thead>
                        <tr>
                            <th scope="col" width="100"></th>
                            <th scope="col"></th>
                            <th scope="col" width="120"></th>
                            <th scope="col" width="120"></th>
                        </tr>
                    </thead>

                    <tbody data-bind="source:values" data-template="values-list-row-tmpl">
                    </tbody>

                </table>

            </td>
        </tr>
    </nmscript>
</cfoutput>
