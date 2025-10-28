<cfoutput>
    <div id="role-list-root">
       
        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
        </div>
        
        <div class="row">
            <div class="col-12">

                <section class="card">
                    
                    <div class="card-body">

                        <form name="role-grid-form" id="role-grid-form" method="get">
                            <div class="col-12">
								#grid(
									id = "role-grid",
									columns = "[
                                        { 'field':'id', 'title':'ID',  width: '10%' },
                                        { 'field':'name', 'title':'Nome' },
                                        { 'field':'', 'title':'Modifica', width: '10%'}
                                    ]",
									rowTemplate = "role/role-grid-row-tmpl"
								)#
							</div>

                        </form>
                    
                    </div>
                </section>
            </div>
        </div>

    </div>
    
    #view("role/detail")#

</cfoutput>