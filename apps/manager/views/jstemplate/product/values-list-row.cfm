<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="values-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:addSubAttribute">+ Aggiungi</button>
            </td>
            <td>
                <table>
                    <tr>
                        <td>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:showComponentsList">Gestionale</button>
                        </td>
                        <td>
                            <span id="product_counter_##: id  ##">0</span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </nmscript>
</cfoutput>