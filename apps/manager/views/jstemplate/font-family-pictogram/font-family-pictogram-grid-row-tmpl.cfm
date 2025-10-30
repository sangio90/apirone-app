<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="font-family-pictogram-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <div data-bind="text: id"></div>
            </td>
            <td>
                <div data-bind="text: code"></div>
            </td>
            <td>
                <div data-bind="text: name"></div>
            </td>
            <td>
                <div data-bind="visible: image.uri">
                    <img data-bind="attr: { src: image.uri }" style="max-width: 20%; max-height: 20%; object-fit: contain;">
                </div>
            </td>
            <td class="text-center width-30">
                #iconButton(bind="click:editDimensions", icon="expand-alt")#
            </td>
            <td class="text-center width-30">
                #iconButton(bind="click:remove", class="btn-danger", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>

