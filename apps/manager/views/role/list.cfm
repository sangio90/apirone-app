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
									id    = "role-grid",
                                    class = "no-pager",
									columns = "[
                                        { 'title':'ID',  width: '70px' },
                                        { 'title':'Nome' },
                                        { 'title':'', 'width' :'50px', 'headerAttributes': { 'class': 'text-center' } }
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
    
    #view("role/detail-modal")#

</cfoutput>