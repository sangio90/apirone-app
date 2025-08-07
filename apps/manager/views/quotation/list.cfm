<cfoutput>
    <div id="quotation-list-root">

        <div class="row">
            <div class="col-6 pt-2">
				#pageTitle()#
            </div>
			<div class="col-6 text-end">
				#addButton( bind = "click:new", size = "md", label = "Aggiungi preventivo" )#
			</div>
        </div>

        <div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">

                        <div class="row d-flex align-items-center mb-2">
                            <div class="col-sm-8">
                                <div class="box-search-small"> 
                                    <form 
                                        id="quotation-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind="events: { submit: search }">

                                        <input name="strDescription" placeholder="Cerca per nome" class="form-control me-2" type="text">
                                        <input name="strNumber" placeholder="Cerca per numero" class="form-control me-2" type="text">

										<select class="form-control me-2" name="statusId">
											<option value="">-- tutti gli stati</option>
											<cfloop array="#prc.statuses#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>

                                        <input type="date" name="fromDate" class="form-control" id="fromDate">

                                        <input type="date" name="toDate" class="form-control me-2" id="toDate">

                                        <div style="align-self: flex-end;">
                                            #searchButton( bind="click:search" )#
                                        </div>

                                    </form>

                                </div>

                            </div>
                        </div>						

						<form name="quotation-grid-form" id="quotation-grid-form" method="get">
							<div class="col-12">
								#grid(
									id      = "quotation-grid",
									columns = "[
                                        { 'field':'', 'title':'', width: '5%' },
                                        { 'field':'description', 'title':'Nome' },
                                        { 'field':'quotation_number', 'title':'Numero', width: '15%' },
                                        { 'field':'quotation_date', 'title':'Data', width: '15%'},
                                        { 'field':'status', 'title':'Stato', width: '15%'},
                                        { 'field':'', 'title':'Modifica', width: '10%' }
                                    ]",
									rowTemplate = "quotation/quotation-grid-row-tmpl"
								)#
							</div>

						</form>
					</div>
				</section>
			</div>
		</div>
    </div>
</cfoutput>