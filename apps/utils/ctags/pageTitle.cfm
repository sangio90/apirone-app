<!---- TODO: add breadcrumbs --->
<cfparam name="attributes.prc" type="Struct" required="true">

<cfoutput>
    <div class="row mb-3 page-title">
        <div class="col-lg-12">
            <h2>#attributes.prc.title#</h2>
            <cfif Len(attributes.prc.subtitle)><h4>#attributes.prc.subtitle#</h4></cfif>
        </div>
    </div>
</cfoutput>
