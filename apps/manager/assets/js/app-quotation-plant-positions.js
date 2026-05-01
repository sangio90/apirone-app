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
                isLoading: false,
                isRotating: false,
                rotatedPosition: null,
                initialMouseX: 0,
                initialAngle: 0,
                rotationSpeedFactor: 0.5,
				showAccessori: true,
				showSegnaletica: true,
				showPlacche: true,
            },

			watch: {
				showAccessori(newVal) {
					debugger
				}
			},

			computed: {
				filteredQuotationItemsGroupedByType() {
					let quotationItemsGroupedByType = {...this.quotationItemsGroupedByType}
					if (!this.showAccessori) {
						quotationItemsGroupedByType.accessori = []
					}
					if (!this.showSegnaletica) {
						quotationItemsGroupedByType.segnaletica = []
					}
					if (!this.showPlacche) {
						quotationItemsGroupedByType.placche = []
					}
					return quotationItemsGroupedByType
				},
				quotationItemsGroupedByType() {
					let placche = []
					let segnaletica = []
					let accessori = []
					let servizi = [] //TODO non dovrebbero esserci ma verifichiamo
					placche = this.quotationItems.filter(el => {
						return el.product.catalogBundle.category.type.id === 'PLA'
					})
					segnaletica = this.quotationItems.filter(el => {
						return el.product.catalogBundle.category.type.id === 'SEG'
					})
					accessori = this.quotationItems.filter(el => {
						return el.product.catalogBundle.category.type.id === 'ACC'
					})
					servizi = this.quotationItems.filter(el => {
						return el.product.catalogBundle.category.type.id === 'FRU'
					})
					return {
						placche,
						segnaletica,
						accessori
					}
				}
			},

            methods: {
				async deletePosition(pos) {
					if (window.confirm('Vuoi eliminare questa posizione?')) {
						//TODO API Che elimina posizione e riduce di 1 la quantita
						await $.ajax({
							url: "/manager/ajax/quotation-item-positions/" + pos.id,
							method: "DELETE"
						})
							.done(function (res) {
								AP.widget.notify( "success", "Riga cancellata correttamente." );
                                setTimeout(function() {
                                    window.location.reload();
                                }, 1000);
							})
							.fail(function (err) {
								AP.widget.notify( "error", "Errore durante la cancellazione della posizione.");
							})
					}
				},
				getBackgroundColor: function(type) {
					let backgroundColor = 'rgb(232, 93, 68)';
					if (type === 'placche') {
						backgroundColor = 'rgb(68, 130, 232)';
					}
					if (type === 'accessori') {
						backgroundColor = 'rgb(3,166,54)';
					}
					return backgroundColor
				},
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
                    if (this.selectedItemPositionId === position.id) {
                        this.selectedItemPositionId = null;
                        this.selectedItemPosition = {};
                        return;
                    }
                    this.selectedItemPosition = position;
                    this.selectedItemPositionId = position.id;
                },
                getPinStyle(pos) {
                    let quotationItem = this.quotationItems.find(
                        quotationItem => quotationItem.id == pos.quotationItemId
                    );
                    let color = this.getColor(quotationItem);
                    return {
                        backgroundColor: color,
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        transform: 'translate(-50%, -50%) rotate(' + (Number(pos.angle) + 135 || 135) + 'deg)'
                    };
                },
				getPositionFullText(p) {
					return p?.position?.code || 'N/A'
				},
                getSelectionRingStyle(pos) {
                    let quotationItem = this.quotationItems.find(
                        quotationItem => quotationItem.id == pos.quotationItemId
                    );
                    let color = this.getColor(quotationItem);
                    return {
                        borderColor: color,
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        transform: 'translate(-50%, -53%)'
                    };
                },
                getSelectionPositionTextStyle(pos) {
                    let quotationItem = this.quotationItems.find(
                        quotationItem => quotationItem.id == pos.quotationItemId
                    );
                    let color = this.getColor(quotationItem);
                    return {
						backgroundColor: 'white',
						padding: '0.3em',
                        borderColor: color,
						borderRadius: '0.3em',
                        left: `calc(${pos.coordinateX * 100}% + 5px)`,
                        top: `calc(${pos.coordinateY * 100}% - 40px)`,
                        transform: 'translate(-50%, -53%)'
                    };
                },
                getLabelStyle(pos) {
                    return {
                        position: 'absolute',
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        transform: 'translate(-50%, -50%)'
                    };
                },
                getArrowStyle(pos) {
                    return {
                        position: 'absolute',
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        transform: 'translate(+100%, -150%)',
						backgroundColor: 'white',
						padding: '3px',
						borderRadius: '.9em'
                    };
                },
				getDeleteIconStyle(pos) {
					return {
						position: 'absolute',
						left: (pos.coordinateX * 100) + '%',
						top: (pos.coordinateY * 100) + '%',
						transform: 'translate(+220%, -138%)',
						backgroundColor: 'white',
						border: '2px solid red',
						padding: '3px',
						borderRadius: '.9em'
					};
				},
                startDrag(event, pos) {
                    event.preventDefault();
                    this.dragging = true;
                    this.draggedPosition = pos;

                    document.addEventListener('mousemove', this.onDrag);
                    document.addEventListener('mouseup', this.stopDrag);
                },
                getColor(quotationItem) {
                    let background = 'rgb(232, 93, 68)';

                    if (quotationItem) {
                        const name = quotationItem?.product?.category?.type?.name;
                        const firstChar = name ? name.charAt(0).toUpperCase() : '';

                        if (firstChar === 'P') {
                            background = 'rgb(68, 130, 232)';
                        }
                        if (firstChar === 'A') {
                            background = 'rgb(3,166,54)';
                        }
                    }

                    return background;
                },
                onDrag(event) {
                    if (!this.dragging || !this.draggedPosition) return;

                    const overlay = document.querySelector('#plant-to-capture .overlay-layer');
                    if (!overlay) return;
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
                startRotate(event, pos) {
                    event.preventDefault();
                    this.isRotating = true;
                    this.rotatedPosition = pos;

                    // Calcoliamo le coordinate assolute in pixel del centro del pin sulla pagina
                    const overlay = document.querySelector('#plant-to-capture .overlay-layer');
                    if (overlay) {
                        const rect = overlay.getBoundingClientRect();
                        this.pinCenterX = rect.left + (pos.coordinateX * rect.width);
                        this.pinCenterY = rect.top + (pos.coordinateY * rect.height);
                    }
                    // 1. Memorizziamo l'angolo iniziale del pin
                    this.initialPinAngle = Number(pos.angle) || 0;

                    // 2. Calcoliamo l'angolo iniziale del mouse rispetto al centro del pin al momento del click
                    const deltaX = event.clientX - this.pinCenterX;
                    const deltaY = event.clientY - this.pinCenterY;
                    this.initialMouseAngle = (Math.atan2(deltaY, deltaX) * (180 / Math.PI) + 360) % 360;

                    document.addEventListener('mousemove', this.onRotate);
                    document.addEventListener('mouseup', this.stopRotate);
                },

                onRotate(event) {
                    if (!this.isRotating || !this.rotatedPosition) return;

                    // Calcoliamo la distanza tra il mouse e il centro del pin
                    const deltaX = event.clientX - this.pinCenterX;
                    const deltaY = event.clientY - this.pinCenterY;

                    // Angolo corrente del mouse rispetto al centro
                    let currentMouseAngle = (Math.atan2(deltaY, deltaX) * (180 / Math.PI) + 360) % 360;

                    // Differenza rispetto al click iniziale
                    let angleDiff = currentMouseAngle - this.initialMouseAngle;

                    // Nuovo angolo calcolato sommando la differenza all'angolo iniziale
                    let newAngle = this.initialPinAngle + angleDiff;

                    // Normalizzazione dell'angolo tra 0 e 360
                    newAngle = (newAngle % 360 + 360) % 360;

                    // Se il pin ha un orientamento di default (es. se la punta non è a 0° ma a 135°),
                    // puoi aggiungere o sottrarre un eventuale offset per allineare l'angolo alla freccia.
                    // Ad esempio: newAngle = (newAngle + 90) % 360;

                    if (event.shiftKey) {
                        // Rotazione di 1 grado
                        this.rotatedPosition.angle = Math.round(newAngle);
                    } else {
                        // Snap di 45 in 45 gradi
                        let snappedAngle = Math.round(newAngle / 45) * 45;

                        if (snappedAngle >= 360) {
                            snappedAngle = 0;
                        }

                        this.rotatedPosition.angle = snappedAngle;
                    }
                },

                stopRotate() {
                    this.isRotating = false;
                    this.rotatedPosition = null;

                    document.removeEventListener('mousemove', this.onRotate);
                    document.removeEventListener('mouseup', this.stopRotate);
                },

                formatLabelText(p) {
                    let quotationItem = this.quotationItems.find(
                        quotationItem => quotationItem.id == p.quotationItemId
                    );

                    let fullText = `${quotationItem.position ? quotationItem.position.code : 'N/A'}`;

                    if (fullText.length > 3) {
                        return fullText.slice(0, 3);
                    }

                    return fullText;
                },

                savePositions: async function () {
                    var self = this;
                    let quotationItemPositions = this.getPositions();
                    if (quotationItemPositions.length == 0) {
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
                },
                async printPlant() {
                    this.selectedItemPositionId = null;
                    this.selectedItemPosition = {};
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '/manager/ajax/quotation-item-positions-print';
                    form.target = '_blank';

                    const element = document.getElementById( 'plant-to-capture' );

                    const canvas = await html2canvas( element, {
                        useCORS: true,
                        scale: 2
                    });

                    const base64Image = canvas.toDataURL( 'image/png' );

                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'data';
                    input.value = JSON.stringify({
                        image: base64Image,
                        zoneId: this.selectedZoneId
                    });

                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                    document.body.removeChild(form);
                },
                getImageSrc() {
                    const el = document.getElementById('plant-to-capture');
                    const img = el ? el.querySelector('img') : null;

                    return img ? img.src : null;
                },
                getPositions() {
                    let quotationItemPositions = [];
                    this.quotationItems.forEach(item => {
                        if (item.positions && item.positions.length) {
                            item.positions.forEach(pos => {
                                quotationItemPositions.push({
                                    id: pos.id,
                                    coordinateX: pos.coordinateX,
                                    coordinateY: pos.coordinateY,
                                    visible: pos.visible == true ? 1 : 0,
                                    angle: pos.angle || 0,
                                    sequence: pos.sequence,
                                    quotationItemId: item.id,
                                    type: item.product ? item.product.category.type.name : null,
                                    position: item.position ? item.position.code : 'senza posizione' + ' - ' + pos.sequence
                                });
                            });
                        }
                    })
                    return quotationItemPositions;
                }
            },

            mounted: async function () {
                await this.getZones();
				// Se la querystring contiene zoneId, seleziono la zona e carico gli articoli
				const urlParams = new URLSearchParams(window.location.search);
				const zoneIdFromQuery = urlParams.get('zoneId');
				if (zoneIdFromQuery) {
					this.selectedZoneId = zoneIdFromQuery;
					this.getItems();
				}
            }
        });



        AP.loading && AP.loading.hide();
    };

    return pub;
}());