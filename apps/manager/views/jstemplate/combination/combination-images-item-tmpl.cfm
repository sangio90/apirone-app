<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="combination-images-item-tmpl">

        <div class="col-12" class="">

            <div class="row">
                <h4 data-bind="text: name" class="col-9"></h4>
                <div class="col-3"> 
                    <div class="text-end"> 
                        <span data-bind="visible: isImagesCompleted" class="text-end"><span class="badge bg-secondary" style="font-size:13px">Da caricare</span></span>
                        <span data-bind="visible: isImagesUncompleted" class="text-end"><span class="badge bg-success" style="font-size:13px">Caricato</span></span>
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

            <div id="document-image" class="d-none">
                <a href="/502.jpg" target="_blank" >
                    <img src="/502.jpg" width="400" height="150" style="border: 1px solid LightGray">
                </a>
            </div>

            <hr class="my-4">

        </div>

    </nmscript>
</cfoutput>