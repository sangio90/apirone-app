<cfoutput>
    <div id="quotation-exported-root">

        <div class="row">
            <div class="col-6 pt-2">
				#pageTitle()#
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
                                        id="quotation-exported-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind="events: { submit: search }">

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <div style="align-self: flex-end;">
                                            #searchButton( bind="click:search" )#
                                        </div>

                                    </form>

                                </div>

                            </div>
                            <div class="col-sm-4" style="text-align: right">
                                #button( label='Cancella Selezionati  <i class="fas fa-trash" style="margin-left: 5px"></i>', bind="click:deleteSelected", variant="danger" )#
                            </div>
                        </div>						

						<form name="quotation-exported-grid-form" id="quotation-exported-grid-form" method="get">
							<div class="col-12">
								#grid(
									id      = "quotation-exported-grid",
									columns = "[
                                        { 'field':'company', 'title':'Ragione Sociale', width: '10%' },
                                        { 'field':'quotationSeriale', 'title':'Descrizione', width: '10%' },
                                        { 'field':'quotationCode', 'title':'Preventivo', width: '5%' },
                                        { 'field':'billingAddress', 'title':'Indirizzo Fatturazione', width: '20%'},
                                        { 'field':'shippingProfile', 'title':'Indirizzo Spedizione', width: '20%'},
                                        { 'field':'opportunity', 'title':'Note', width: '10%'},
                                        { 'field':'agent', 'title':'Note', width: '10%'},
                                        { 'field':'', 'title':'Azioni', width: '10%', 'headerAttributes': { 'class': 'justify-content-center' }},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'5%',
                                            'headerAttributes': { 'class': 'justify-content-center' }
                                        }
                                    ]",
									rowTemplate = "quotation-exported/quotation-exported-grid-row-tmpl"
								)#
							</div>

						</form>
					</div>
				</section>
			</div>
		</div>
    </div>
    #view( "quotation-exported/modal" )#
</cfoutput>