<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-document-item-tmpl">

        <div class="col-12" class="">

            <div class="row">
                <h4 data-bind="text: name" class="col-9"></h4>
                <div class="col-3"> 
                    <div class="text-end"> 
                        <span data-bind="visible: isDocumentCompleted" class="text-end">Da caricare</span>
                        <span data-bind="visible: isDocumentUncompleted" class="text-end"><span class="success">Caricato</span></span>
                    </div>
                </div>
    
            </div>

                        
            <input type="file" id="document-upload-##: uid ##" class="mb-1 document-upload form-control" data-uid="##: uid ##">

            <div id="document-upload-dropzone-##: uid ##" class="document-dropzone" data-uid="##: uid ##">
            </div>
            
            <div id="document-upload-progress-##: uid ##">
                <div class="upload-bar" style="width: 0%;"></div>
            </div>

            <div id="document-upload-status-##: uid ##"></div>

            <hr class="my-4">

        </div>

    </nmscript>
</cfoutput>