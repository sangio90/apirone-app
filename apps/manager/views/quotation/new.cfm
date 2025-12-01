<cfoutput>
    <div>
        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
			<div class="col-6 text-end mt-3">
				#button( href = "/manager/quotations", size = "sm", label = "Torna ai preventivi" )#
			</div>
        </div>

        <div class="row" id="quotation-header-root">
            <div class="col-lg-12">

                <section class="card">

                    <div class="card-body">                    
                        
                        <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-header-form">

                            #view("quotation/header-form")#

                            <div class="form-group quotation-button-box">
                                <div class="mt-2 d-flex justify-content-end align-items-center">
                                    <div class="save-status errors-counter mt-1 me-3"></div>
                                    <button class="btn btn-primary" data-bind="click:save"><i class="fa fa-save"></i> Salva</button>
                                </div>
                            </div>

                        </form>

                    </div>

                </section>                

            </div>

        </div>

    </div>
    
</cfoutput>
