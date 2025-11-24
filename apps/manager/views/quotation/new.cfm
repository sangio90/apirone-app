<cfoutput>
    <div id="quotation-header-root">
        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
			<div class="col-6 text-end mt-3">
				#button( bind = "click:list", size = "sm", label = "Torna ai preventivi" )#
			</div>
        </div>

        <div class="row">
            <div class="col-lg-12">

				#view("quotation/header-form")#

            </div>

        </div>

    </div>
    
</cfoutput>
