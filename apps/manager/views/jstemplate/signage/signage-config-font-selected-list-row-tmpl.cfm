<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-config-font-selected-list-row-tmpl">
        <tr>
            <td class="p-0 m-0">

                <table width="100%">
                    <tr>
                        <td colspan="6">
                            <div class="p-2">
                                <b><span data-bind="text: font.name" class="fs-16"></span></b>
                                (<span data-bind="text: font.id"></span>)
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th width="10%" class="align-end header-small">
                            ID
                        </th>
                        <th width="20%" class="align-end header-small">
                            Altezza mm
                        </th>
                        <th width="20%" class="align-end header-small">
                            Altezza px
                        </th>
                        <th width="20%" class="align-end header-small">
                            Righe
                        </th>
                        <th width="20%" class="align-end header-small">
                            Caratteri
                        </th>
                        <th width="50">
                        </th>
                    </tr>
                    <tr>
                        <td colspan="6">
                            <table class="table">
                                <tbody data-template="signage-config-font-selected-size-list-row-tmpl" data-bind="source: items">
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="6" class="pb-3 text-center">
                            <button class="btn btn-sm btn-default" data-bind="click:addItem">Aggiungi riga &raquo;</button>
                        </td>
                    </tr>
                </table>

            </td>
        </tr>
    </nmscript>

    #template(view="jstemplate/signage/signage-config-font-selected-size-list-row-tmpl")#

</cfoutput>