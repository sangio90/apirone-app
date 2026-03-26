<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/x-kendo-template" id="quotation-item-preview-tmpl">
    <div class="quotation-item m-1 col-md-3" data-uid="#: uid #">
        <div class="quotation-item-inner">
            <div class="row">
                <div class="col-8 justify-content-start" style="margin-top: -15px; min-height: 2rem;">
                    <div style="font-size: 10px; margin-bottom: -10px;"> 
                        <span data-bind="text: product.line.name"></span> - 
                        <span data-bind="text: product.model.code"></span> - 
                        <span data-bind="text: product.finish.code"></span> 
                    </div>
                    <div style="font-size: 10px; margin-bottom: -2px;" data-bind="visible: position.code"> 
                        <span>Posizione: </span><span data-bind="text: position.code"></span> 
                    </div>
                    <div style="font-size: 10px;"> 
                        <i data-bind="text: note_short, attr: { title: note }"></i>
                    </div>
                </div>
                <div class="col-3"  style="margin-top: -15px;" data-bind="visible: canEdit">
                    <div class="d-flex justify-content-end mb-3">
                        <div class="ms-2 d-flex justify-content-center p-1 qt-item-clone-rounded" data-bind="click:edit" data-id="#: id#" title="Modifica">
                            <i class="fas fa-edit" style="cursor: pointer"></i>
                        </div>
                        <div class="ms-2 d-flex justify-content-center p-1 qt-item-clone-rounded" data-bind="click:clone" data-id="#: id#" title="Duplica">
                            <i class="fas fa-clone" style="cursor: pointer"></i>
                        </div>
                        <div class="ms-2 d-flex justify-content-center p-1 qt-item-trash-rounded" data-bind="click:delete" data-id="#: id#" title="Cancella">
                            <i class="fas fa-trash" style="color: red; cursor: pointer"></i>
                        </div>
                        <div class="ms-1 pb-2" style="color: rgb(199, 113, 0);" data-bind="visible: special" title="Speciale">
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                </div>
                <div class="col-12 d-flex justify-content-center">
                    <div class="qt-item-image-container">
                        <div data-bind="visible: canEdit">
                            <img data-bind="attr: { src: getImageSrc }, click:edit" class="qt-item-image">
                        </div>
                        <div data-bind="visible: canSee">
                            <img data-bind="attr: { src: getImageSrc }" class="qt-item-image" style="cursor: default">
                        </div>
                    </div>
                </div>
                <div class="col-1"></div>
                <div class="col-5" style="font-size: 11px">
                    <table style="margin: 0; padding: 0">
                        <tr>
                            <td class="text-left">Quantità:&nbsp;</td>
                            <td><span data-bind="text: quantity"></span></td>
                        </tr>
                    </table>
                </div>
                <div class="col-5" style="font-size: 11px">
                    <table>
                        <tr>
                            <td class="text-left">Prezzo:&nbsp;</td>
                            <td class="d-flex justify-content-end"><span data-bind="text: price.total" data-format="n2"></span></td>
                            <td class="text-left">&nbsp;&euro;</td>
                        </tr>
                        <tr data-bind="visible: showCosts" style="color: blue;">
                            <td class="text-left">Costo:&nbsp;</td>
                            <td class="d-flex justify-content-end"><span data-bind="text: price.cost" data-format="n2"></span></td>
                            <td class="text-left">&nbsp;&euro;</td>
                        </tr>
                    </table>
                </div>
                <div class="col-1"></div>
            </div>
        </div>
    </div>
</nmscript>
