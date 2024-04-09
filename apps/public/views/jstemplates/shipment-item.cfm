<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="public-shipment-item-tmpl">

        <div class="row mb-3 pt-2" data-bind="css: { row-odd: isOddRow }">

            <div class="col-12">
                <h4 class="form-group-title title-stroke"><span>Elemento \\##<span data-bind="text: index"></span></span></h4>
            </div>

            <div class="public-shipment-item-button-trash">
                <button type="button" class="btn btn-secondary float-end" data-bind="click: removeItem">
                    <i class="bi bi-trash3-fill"></i>
                </button>
            </div>            

        </div>
    </nmscript>
</cfoutput>