<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/x-kendo-template" id="quotation-item-plate-preview-tmpl">
    <div class="quotation-item m-1 col-md-3" data-uid="#: uid #">
        <div class="quotation-item-inner">
            <div class="row">
                <div class="col-12 d-flex justify-content-end mb-3">
                    <div class="ms-2 d-flex justify-content-center p-1 qt-item-clone-rounded" data-bind="click:editPlate" data-id="#: id#" title="Modifica">
                        <i class="fas fa-edit" style="cursor: pointer"></i>
                    </div>
                    <div class="ms-2 d-flex justify-content-center p-1 qt-item-clone-rounded" data-bind="click:clonePlate" data-id="#: id#" title="Duplica">
                        <i class="fas fa-clone" style="cursor: pointer"></i>
                    </div>
                    <div class="ms-2 d-flex justify-content-center p-1 qt-item-trash-rounded" data-bind="click:delete" data-id="#: id#" title="Cancella">
                        <i class="fas fa-trash" style="color: red; cursor: pointer"></i>
                    </div>
                </div>
                <div class="col-12 d-flex justify-content-center">
                    <div class="qt-item-image-container">
                        <img data-bind="attr: { src: getImageSrc }, click:editPlate" class="qt-item-image">
                    </div>
                </div>
                <div class="col-6 mt-2 d-flex justify-content-center">
                    Quantità: #: quantity #
                </div>
                <div class="col-6 mt-2 d-flex justify-content-center">
                    Prezzo: #: price.total #
                </div>
            </div>
        </div>
    </div>
</nmscript>
