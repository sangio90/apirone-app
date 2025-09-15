<cfprocessingdirective pageEncoding='UTF-8'>

<script type="text/x-kendo-template" id="quotation-item-preview-tmpl">
    <div class="quotation-item m-1" data-uid="#: uid #" style="cursor: pointer" data-bind="click:editSignate">
        <div class="quotation-item-inner">
            <div class="row">
                <div class="col-12" style="font-size: 14px; font-weight: bold;">
                    Anteprima Segnaletica
                </div>
                <div class="col-12">
                    <img src="/assets/fakes/img/plate.jpg" style="width: 80%;">
                </div>
                <div class="col-6">
                    Quantità: #: quantity #
                    Prezzo: #: price #
                </div>
            </div>
        </div>
    </div>
</script>
