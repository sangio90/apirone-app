1<script src="https://cdn.jsdelivr.net/npm/vue@2"></script>
<cfoutput>
    <div id="quotation-plant-positions-root">

        <div class="row mb-2">
            <div class="col-12 pt-2">
				#pageTitle()#
            </div>
			<div class="col-12 text-end">
                #button( href="/manager/quotations/#prc.quotation.getId()#", size="sm", label="Torna al preventivo", icon="arrow-left", class="me-4" )#
			</div>
        </div>

        <div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
                        <div id="vue-plant-positions-app" data-quotation-id="#prc.quotation.getId()#" data-base-url="#prc.baseUrl#">
                            <div class="loadingOverlay" v-if="isLoading">
                                <i class="fas fa-spinner fa-spin fa-3x"></i>
                            </div>
							<div class="row" style="font-size: .9em; font-style: italic;">
								<div class="col-11">
									Quando si ruota un oggetto, è possibile usare gli "scatti" di rotazione oppure tenere premuto "shift" per una rotazione libera. Per spostare un oggetto, è sufficiente trascinarlo con il mouse.
								</div>
								<div class="col-1 d-flex align-items-center justify-content-end">
									<button class="btn btn-primary" @click="savePositions" :disabled="!selectedZoneId">Salva posizioni <i class="fas fa-save"></i></button>
									<button class="btn btn-primary" style="margin-left: 10px;" @click="printPlant" :disabled="!selectedZoneId">Stampa pianta <i class="fas fa-print"></i></button>
								</div>
							</div>
                            <div class="row">
                                <div class="col-2 my-3" >
                                    <label>Zone</label>
                                    <select class="form-control" v-model="selectedZoneId" @change="getItems">
                                        <option value="">-- Seleziona una zona</option>
                                        <option v-for="zone in zones" :key="zone.id" :value="zone.id">
                                            {{ zone.name }}
                                        </option>
                                    </select>
                                </div>
                                <div class="col-2" style="padding-top: 3.6em;">
                                    <input type="checkbox" class="form-check-input" v-model="showAccessori">
                                    <label>Mostra Accessori</label>
                                </div>
                                <div class="col-2" style="padding-top: 3.6em;">
                                    <input type="checkbox" class="form-check-input" v-model="showSegnaletica">
                                    <label>Mostra Segnaletica</label>
                                </div>
                                <div class="col-2" style="padding-top: 3.6em;">
                                    <input type="checkbox" class="form-check-input" v-model="showPlacche">
                                    <label>Mostra Placche</label>
                                </div>
                            </div>
                            <div class="row">
                            	<div class="col-12 d-flex align-items-center justify-content-around gap-2">
                            		<button type="button" class="btn btn-primary" @click="addAccessorio">Aggiungi accessorio</button>
                            		<button type="button" class="btn btn-primary" @click="addSegnaletica">Aggiungi segnaletica</button>
                            		<button type="button" class="btn btn-primary" @click="addPlacca">Aggiungi placca</button>
								</div>
                            </div>
                            <div class="row">
                                <div class="col-6">
                                    <h5>Pianta</h5>
                                </div>
                                <div class="col-6">
                                    <h5>Articoli</h5>
                                </div>
                                <div class="col-12 text-center">
                                    <div style="position: relative; display: inline-block;" v-if="selectedZone.image" id="plant-to-capture">
                                        <img
                                            :src="selectedZone.image.uri"
                                            crossorigin="anonymous"
                                            alt="Pianta del preventivo"
                                            style="max-height: 700px;"
                                        >
                                        <div class="overlay-layer">
                                            <div v-for="quotationItem in quotationItems" :key="quotationItem.id">
                                                <template v-for="p in quotationItem.positions">
                                                    <template v-if="p.visible && (showAccessori && quotationItem?.product?.category?.type?.id == 'ACC' || showSegnaletica && quotationItem?.product?.category?.type?.id == 'SEG' || showPlacche && quotationItem?.product?.category?.type?.id == 'PLA')">
                                                        <div
															:class="{ 'red-border': quotationItem.quantity < quotationItem.positions.length, 'pin-instance': quotationItem.instanceGroupId }"
                                                            class="pin"
                                                            :style="getPinStyle(p)"
                                                            @click="selectPosition(p)"
                                                            @mousedown="startDrag($event, p)"
                                                            :key="'pin-' + p.id"
                                                        >
                                                        </div>
                                                        <div
                                                            class="pin-label"
                                                            :style="getLabelStyle(p)"
                                                            :key="'label-' + p.id"
                                                        >
                                                            {{ formatLabelText(p) }}
                                                        </div>
                                                        <div v-if="p.id == selectedItemPositionId">
                                                        	<div class="position-full-text" :style="getSelectionPositionTextStyle(p)">
                                                        		{{ getPositionFullText(quotationItem) }}
                                                        	</div>
                                                            <div
                                                                class="selection-ring"
                                                                :style="getSelectionRingStyle(p)"
                                                                :key="'ring-' + p.id"
                                                                :style="{ borderColor: getColor(quotationItem) }"
                                                            ></div>
                                                            <img
                                                                src="/assets/main/img/rotation-arrow.png"
                                                                alt="Ruota Pin"
                                                                class="rotation-arrow"
                                                                :style="getArrowStyle(p)"
                                                                @mousedown.stop="startRotate($event, p)"
                                                                :key="'arrow-' + p.id"
                                                            />
                                                            <img
                                                                src="/assets/main/img/delete-icon.jpg"
                                                                alt="Elimina Pin"
                                                                class="delete-icon"
                                                                :style="getDeleteIconStyle(p)"
                                                                @click="deletePosition(p)"
                                                                :key="`deletearrow-${p.id}`"
                                                            />
                                                            <div
                                                                class="plant-action-btn"
                                                                :style="getDuplicateBtnStyle(p)"
                                                                @click.stop="openDuplicateDialog(p, quotationItem)"
                                                                :key="'dup-' + p.id"
                                                            ><i class="fas fa-clone"></i></div>
                                                            <div
                                                                class="plant-action-btn"
                                                                :style="getMultiplierBtnStyle(p)"
                                                                @click.stop="toggleMultiplierPanel(p)"
                                                                :key="'mul-' + p.id"
                                                            ><i class="fas fa-expand-alt"></i></div>
                                                            <div
                                                                v-if="multiplierPos && multiplierPos.id === p.id"
                                                                :style="getMultiplierPanelStyle(p)"
                                                                :key="'mulpanel-' + p.id"
                                                                @click.stop
                                                            >
                                                                <button class="btn btn-sm btn-outline-secondary" @click.stop="changeMultiplier(p, -10)">-</button>
                                                                <span style="min-width:40px;text-align:center;">{{ p.sizeMultiplier || 100 }}%</span>
                                                                <button class="btn btn-sm btn-outline-secondary" @click.stop="changeMultiplier(p, 10)">+</button>
                                                            </div>
                                                        </div>
                                                    </template>
                                                </template>
                                            </div>

                                            <!-- Marker draft (segnaposto non ancora configurati) -->
                                            <template v-for="draft in drafts">
                                                <div
                                                    class="pin pin-draft"
                                                    :style="getDraftPinStyle(draft)"
                                                    @click.stop="selectDraft(draft)"
                                                    @mousedown.stop="startDraftDrag($event, draft)"
                                                    :key="'dpin-' + draft.id"
                                                ></div>
                                                <div class="pin-label pin-label-draft" :style="getDraftLabelStyle(draft)" :key="'dlabel-' + draft.id">
                                                    {{ draft.itemType }}
                                                </div>
                                                <template v-if="selectedDraftId === draft.id">
                                                    <img
                                                        src="/assets/main/img/rotation-arrow.png"
                                                        alt="Ruota"
                                                        class="rotation-arrow"
                                                        :style="getDraftArrowStyle(draft)"
                                                        @mousedown.stop="startDraftRotate($event, draft)"
                                                        :key="'darrow-' + draft.id"
                                                    />
                                                    <img
                                                        src="/assets/main/img/delete-icon.jpg"
                                                        alt="Elimina"
                                                        class="delete-icon"
                                                        :style="getDraftDeleteStyle(draft)"
                                                        @click.stop="deleteDraft(draft)"
                                                        :key="'ddelete-' + draft.id"
                                                    />
                                                    <div
                                                        class="draft-configure-btn"
                                                        :style="{ position: 'absolute', left: (draft.coordinateX * 100) + '%', top: 'calc(' + (draft.coordinateY * 100) + '% + 50px)', transform: 'translate(-50%, 0)', pointerEvents: 'auto' }"
                                                        @click.stop="openConfigureDraft(draft)"
                                                        :key="'dcfg-' + draft.id"
                                                    >Configura</div>
                                                </template>
                                            </template>

                                        </div>
                                    </div>
                                </div>
                                <div class="col-12">
                                    <div v-if="quotationItems.length > 0" style="align-items: center; display: flex; height: 100%;">
                                        <div class="quotation-list">
                                        	<div v-for="(quotationItemByType, index) in filteredQuotationItemsGroupedByType" :key="quotationItemByType.type" style="margin-right: 20px; display: flex">
                                        	<div
												v-for="quotationItem in quotationItemByType"
												:key="quotationItem.id"
												class="quotation-item"
												:style="{ border: '2px solid', borderColor: getColor(quotationItem), backgroundColor: 'white'}"
												>
													<div>
											{{ quotationItem.type }}<span v-if="quotationItem.instanceGroupId" :title="'Istanza (' + quotationItem.instanceGroupCount + ')'" style="margin-left:.4em; color:##888; font-size:.8em;"><i class="fas fa-link"></i></span>
										</div>
													<!-- HEADER ITEM -->
													<div class="quotation-item-header">
														{{ quotationItem.product.category.name }}
														{{ quotationItem.product.line.name }}
														{{ quotationItem.product.model.name }}
														{{ quotationItem.product.finish.code }}
													</div>

													<div>Quantità nel preventivo: {{ quotationItem.quantity }}</div>

													<!-- POSITIONS -->
													<div
														v-if="quotationItem.positions.length"
														style="display: block; margin-left: 10px;"
													>
														<div
															style="display: flex; float: left; cursor: pointer;"
															v-for="p in quotationItem.positions"
															:key="p.id"
															class="position-card"
															:class="{ 'red-border': quotationItem.quantity < quotationItem.positions.length, 'with-margin': quotationItem.quantity < quotationItem.positions.length }"
															@click="selectPosition(p)"
														>
															<div style="margin-top: .3em;">
																<input type="checkbox" class="form-check-input" v-model="p.visible" @change="syncInstanceVisible(p, quotationItem)">
															</div>
															<div class="position-title" style="margin-right: .3em;">
																{{ quotationItem.position ? quotationItem.position.code : 'N/A' }}
															</div>
															<img
																src="/assets/main/img/delete-icon.jpg"
																style="width: 20px; height: 20px; margin-top: .3em;"
																alt="Elimina Pin"
																@click="deletePosition(p)"
																:key="`deletearrow-${p.id}`"
															/>
														</div>
													</div>
												</div>
											</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        </div>
					</div>
				</section>
			</div>
		</div>
    </div>
    <style>

    .red-border {
    	border: 2px dashed red!important;
    }
	.with-margin {
		margin: .3em;
		padding: .3em;
	}

    .overlay-layer {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }

    .position {
        height: 64px;
        cursor: pointer;
        background-color: transparent;
    }

    .loadingOverlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(121, 121, 121, 0.663);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
    }

    .pin {
        position: absolute;
        cursor: pointer;
        pointer-events: auto;
        transform-origin: center;
        border-radius: 50% 50% 50% 0;
        width: 35px;
        height: 35px;
    }

    .selection-ring {
        position: absolute;
        width: 50px;
        height: 50px;
        border: 2px solid;
        border-radius: 38%;
        pointer-events: none;
        transform-origin: center;
    }

    .pin-label {
        position: absolute;
        pointer-events: none;
        font-size: 10px;
        max-width: 35px;
        white-space: normal;
        word-wrap: break-word;
        overflow-wrap: break-word;
        text-align: center;
        line-height: 1.2;
        color: white;
    }

    .rotation-arrow {
        position: absolute;
        width: 20px;
        height: 20px;
        padding: 10px;
        box-sizing: content-box;
        opacity: 1;
        pointer-events: auto;
        cursor: move;
        transform-origin: center;
        object-fit: contain;
    }

	.delete-icon {
        position: absolute;
        width: 20px;
        height: 20px;
        padding: 10px;
        box-sizing: content-box;
        opacity: 1;
        pointer-events: auto;
        cursor: pointer;
        transform-origin: center;
        object-fit: contain;
    }

    .position-full-text {
        position: absolute;
        height: 20px;
        padding: 10px;
        box-sizing: content-box;
        opacity: 1;
        pointer-events: auto;
        cursor: move;
        transform-origin: center;
        object-fit: contain;
    }

    .position-title {
        padding: .3em;
    }

    .quotation-item {
    	display: inline-block;
        margin-top: .3em;
        margin-left: .3em;
        border-radius: 10px;
        background-color: rgb(68, 130, 232, 0.2);
        padding: 10px;
        max-width: 400px !important;
        max-height: none !important;
    }
    .pin-draft {
        border: 3px dashed ##999 !important;
        background-color: rgba(200, 200, 200, 0.65) !important;
    }
    .pin-label-draft {
        color: ##333;
        font-weight: bold;
        font-size: 9px;
    }
    .draft-configure-btn {
        background: ##0d6efd;
        color: white;
        font-size: 11px;
        padding: 3px 8px;
        border-radius: 4px;
        cursor: pointer;
        white-space: nowrap;
        z-index: 10;
        pointer-events: auto;
    }
    .draft-configure-btn:hover {
        background: ##0b5ed7;
    }
    .pin-instance {
        outline: 2px dashed rgba(255,255,255,0.9);
        outline-offset: -5px;
    }
    .plant-action-btn {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 26px;
        height: 26px;
        border-radius: 50%;
        pointer-events: auto;
        cursor: pointer;
        font-size: 11px;
        z-index: 10;
    }
    </style>

    #view( "quotation/signage-modal" )#
    #view( "quotation/accessory-modal" )#
    #view( "quotation/plate-modal-vue" )#
    #view( "quotation/posizione-in-pianta-modal" )#

    <div class="modal fade" id="item-duplicate-modal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Duplica articolo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p class="mb-3">Come vuoi duplicare questo articolo?</p>
                    <div class="d-grid gap-2">
                        <button id="item-duplicate-copy-btn" class="btn btn-outline-primary">
                            <i class="fas fa-copy me-2"></i>Copia
                            <small class="d-block text-muted">Crea un articolo indipendente</small>
                        </button>
                        <button id="item-duplicate-instance-btn" class="btn btn-outline-secondary">
                            <i class="fas fa-link me-2"></i>Istanza
                            <small class="d-block text-muted">Crea una copia collegata (sincronizzata)</small>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    #template( view="jstemplate/quotation/quotation-pricing-totals-item-tmpl" )#
    #template( view="jstemplate/quotation/quotation-position-suggest-row-tmpl" )#
    #template( view="jstemplate/quotation/signage-line-row-tmpl" )#
    #template( view="jstemplate/quotation/signage-line-preview-row-tmpl" )#

</cfoutput>