<cfoutput>
	<div id="line-category-list-root">

        <div class="row">
            <div class="col-6" id="page-title">
				#pageTitle()#
            </div>
            <div class="col-6 d-flex align-items-center text-end mb-2">
                <div class="text-end text-nowrap">
                    Cambia categoria: 
                </div>
				<select class="form-control ms-2" name="categoryId" data-bind="events: { change: change }">
					<cfloop array="#prc.categories#" item="item">
						<option data-name="#item.getName()#" value="#item.getId()#" <cfif item.getId() == prc.category.getId()>SELECTED</cfif>>#item.getName()#</option>
					</cfloop>
				</select>
            </div>
        </div>

		<div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">

                        <div class="row d-flex align-items-center mb-2">

                            <div class="col-sm-8">

                                <div class="box-search-small"> 

                                    <form id="line-category-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind="events: { submit: search }"
                                        >

                                        <input name="str" placeholder="Filtra..." class="form-control me-2" type="text">

                                        <div style="align-self: flex-end;">
                                            #searchButton( bind="click:search" )#
                                        </div>

                                    </form>

                                </div>

                            </div>
                        </div>						

                        <div class="row d-flex align-items-center mb-2">

                            <div class="col-sm-10 text-end" id="line-category-status"></div>
                            <div class="col-sm-2 text-end mb-2">
                                #saveButton( bind="click:save", size="md" )#
                            </div>
                        </div>						

						<form name="line-category-grid-form" id="line-category-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "line-category-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'code', 'title':'Codice', width: '90px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'', 'title':'% Markup', width: '110px'},
                                        { 'field':'', 'title':'Duplica', width: '55px'},
                                        { 'field':'', 'title':'Possibili combinazioni', width: '55px'},
                                        { 'field':'', 'title':'Tutti gli attributi', width: '55px'}
                                    ]",
									rowTemplate = "line/line-category-grid-row-tmpl"
								)#
							</div>

						</form>
					</div>
				</section>
			</div>
		</div>

        #view("line/clone-modal")#;

	</div>

</cfoutput>
