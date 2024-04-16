<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="document-item-tmpl">
        <h4>##1 Documento d'identità</h4>
                            
        <div class="col-4">
        </div>

        <div class="col-8">
            <!--- <input class="form-control" type="file" id="form-upload-2" class="text-center"> ---->

            <div id="form-upload-1-dropzone" style="margin-top: 20px; margin-bottom: 20px; width: 100%; border: 2px solid ##EAEAEA; height: 150px;
                background-image: url(/assets/main/img/trascina-qui.png);
                background-repeat:no-repeat;
                background-position: top center;
            ">
                <br>
                <br>
                <br>
                <br>
                <input class="form-control" type="button" id="form-upload-2" class="btn btn-secondary mb-3" value="O selezionane uno" style="width: 50%; margin-left: 130px">
                
            </div>

            <div id="form-upload-1-status"></div>                            </div>

        <hr class="my-4">

    </nmscript>
</cfoutput>