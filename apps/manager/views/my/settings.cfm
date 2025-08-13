<cfoutput>
    <div id="my-settings-root">

        #pageTitle()#

        <div class="col-12">
            
            <section class="card">

                <div class="card-body">
                    
                    <div class="row g-5">

						<div class="col-12">
							<p>Gestisci le tue preferenze nell'applicazione.</p>

							#table( source = "items", rowTemplate="my/my-settings-grid-row-tmpl" )#

						</div>

                    </div>
                </div>                                
                
            </section>
            
        </div>
        
    </div>

</cfoutput>