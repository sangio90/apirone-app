AP.quotation = AP.quotation || {};

AP.quotation.fields = {
    root: $("#quotation-plant-positions-root"),
    vueRoot: $("#vue-plant-positions-app"),
};

$(document).ready(function () {
    if (AP.quotation.fields.root.length) {
        AP.quotation.plantPositions.init();
    }
});


AP.quotation.plantPositions = (function () {
    var pub = {};
    var vm = null;
    pub.init = function () {
        AP.loading && AP.loading.show();
        var el = document.getElementById("vue-plant-positions-app");
        var quotationId = el ? el.getAttribute("data-quotation-id") : null;
        var baseUrl = el ? el.getAttribute("data-base-url") : null;

        vm = new Vue({
            el: "#vue-plant-positions-app",

            data: {
                quotationId: quotationId,
                baseUrl: baseUrl,
                zones: [],
                quotationItems: [],
                quotationItemPositions: [],
                selectedZoneId: null,
                selectedZone: {},
                selectedItemId: null,
                selectedItem: {},
                selectedItemPositionId: null,
                selectedItemPosition: {},
                dragging: false,
                draggedPosition: null,
                isLoading: false
            },

            methods: {
                increment: function () {
                    this.count++;
                },
                getZones: async function () {
                    var self = this;

                    if (!self.quotationId) {
                        AP.widget.notify( "warning", "Quotation ID mancante.");
                        return;
                    }

                    await $.ajax({
                        url: "/manager/ajax/quotations/" + self.quotationId + "/zones",
                        method: "GET"
                    })
                    .done(function (res) {
                        const zonesData = res.data.filter(zone => zone.name != 'Non assegnato');
                        self.zones = zonesData;
                    })
                    .fail(function (err) {
                        AP.widget.notify( "error", "Errore durante il caricamento delle Zone.");
                    })
                },
                getItems: async function () {
                    var self = this;
                    if (!self.selectedZoneId) {
                        AP.widget.notify( "warning", "Selezionare una zona.");
                        self.quotationItems = [];
                        self.selectedZone = {};
                        return;
                    }
                    self.isLoading = true;
                    await this.$nextTick(); 

                    self.selectedZone = self.zones.find(zone => zone.id == self.selectedZoneId) || {};
                    if (self.selectedZone.image) {
                        self.selectedZone.image.uri = self.baseUrl + "/media/quotation-zones/_ori/" + self.selectedZone.image.directory + "/" + self.selectedZone.image.name;
                    }
                    try {
                        const res = await $.ajax({
                            url: "/manager/ajax/quotations/" + self.quotationId + "/itemsbyzone/" + self.selectedZoneId,
                            method: "GET"
                        });
                        if (res.data && res.data.length) {
                            res.data.forEach(item => {
                                if (!item.positions || item.positions.length == 0) {
                                    item.positions = [];
                                }
                            });
                        }
                        self.quotationItems = res.data;

                    } catch (err) {
                        AP.widget.notify( "error", "Errore durante il caricamento degli Articoli.");
                    } finally {
                        self.isLoading = false;
                    }
                },
                selectPosition: function (position) {
                    this.selectedItemPosition = position;
                    this.selectedItemPositionId = position.id;
                },
                getMarkerStyle(pos) {
                    let quotationItem = this.quotationItems.find(quotationItem =>  quotationItem.id == pos.quotationItemId );
                    let background = 'rgb(232, 93, 68)';
                    if (quotationItem) {
                        const name = quotationItem?.product?.category?.type?.name;
                        const firstChar = name ? name.charAt(0).toUpperCase() : '';
                        if (firstChar === 'P') {
                            background = 'rgb(68, 130, 232)';
                        }
                        if (firstChar === 'A') {
                            background = 'rgb(69, 232, 118)';
                        }
                    }
                    return {
                        position: 'absolute',
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        transform: 'translate(-50%, -50%)',
                        backgroundColor: background,
                    };
                },
                startDrag(event, pos) {
                    this.dragging = true;
                    this.draggedPosition = pos;

                    document.addEventListener('mousemove', this.onDrag);
                    document.addEventListener('mouseup', this.stopDrag);
                },
                onDrag(event) {
                    if (!this.dragging || !this.draggedPosition) return;

                    const overlay = this.$el.querySelector('.overlay-layer');
                    const rect = overlay.getBoundingClientRect();

                    let x = event.clientX - rect.left;
                    let y = event.clientY - rect.top;

                    // clamp dentro area
                    x = Math.max(0, Math.min(x, rect.width));
                    y = Math.max(0, Math.min(y, rect.height));

                    // converti in percentuale (0 → 1)
                    this.draggedPosition.coordinateX = +(x / rect.width).toFixed(4);
                    this.draggedPosition.coordinateY = +(y / rect.height).toFixed(4);
                },
                stopDrag() {
                    this.dragging = false;
                    this.draggedPosition = null;

                    document.removeEventListener('mousemove', this.onDrag);
                    document.removeEventListener('mouseup', this.stopDrag);
                },
                getInitial(item) {
                    const name = item?.product?.category?.type?.name;
                    const firstChar = name ? name.charAt(0).toUpperCase() : '';

                    if (firstChar === 'P') {
                        return '<i class="fas fa-plug"></i>';
                    }

                    if (firstChar === 'A') {
                        return '<i class="fas fa-chair"></i>';
                    }

                    if (firstChar === 'S') {
                        return '<i class="fas fa-font"></i>';
                    }

                    return '';
                },
                savePositions: async function () {
                    var self = this;
                    let quotationItemPositions = [];
                    self.quotationItems.forEach(item => {
                        if (item.positions && item.positions.length) {
                            item.positions.forEach(pos => {
                                quotationItemPositions.push({
                                    id: pos.id,
                                    coordinateX: pos.coordinateX,
                                    coordinateY: pos.coordinateY,
                                    visible: pos.visible == true ? 1 : 0,
                                    sequence: pos.sequence,
                                    quotationItemId: item.id
                                });
                            });
                        }
                    })
                    if (quotationItemPositions.length == 0) {
                        AP.widget.notify( "warning", "Non ci sono posizioni da salvare.");
                        return;
                    }

                    await $.ajax({
                        url: "/manager/ajax/quotation-item-positions/",
                        method: "POST",
                        data: JSON.stringify({
                            positions: quotationItemPositions
                        }),
                        contentType: "application/json"
                    })
                    .done(function (res) {
                        if (res.status && res.status.toLowerCase() === "ERROR") {
                            AP.widget.notify( "error", res.data.message || "Errore.");
                        } else {
                            AP.widget.notify( "success", res.data.message || "Successo.");
                        }
                    })
                    .fail(function (err) {
                        AP.widget.notify( "error", "Errore sconosciuto durante il salvataggio.");
                    })
                }
            },

            mounted: function () {
                this.getZones();
            }
        });



        AP.loading && AP.loading.hide();
    };

    return pub;
}());