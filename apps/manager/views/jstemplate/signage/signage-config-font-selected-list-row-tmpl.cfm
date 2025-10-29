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
                        <th width="50" class="header-small">
                            ID
                        </th>
                        <th class="header-small" width="55%">
                            Altezza mm
                        </th>
                        <th class="header-small" width="15%">
                            Altezza px
                        </th>
                        <th class="header-small" width="15%">
                            Righe
                        </th>
                        <th class="header-small" width="15%">
                            Caratteri
                        </th>
                        <th width="50">
                        </th>
                        <th width="50">
                        </th>
                    </tr>
                    <tr>
                        <td colspan="7">
                            <table class="table">
                                <tbody data-template="signage-config-font-selected-size-list-row-tmpl" data-bind="source: items">
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="7" class="pb-3 text-center">
                            <button class="btn btn-sm btn-default" data-bind="click:addItem">Aggiungi riga &raquo;</button>
                        </td>
                    </tr>
                </table>

            </td>
        </tr>
    </nmscript>

    #template(view="jstemplate/signage/signage-config-font-selected-size-list-row-tmpl")#

</cfoutput>