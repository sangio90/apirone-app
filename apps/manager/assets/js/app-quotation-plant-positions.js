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
				drafts: [],
				draggingDraft: false,
				draggedDraft: null,
				isRotatingDraft: false,
				rotatedDraft: null,
				selectedDraftId: null,
				multiplierPos: null,
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
					const getItems = this.getItems
					if (window.confirm('Vuoi eliminare questa posizione?')) {
						await $.ajax({
							url: "/manager/ajax/quotation-item-positions/" + pos.id,
							method: "DELETE"
						})
							.done(function (res) {
								AP.widget.notify( "success", "Riga cancellata correttamente." );
								getItems();
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
                        // AP.widget.notify( "warning", "Selezionare una zona.");
                        self.quotationItems = [];
                        self.selectedZone = {};
                        return;
                    }

					const url = new URL(window.location.href);
					const params = new URLSearchParams(url.search);

					params.set('selectedZoneId', self.selectedZoneId); // aggiunge o aggiorna

					url.search = params.toString();

					window.history.pushState({}, '', url);

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
                        await self.getDrafts();

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
                    const scale = (pos.sizeMultiplier || 100) / 100;
                    const size = Math.round(35 * scale);
                    return {
                        backgroundColor: color,
                        left: (pos.coordinateX * 100) + '%',
                        top: (pos.coordinateY * 100) + '%',
                        width: size + 'px',
                        height: size + 'px',
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
                    if (!quotationItem) return 'rgb(232, 93, 68)';

                    const typeId = quotationItem?.product?.catalogBundle?.category?.type?.id;
                    const catName = (quotationItem?.product?.catalogBundle?.category?.name || '').toUpperCase();

                    if (typeId === 'PLA') {
                        return 'rgb(68, 130, 232)';   // blu – placche
                    }
                    if (catName.includes('EMERGENZA')) {
                        return 'rgb(220, 30, 30)';    // rosso – segnaletica emergenza
                    }
                    if (catName.includes('INTERNA')) {
                        return 'rgb(34, 139, 34)';    // verde – segnaletica interna
                    }
                    if (catName.includes('ESTERNA')) {
                        return 'rgb(139, 90, 43)';    // marrone – segnaletica esterna
                    }
                    return 'rgb(128, 0, 128)';         // viola – accessori altre linee
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
                                    sizeMultiplier: pos.sizeMultiplier || 100,
                                    quotationItemId: item.id,
                                    type: item.product ? item.product.category.type.name : null,
                                    position: item.position ? item.position.code : 'senza posizione'
                                });
                            });
                        }
                    })
                    return quotationItemPositions;
                },
				addAccessorio() { this.addDraft('ACC'); },
				addSegnaletica() { this.addDraft('SEG'); },
				addPlacca()     { this.addDraft('PLA'); },

				async addDraft(itemType) {
					if (!this.selectedZoneId) {
						AP.widget.notify('warning', 'Selezionare prima una zona.');
						return;
					}
					try {
						const res = await $.ajax({
							url: '/manager/ajax/quotation-item-drafts/',
							method: 'POST',
							contentType: 'application/json',
							data: JSON.stringify({
								quotationId: this.quotationId,
								quotationZoneId: this.selectedZoneId,
								itemType: itemType
							})
						});
						this.drafts.push(res.data);
					} catch(e) {
						AP.widget.notify('error', 'Errore durante la creazione del segnaposto.');
					}
				},

				async getDrafts() {
					if (!this.selectedZoneId) { this.drafts = []; return; }
					try {
						const res = await $.ajax({
							url: '/manager/ajax/quotation-item-drafts/zone/' + this.selectedZoneId,
							method: 'GET'
						});
						this.drafts = res.data || [];
					} catch(e) {
						AP.widget.notify('error', 'Errore durante il caricamento dei segnaposto.');
					}
				},

				getDraftPinStyle(draft) {
					return {
						left: (draft.coordinateX * 100) + '%',
						top:  (draft.coordinateY * 100) + '%',
						transform: 'translate(-50%, -50%) rotate(' + (Number(draft.angle) + 135 || 135) + 'deg)'
					};
				},

				getDraftLabelStyle(draft) {
					return {
						position: 'absolute',
						left: (draft.coordinateX * 100) + '%',
						top:  (draft.coordinateY * 100) + '%',
						transform: 'translate(-50%, -50%)'
					};
				},

				getDraftArrowStyle(draft) {
					const offset = 30;
					return {
						position: 'absolute',
						left: 'calc(' + (draft.coordinateX * 100) + '% + ' + offset + 'px)',
						top:  'calc(' + (draft.coordinateY * 100) + '% - ' + offset + 'px)',
						pointerEvents: 'auto',
						cursor: 'move'
					};
				},

				getDraftDeleteStyle(draft) {
					const offset = 30;
					return {
						position: 'absolute',
						left: 'calc(' + (draft.coordinateX * 100) + '% + ' + offset + 'px)',
						top:  'calc(' + (draft.coordinateY * 100) + '% + ' + offset + 'px)',
						pointerEvents: 'auto',
						cursor: 'pointer'
					};
				},

				selectDraft(draft) {
					this.selectedDraftId = (this.selectedDraftId === draft.id) ? null : draft.id;
				},

				startDraftDrag(event, draft) {
					event.preventDefault();
					this.draggingDraft = true;
					this.draggedDraft  = draft;
					document.addEventListener('mousemove', this.onDraftDrag);
					document.addEventListener('mouseup',   this.stopDraftDrag);
				},

				onDraftDrag(event) {
					if (!this.draggingDraft || !this.draggedDraft) return;
					const el   = document.getElementById('plant-to-capture');
					if (!el) return;
					const rect = el.getBoundingClientRect();
					const x    = event.clientX - rect.left;
					const y    = event.clientY - rect.top;
					if (x < 0 || y < 0 || x > rect.width || y > rect.height) return;
					this.draggedDraft.coordinateX = +(x / rect.width).toFixed(4);
					this.draggedDraft.coordinateY = +(y / rect.height).toFixed(4);
				},

				async stopDraftDrag() {
					if (!this.draggingDraft || !this.draggedDraft) return;
					document.removeEventListener('mousemove', this.onDraftDrag);
					document.removeEventListener('mouseup',   this.stopDraftDrag);
					const draft = this.draggedDraft;
					this.draggingDraft = false;
					this.draggedDraft  = null;
					try {
						await $.ajax({
							url: '/manager/ajax/quotation-item-drafts/' + draft.id + '/position',
							method: 'POST',
							contentType: 'application/json',
							data: JSON.stringify({ coordinateX: draft.coordinateX, coordinateY: draft.coordinateY, angle: draft.angle || 0 })
						});
					} catch(e) {
						AP.widget.notify('error', 'Errore salvataggio posizione segnaposto.');
					}
				},

				startDraftRotate(event, draft) {
					event.preventDefault();
					this.isRotatingDraft = true;
					this.rotatedDraft    = draft;
					this.initialMouseX   = event.clientX;
					this.initialAngle    = draft.angle || 0;
					document.addEventListener('mousemove', this.onDraftRotate);
					document.addEventListener('mouseup',   this.stopDraftRotate);
				},

				onDraftRotate(event) {
					if (!this.isRotatingDraft || !this.rotatedDraft) return;
					const delta    = event.clientX - this.initialMouseX;
					const newAngle = this.initialAngle + Math.round(delta * this.rotationSpeedFactor);
					if (event.shiftKey) {
						this.rotatedDraft.angle = newAngle;
					} else {
						this.rotatedDraft.angle = Math.round(newAngle / 45) * 45;
					}
				},

				async stopDraftRotate() {
					if (!this.isRotatingDraft || !this.rotatedDraft) return;
					document.removeEventListener('mousemove', this.onDraftRotate);
					document.removeEventListener('mouseup',   this.stopDraftRotate);
					const draft = this.rotatedDraft;
					this.isRotatingDraft = false;
					this.rotatedDraft    = null;
					try {
						await $.ajax({
							url: '/manager/ajax/quotation-item-drafts/' + draft.id + '/position',
							method: 'POST',
							contentType: 'application/json',
							data: JSON.stringify({ coordinateX: draft.coordinateX, coordinateY: draft.coordinateY, angle: draft.angle || 0 })
						});
					} catch(e) {
						AP.widget.notify('error', 'Errore salvataggio rotazione segnaposto.');
					}
				},

				async deleteDraft(draft) {
					if (!window.confirm('Eliminare questo segnaposto?')) return;
					try {
						await $.ajax({ url: '/manager/ajax/quotation-item-drafts/' + draft.id, method: 'DELETE' });
						this.drafts = this.drafts.filter(d => d.id !== draft.id);
						if (this.selectedDraftId === draft.id) this.selectedDraftId = null;
					} catch(e) {
						AP.widget.notify('error', 'Errore eliminazione segnaposto.');
					}
				},

				getDuplicateBtnStyle(pos) {
					return {
						position: 'absolute',
						left: (pos.coordinateX * 100) + '%',
						top: (pos.coordinateY * 100) + '%',
						transform: 'translate(+100%, +50%)',
						backgroundColor: 'white',
						border: '2px solid #0d6efd',
						padding: '3px 6px',
						borderRadius: '.9em',
						cursor: 'pointer',
						fontSize: '10px',
						whiteSpace: 'nowrap',
						pointerEvents: 'auto',
						zIndex: 10
					};
				},
				getMultiplierBtnStyle(pos) {
					return {
						position: 'absolute',
						left: (pos.coordinateX * 100) + '%',
						top: (pos.coordinateY * 100) + '%',
						transform: 'translate(+220%, +50%)',
						backgroundColor: 'white',
						border: '2px solid #198754',
						padding: '3px 6px',
						borderRadius: '.9em',
						cursor: 'pointer',
						fontSize: '10px',
						whiteSpace: 'nowrap',
						pointerEvents: 'auto',
						zIndex: 10
					};
				},
				getMultiplierPanelStyle(pos) {
					return {
						position: 'absolute',
						left: (pos.coordinateX * 100) + '%',
						top: (pos.coordinateY * 100) + '%',
						transform: 'translate(-50%, +110%)',
						backgroundColor: 'white',
						border: '1px solid #ccc',
						padding: '4px 8px',
						borderRadius: '.5em',
						pointerEvents: 'auto',
						zIndex: 20,
						display: 'flex',
						alignItems: 'center',
						gap: '4px',
						whiteSpace: 'nowrap',
						boxShadow: '0 2px 6px rgba(0,0,0,0.2)'
					};
				},
				toggleMultiplierPanel(pos) {
					if (this.multiplierPos && this.multiplierPos.id === pos.id) {
						this.multiplierPos = null;
					} else {
						this.multiplierPos = pos;
					}
				},
				openDuplicateDialog(pos, quotationItem) {
					this._pendingDuplicate = { pos, quotationItem };
					$('#item-duplicate-modal').modal('show');
				},
				async executeDuplicate(asInstance) {
					if (!this._pendingDuplicate) return;
					var pos = this._pendingDuplicate.pos;
					var quotationItem = this._pendingDuplicate.quotationItem;
					this._pendingDuplicate = null;
					$('#item-duplicate-modal').modal('hide');
					try {
						await $.ajax({
							url: '/manager/ajax/quotation-items/' + quotationItem.id + '/duplicate',
							method: 'POST',
							contentType: 'application/json',
							data: JSON.stringify({
								asInstance: asInstance,
								position: {
									coordinateX: pos.coordinateX,
									coordinateY: pos.coordinateY,
									visible: pos.visible ? 1 : 0,
									angle: pos.angle || 0,
									sizeMultiplier: parseInt(pos.sizeMultiplier, 10) || 100
								}
							})
						});
						AP.widget.notify('success', 'Articolo duplicato correttamente.');
						this.getItems();
					} catch(e) {
						AP.widget.notify('error', 'Errore durante la duplicazione.');
					}
				},
				syncInstanceVisible(pos, quotationItem) {
					if (!quotationItem.instanceGroupId) return;
					var self = this;
					var newVisible = pos.visible;
					self.quotationItems.forEach(function(item) {
						if (item.instanceGroupId === quotationItem.instanceGroupId && item.id !== quotationItem.id) {
							item.positions.forEach(function(p) {
								self.$set(p, 'visible', newVisible);
							});
						}
					});
				},
				changeMultiplier(pos, delta) {
					var newVal = Math.max(10, Math.min(500, (parseInt(pos.sizeMultiplier, 10) || 100) + delta));
					this.$set(pos, 'sizeMultiplier', newVal);
				},

				openConfigureDraft(draft) {
					AP.page.pendingDraftId = draft.id;
					// Aggiorna lo shim detail.config con la zona corrente
					var self = this;
					var currentZone = self.zones.find(function(z) { return z.id === self.selectedZoneId; }) || { id: self.selectedZoneId, name: "" };
					AP.quotation.detail._plantZone = { id: currentZone.id, name: currentZone.name };
					AP.quotation.detail._plantZones = self.zones.map(function(z) { return { id: z.id, name: z.name }; });
					if (draft.itemType === "ACC") AP.accessory.modal.new();
					else if (draft.itemType === "SEG") AP.signage.modal.new();
					else if (draft.itemType === "PLA") AP.plate.modal.new();
				},
            },

            mounted: async function () {
                await this.getZones();
				// Se la querystring contiene zoneId, seleziono la zona e carico gli articoli
				const urlParams = new URLSearchParams(window.location.search);
				const zoneIdFromQuery = urlParams.get('selectedZoneId');
				if (zoneIdFromQuery) {
					this.selectedZoneId = zoneIdFromQuery;
					this.getItems();
				}

				var self = this;
				document.getElementById('item-duplicate-copy-btn').addEventListener('click', function() {
					self.executeDuplicate(false);
				});
				document.getElementById('item-duplicate-instance-btn').addEventListener('click', function() {
					self.executeDuplicate(true);
				});
            }
        });

        // Espone il VM per uso delle modali accessorio/segnaletica/placca
        window.plantPositionsVm = vm;

        // Shim AP.quotation.detail.config() richiesto dalle modali Kendo/Vue
        AP.namespace("quotation.detail");
        AP.quotation.detail._plantZone  = { id: "", name: "" };
        AP.quotation.detail._plantZones = [];
        AP.quotation.detail.config = function() {
            return {
                zone:  AP.quotation.detail._plantZone,
                zones: AP.quotation.detail._plantZones
            };
        };

        AP.loading && AP.loading.hide();
    };

    return pub;
}());