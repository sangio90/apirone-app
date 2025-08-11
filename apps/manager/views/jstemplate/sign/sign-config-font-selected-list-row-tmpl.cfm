<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="sign-config-font-selected-list-row-tmpl">
        <tr>
            <td class="p-0 m-0">

                <table width="100%">
                    <tr>
                        <td colspan="6">
                            <div class="p-2">
                                <b><span data-bind="text: name" class="fs-16"></span></b>
                                (<span data-bind="text: id"></span>)
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td width="10%">
                            ID
                        </td>
                        <td width="20%" class="align-end">
                            Altezza Mm
                        </td>
                        <td width="20%" class="align-end">
                            Altezza px
                        </td>
                        <td width="20%" class="align-end">
                            Righe
                        </td>
                        <td width="20%" class="align-end">
                            Caratteri
                        </td>
                        <td width="50">
                            &nbsp;-
                        </td>
                    </tr>
                    <tr>
                        <td colspan="6">
                            <table class="table">
                                <tbody data-template="sign-config-font-selected-size-list-row-tmpl" data-bind="source: sizes">
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </table>

            </td>
        </tr>
    </nmscript>

    #template(view="jstemplate/sign/sign-config-font-selected-size-list-row-tmpl")#

</cfoutput>