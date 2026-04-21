<cfoutput>
    <nmscript type="text/x-kendo-template" id="zones-grid-row-tmpl">
        <tr data-uid="##: uid ##">
            <td class="text-center">
                <button type="button" class="btn btn-sm btn-primary" 
                        data-bind="click: editZone" title="Modifica">
                    <i class="fas fa-edit"></i>
                </button>
                <button type="button" class="btn btn-sm btn-danger" 
                        data-bind="click: deleteZone" title="Cancella">
                    <i class="fas fa-trash"></i>
                </button>
                <button type="button" class="btn btn-sm btn-secondary" 
                        data-bind="click: openDuplicateDialog" title="Duplica">
                    <i class="fas fa-copy"></i>
                </button>
                <button type="button" class="btn btn-sm btn-secondary" 
                        data-bind="click: openImagesList" title="Pianta">
                    <i class="fas fa-map"></i>
                </button>
            </td>
            <td><span>##: name ##</span></td>
            <td><span>##: (origin && origin.name) ? origin.name : '-' ##</span></td>
            <td class="text-end"><span>##: quantity ##</span></td>
        </tr>
    </nmscript>
</cfoutput>