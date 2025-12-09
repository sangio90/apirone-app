<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/x-kendo-template" id="quotation-item-accessory-preview-tmpl">
    <div class="quotation-item m-1 col-3" data-uid="#: uid #" style="cursor: pointer" data-bind="click:editAccessory">
        <div class="quotation-item-inner">
            <div class="row">
                <div class="col-12 d-flex justify-content-center mb-2" style="font-size: 14px; font-weight: bold;">
                    <div>
                        Accessorio
                    </div>
                    <div class="ms-2 d-flex justify-content-center p-1" style="border: 1px solid red; height: 25px; width: 25px; border-radius: 5px" data-bind="click:delete" data-id="#: id#">
                        <i class="fas fa-trash" style="color: red; cursor: pointer"></i>
                    </div>
                </div>
                <div class="col-12 d-flex justify-content-center">
                    <div style="min-width: 200px; max-width: 200px; max-height:200px; min-height: 200px; overflow: hidden; display: flex; align-items: center; justify-content: center; background: white;">
                      <img data-bind="attr: { src: getImageSrc }" style="max-width: 100%; max-height: 100%; object-fit: contain;">
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
