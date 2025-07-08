<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-selected-row-tmpl">
        <tr ##if (typeId == "base") {## class="bg-blue" ##}##>
            <td width="10">
                <b data-bind="text: rawProduct.processingType.id"></b> ##:typeId##
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
            <td width="160">

                ##if (typeId == 'base') {## 

                    <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <input data-bind="value: quantity, events: { keyup: calcTotalQuantity }" 
                                class="form-control text-end d-inline-block" style="width:45px" data-value-update="keyup" maxlength="2">
                            <br>
                            <span class="fs-10" data-bind="text: rawProduct.measurementUnit.id"></span>
                        </td>
                        <td class="ps-1">
                            <div data-bind="text: variation.quantity" class="d-inline-block w-40 text-end similar-to-form-control "></div>
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

                ##} else {##

                    <input data-bind="value: quantity" class="form-control text-end w-70">
                    <br>
                    <span data-bind="text: rawProduct.measurementUnit.id"></span>

                ##}##

            </td>
            <td width="40" class="text-end">
                #iconButton( icon="trash", bind="click:remove" )#
            </td>
        </tr>
    </nmscript>
</cfoutput>