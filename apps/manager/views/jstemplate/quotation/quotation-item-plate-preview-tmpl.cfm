<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/x-kendo-template" id="quotation-item-plate-preview-tmpl">
    <div class="quotation-item m-1 col-3" data-uid="#: uid #" style="cursor: pointer" data-bind="click:editPlate">
        <div class="quotation-item-inner">
            <div class="row">
                <div class="col-12 d-flex justify-content-center mb-2">
                    <div>
                        <b>Placca</b>
                    </div>
                    <div class="ms-2 d-flex justify-content-center p-1 qt-item-trash-rounded" data-bind="click:delete" data-id="#: id#">
                        <i class="fas fa-trash" style="color: red; cursor: pointer"></i>
                    </div>
                </div>
                <div class="col-12 d-flex justify-content-center">
                    <div class="qt-item-image-container">
                        <img data-bind="attr: { src: getImageSrc }" class="qt-item-image">
                    </div>
                </div>
                <div class="col-6 mt-2 d-flex justify-content-center">
                    Quantità: #: quantity #
                </div>
                <div class="col-6 mt-2 d-flex justify-content-center">
                    Prezzo: #: price.amount #
                </div>
            </div>
        </div>
    </div>
</nmscript>
