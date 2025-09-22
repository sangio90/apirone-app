<cfoutput>
<div id="frame-list-root">

	<div class="row">
		<div class="col-6">
			#pageTitle()#
		</div>
		<div class="col-6 text-end pb-3">
			#addButton( bind = "click:new", size = "sm" )#
		</div>
	</div>

	<div class="row">
		<div class="col-lg-12">
			<section class="card">
				<div class="card-body">	

					<div class="row d-flex align-items-center mb-3">
						<div class="col-sm-8">
							<div class="box-search-small">
								<form 
									id   ="frame-grid-search-form"
									class="d-flex align-items-center justify-content-end"
									data-bind: 'events: { submit: search }'>

									<div class="col">
										<span>Cerca</span>
										<input type="text" class="form-control" id="search-code" placeholder="Cerca">
									</div>
									
									<div class="col">
										<span>Orientamento</label>
										<select class="form-select" id="search-orientation-id">
											<option value="">-- tutti</option>
											<option value="VER">Verticale</option>
											<option value="HOR">Orizzontale</option>
										</select>
									</div>

									<div class="align-self-end">
										#searchButton( bind = "click:search" )#
									</div>
								</form>									
							</div>
						</div>

						<div class="col-sm-4">
							<div class="float-end">
								#deleteButton( bind = "click:delete", size = "sm" )#
							</div>
						</div>
					</div>

					<form name="frame-grid-form" id="frame-grid-form" method="post">
						<div class="col-12">
							#grid(
								id      = "frame-grid",
								columns = "[
								{ 'field': 'shortId', 'title': 'ID', 'width': '80px' },
								{ 'field': 'code', 'title': 'Codice', 'width': '100px' },
								{ 'field': 'name', 'title': 'Nome' },
								{ 'field': 'orientation.name', 'title': 'Orient. armatura', 'width': '140px' },
								{ 'field': 'cellOrientation.name', 'title': 'Orient. celle', 'width': '140px' },
									{ 'field':'', 'title':'Modifica', width: '55px'},
									{ 
										'field'           :'', 
										'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
										'width'           :'40px',
										'headerAttributes': { 'class': 'text-center' }
									}
								]",
								rowTemplate = "frame/frame-grid-row-tmpl"
							)#
						</div>
					</form>
    
				</div>
			</section>
		</div>
	</div>
</div>

#view("frame/detail-modal")#

</cfoutput>