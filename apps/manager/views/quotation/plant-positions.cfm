<script src="https://cdn.jsdelivr.net/npm/vue@2"></script>
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
                            <div class="row">
                                <div class="col-11">
                                    <h5>Filtri Ricerca</h5>
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
                            </div>
                            <div class="row">
                                <div class="col-6">
                                    <h5>Pianta</h5>
                                </div>
                                <div class="col-6">
                                    <h5>Articoli</h5>
                                </div>
                                <div class="col-6 text-center">
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
                                                    <template v-if="p.visible">
                                                        <div
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
                                                        </div>
                                                    </template>
                                                </template>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div v-if="quotationItems.length > 0" style="align-items: center; display: flex; height: 100%;">
                                        <table>
                                            <tr v-for="quotationItem in quotationItems" :key="quotationItem.id" :value="quotationItem.id">
                                                <td>
                                                    {{ quotationItem.product.category.name }} {{ quotationItem.product.line.name }} {{ quotationItem.product.model.name }} {{ quotationItem.product.finish.code }}
                                                    <div style="margin-left: 10px;" v-if="quotationItem.positions.length">
                                                        <table>
                                                            <tr v-for="p in quotationItem.positions" :key="p.sequence" :value="p.id" :class="p.id == selectedItemPositionId ? 'position-selected' : 'position'" style="padding: 5px;">
                                                                <td :id="p.id" @click="selectPosition(p)" style="padding: 10px;">
                                                                    {{ quotationItem.position ? quotationItem.position.code : 'senza posizione' }} - {{ p.sequence }}
                                                                </td>
                                                                <td style="padding: 10px;">
                                                                    <div v-if="p.id == selectedItemPositionId" style="display: flex;">
                                                                        <div>
                                                                            <label>Coordinate X</label>
                                                                            <input class="form-control" v-model="selectedItemPosition.coordinateX">
                                                                        </div>
                                                                        <div style="margin-left: 5px;">
                                                                            <label>Coordinate Y</label>
                                                                            <input class="form-control" v-model="selectedItemPosition.coordinateY">
                                                                        </div>
                                                                        <div style="margin-left: 5px;">
                                                                            <label>Angolo</label>
                                                                            <input type="number" class="form-control" v-model.number="selectedItemPosition.angle">
                                                                        </div>
                                                                        <div style="margin-left: 5px;">
                                                                            <label>Visibile</label><br>
                                                                            <input style="margin-left: 15px; margin-top: 10px;" type="checkbox" class="form-check-input" v-model="selectedItemPosition.visible">
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
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
    .overlay-layer {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }

    .position-selected {
        height: 64px;
        color: white;
        cursor: pointer;
        background-color: rgb(68, 130, 232);
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
    </style>
</cfoutput>