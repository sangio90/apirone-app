<cfoutput>
<!---
    PLANNING/PROJECTS.CFM
    =====================
    Ore progetti per la pianificazione ( Gantt ): elenco dei preventivi
    "Confermato da cliente" e "Convertito in ordine" con le ore di attività
    stimate per tipo e lo stato del progetto. Un progetto concluso esce
    dall'elenco e dal Gantt ( colonna "Da pianificare" e vista Preventivi ).
    App Vue 2 montata su ##planning-projects-app ( app-planning-projects.js ).
--->
<script src="/assets/#prc.staticVersion#/main/js/vue2.js"></script>

<div id="planning-projects-app" v-cloak>

    <div class="row">
        <div class="col-12">
            #pageTitle()#
        </div>
    </div>

    <section class="card">
        <div class="card-body">

            <div class="row d-flex align-items-end mb-3">
                <div class="col-sm-4">
                    <label class="col-form-label">Cerca</label>
                    <input type="text" class="form-control" v-model="filters.str" placeholder="Numero, nome o cliente">
                </div>
                <div class="col-sm-3">
                    <div class="form-check mt-4">
                        <input class="form-check-input" type="checkbox" id="pp-show-completed" v-model="filters.showCompleted">
                        <label class="form-check-label" for="pp-show-completed">Mostra i progetti conclusi</label>
                    </div>
                </div>
                <div class="col-sm-5 text-end text-muted small">
                    Per ogni attività: ore stimate ( si pianificano nel <a href="/manager/planning/gantt">Gantt</a> sulle persone del tipo
                    corrispondente ) e budget in euro, facoltativo.
                    <div class="pp-legend mt-1">
                        Sotto ogni attività le ore già pianificate:
                        <span class="pp-planned">pianificate</span>
                        <span class="pp-planned done">pari alla stima</span>
                        <span class="pp-planned over">oltre la stima</span>
                        <span class="pp-planned extra">+ extra</span>
                    </div>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-sm table-hover align-middle planning-projects-table">
                    <thead>
                        <tr>
                            <th>Preventivo</th>
                            <th v-for="type in workTypes" :key="type.id" class="text-center pp-hours-col">
                                <span class="pp-dot" :style="{ backgroundColor: type.color }"></span>{{ type.activity }}
                            </th>
                            <th class="text-end">Totale</th>
                            <th class="text-center" style="width: 110px;">Concluso</th>
                            <th style="width: 30px;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="project in filteredProjects" :key="project.id" :class="{ 'pp-completed': project.completed }">
                            <td>
                                <a :href="'/manager/quotations/' + project.id" target="_blank" class="fw-bold">
                                    n. {{ project.number }}<template v-if="project.version">/{{ project.version }}</template>
                                </a>
                                <span class="badge ms-1" :class="project.statusId === 'CON' ? 'bg-success' : 'bg-info'">
                                    {{ project.statusId === 'CON' ? 'Convertito in ordine' : 'Confermato da cliente' }}
                                </span>
                                <div class="small pp-project-ref">
                                    {{ project.rifLibero || project.name }}<span v-if="project.customer" class="text-muted"><template v-if="project.rifLibero || project.name"> · </template>{{ project.customer }}</span>
                                </div>
                            </td>
                            <td v-for="type in workTypes" :key="type.id" class="text-center">
                                <div class="pp-input-group" title="Ore stimate">
                                    <input type="number" min="0" step="0.5"
                                           class="form-control form-control-sm text-center pp-hours-input"
                                           v-model.number="project.form[ type.id ]"
                                           @change="save( project )">
                                    <span class="pp-unit">h</span>
                                </div>
                                <div class="pp-input-group mt-1" title="Budget ( costo stimato ), facoltativo">
                                    <input type="number" min="0" step="10"
                                           class="form-control form-control-sm text-center pp-hours-input pp-budget-input"
                                           v-model="project.budgets[ type.id ]"
                                           placeholder="budget"
                                           @change="save( project )">
                                    <span class="pp-unit">€</span>
                                </div>
                                <!--- riga di altezza fissa: gli input restano allineati anche senza ore pianificate --->
                                <div class="pp-planned-line">
                                    <span v-if="planned( project, type.id ) > 0" class="pp-planned" :class="plannedClass( project, type.id )"
                                          title="Ore già pianificate nel Gantt">{{ format( planned( project, type.id ) ) }} h</span>
                                    <span v-if="extra( project, type.id ) > 0" class="pp-planned extra"
                                          title="Ore extra pianificate, oltre la stima">+{{ format( extra( project, type.id ) ) }}</span>
                                </div>
                            </td>
                            <td class="text-end">
                                <strong>{{ format( total( project ) ) }} h</strong>
                                <div class="small text-muted" title="Ore già pianificate nel Gantt">{{ format( totalPlanned( project ) ) }} h pianificate</div>
                                <div class="small" v-if="totalBudget( project ) !== null">{{ formatMoney( totalBudget( project ) ) }}</div>
                            </td>
                            <td class="text-center">
                                <div class="form-check form-switch d-inline-block pp-switch">
                                    <input class="form-check-input" type="checkbox" v-model="project.completed" @change="toggleCompleted( project )"
                                           :title="project.completed ? 'Concluso: non compare più nel Gantt' : 'Segna come concluso'">
                                </div>
                            </td>
                            <td class="text-center">
                                <i v-if="project.saving" class="fas fa-spinner fa-spin text-muted"></i>
                                <i v-else-if="project.saved" class="fas fa-check text-success"></i>
                            </td>
                        </tr>
                        <tr v-if="!loading && !filteredProjects.length">
                            <td :colspan="workTypes.length + 4" class="text-center text-muted py-3">
                                Nessun progetto. Compaiono qui i preventivi "Confermato da cliente" e "Convertito in ordine".
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>
    </section>

</div>

<style>
    ##planning-projects-app[v-cloak] { display: none; }
    .pp-hours-col { width: 96px; white-space: nowrap; }
    .pp-hours-input { width: 74px; padding-left: 4px; padding-right: 4px; }
    .pp-input-group { display: flex; align-items: center; justify-content: center; gap: 3px; }
    .pp-unit { width: 10px; font-size: 11px; color: ##6b7684; }
    .pp-budget-input { background: ##fbfcfe; }
    .pp-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 4px; }
    .pp-planned-line { height: 18px; margin-top: 3px; }
    .pp-planned { display: inline-block; padding: 0 6px; font-size: 11px; line-height: 16px; color: ##6b7684; background: ##eef1f5; border-radius: 999px; }
    .pp-planned.done { color: ##fff; background: ##2f9e44; }
    .pp-planned.over { color: ##fff; background: ##e03131; font-weight: 600; }
    .pp-planned.extra { color: ##1d2b3a; background: ##ffd43b; font-weight: 600; }
    .pp-legend .pp-planned { margin-left: 4px; }
    .pp-project-ref { max-width: 360px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    ##planning-projects-app .pp-switch { padding-left: 0; min-height: 0; }
    ##planning-projects-app .pp-switch .form-check-input { width: 48px; height: 26px; margin: 0; float: none; cursor: pointer; }
    .pp-completed td { opacity: .6; }
</style>
</cfoutput>
