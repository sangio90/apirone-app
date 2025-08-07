<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-selected-row-tmpl">
        <tr ##if (typeId == "base") {## class="bg-blue" ##}## data-bind="css:{ strike: override.deleted }">
            <td width="10">
                <b data-bind="text: rawProduct.processingType.id"></b>
                <br>
                <i>(<span data-bind="text: id"></span>)</i>
            </td>
            <td>
                <b data-bind="text: rawProduct.id"></b><br>
                <span data-bind="text: rawProduct.name"></span>
            </td>
            <td>
                <b data-bind="text: variant.id"></b><br>
                <span data-bind="text: variant.name" style="line-height: 19px"></span>
            </td>
            <td>
                <b data-bind="text: color.id"></b><br>
                <span data-bind="text: color.name"></span>
            </td>
            
            ##if (typeId == 'base') {## 

                <td width="160">

                    <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <input data-bind="value: override.quantity, events: { keyup: calcTotalQuantity }" 
                                class="form-control text-end d-inline-block" style="width:45px" data-value-update="keyup" maxlength="2">
                            <br>
                            <span class="fs-10" data-bind="text: rawProduct.measurementUnit.id"></span>
                        </td>
                        <td class="ps-1">
                            <div data-bind="text: quantity" class="d-inline-block w-40 text-end similar-to-form-control "></div>
                            <br>
                            <span class="fs-10">ATTR.</span>
                            
                        </td>
                        <td class="ps-1">
                            <div data-bind="text: totalQuantity" class="d-inline-block w-40 text-end similar-to-form-control"></div>
                            <br>
                            <span class="fs-10">TOTALE</span>
                        </td>
                    </tr>
                    </table>

                </td>
                <td class="text-center">
                    <input type="checkbox" value="##:id##" name="selected" class="form-check-input">
                </td>
                <td width="40" class="text-end">
                    #iconButton( icon="trash", bind="click:deactivate" )#
                </td>                    

            ##} else {##

                <td width="160">
                    <input data-bind="value: quantity" class="form-control text-end w-70">
                    <span data-bind="text: rawProduct.measurementUnit.id"></span>
                </td>
                <td class="text-center">
                    <input type="checkbox" value="##:id##" name="selected" class="form-check-input">
                </td>
                <td width="40" class="text-end">
                    #iconButton( icon="trash", bind="click:remove" )#
                </td>                    

            ##}##

        </tr>
    </nmscript>
</cfoutput>