<!--- NOTE: tpl: with "tmpl" not found :-( --->
<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="files-list-row-tpl">

        <div class="col-12 mb-2">

            <div class="row">

                <div class="col-8 mb-4">

                    <div class="row">
                        <h4 data-bind="text: getImageTypeText" class="col-9"></h4>
                        <div class="col-3">
                            <div class="text-end mb-1">
                                <span data-bind="invisible: complete" class="text-end">
                                    <span class="badge bg-secondary" style="font-size:13px">Da caricare</span>
                                </span>
                                <span data-bind="visible: complete" class="text-end">
                                    <span class="badge bg-success" style="font-size:13px">Caricato</span>
                                </span>
                            </div>
                        </div>

                    </div>

                    <input type="file" id="file-upload-##: uid ##" class="mb-1 file-upload form-control" data-uid="##: uid ##">

                    <div id="file-upload-dropzone-##: uid ##" class="file-dropzone" data-uid="##: uid ##">
                    </div>

                    <div id="file-upload-progress-##: uid ##">
                        <div class="upload-bar" style="width: 0%;"></div>
                    </div>

                    <div id="file-upload-status-##: uid ##"></div>

                </div>

                <div class="col-4 mb-2">
                    <a href="" data-bind="attr: { href: getImageHref }" target="_blank">
                        <img class="img-fluid" data-bind="attr: { src: getImageSrc }" height="500">
                    </a>
                </div>

            </div>

        </div>

    </nmscript>
</cfoutput>