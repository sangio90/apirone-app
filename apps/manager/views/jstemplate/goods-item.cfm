<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="goods-item-tmpl">

        <div class="row mb-3 pt-2" data-bind="css: { row-odd: isOddRow }" id="goods-item">

            <div class="col-12">

                <div class="row">

                    <div class="col-9">
                        <h4 class="form-group-title title-stroke fw-bold"><span>Etichetta \\##<span data-bind="text: index"></span></span></h4>
                    </div>

                    <div class="col-3 shipment-item-button-trash">

                        <button type="button" class="btn btn-secondary btn-sm float-end mb-1" data-bind="click: removeItem">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>

                        <button type="button" class="btn btn-primary btn-sm me-2 float-end mb-1" data-bind="click: editItem">
                            <i class="fa-solid fa-edit-can"></i> Modifica
                        </button>

                    </div>

                    <hr>

                </div>

                <div class="row">

                    <div class="col-sm-4 col-sx-12 mb-3">
                        <label for="goodDescription_##: uid ##" class="form-label good">Etichetta</label>
                        <div id="goodDescription_##: uid ##" data-bind="text: name"></div>
                    </div>

                    <div class="col-sm-2 col-sx-12 mb-3" data-bind="visible: isAlcoholic"> <!---- data-bind="visible: isAlcoholic" ---->
                        <label for="year_##: uid ##" class="form-label good">Annata</label>
                        <div id="year_##: uid ##" data-bind="text: year"></div>
                    </div>
                    
                    <div class="col-sm-3 col-sx-12 mb-3" data-bind="visible: isAlcoholic">
                        <label for="alcoholType_##: uid ##" class="form-label good">Tipo alcolico</label>
                        <div id="alcoholType_##: uid ##" data-bind="text: alcoholType.name"></div>
                    </div>

                    <div class="col-sm-3 col-sx-12 mb-3" data-bind="visible: isAlcoholic">
                        <div class="form-group mb-3">
                            <label for="Strength_##: uid ##" class="form-label good">Gradazione</label>
                            <div id="Strength_##: uid ##" data-bind="text: strength"></div>
                        </div>

                    </div>

                </div>
                
                <div class="row">
                    
                    <div class="col-sm-4 col-sx-12 mb-3">
                        <label for="bottleCapacity_##: uid ##" class="form-label good">Capacità bott.</label>
                        <div id="bottleCapacity_##: uid ##">
                            <span data-bind="text: capacity.value"></span> L
                            (<span data-bind="text: capacity.name"></span>)
                        </div>
                    </div>
                    
                    <div class="col-sm-2 col-sx-4 mb-3">
                        <label for="quantity_##: uid ##" class="form-label good">Quantità</label>
                        <div id="quantity_##: uid ##" data-bind="text: quantity"></div>
                    </div>

                    <div class="col-sm-3 col-sx-4 mb-3">

                        <div class="form-group mb-3">
                            <label for="value_##: uid ##" class="form-label good">Valore bott.</label>
                            <div id="value_##: uid ##"><span data-bind="text: value" data-type="number" data-format="c2"></span></div>
                        </div>

                    </div>
            
                </div>
            </div>
        </div>

    </nmscript>
</cfoutput>