<cfparam name="attributes.title" default="js">
<cfparam name="attributes.breadcrumbs" default="#ArrayNew(1)#">
<cfparam name="attributes.active" default="id">

<cfoutput>
    <section class="page-header page-header-modern page-header-lg bg-tertiary border-0 my-0">
        <div class="container my-3">
            <div class="row">
                <div class="col-md-12 align-self-center p-static order-2 text-center">
                    <h1 class="font-weight-bold text-10">#attributes.title#</h1>
                </div>
                <div class="col-md-12 align-self-center order-1">
                    <ul class="breadcrumb breadcrumb-light d-block text-center">
                        <cfloop array="#attributes.breadcrumbs#" index="item">
                            <li><a href="#item.url#" 
                                <cfif item.id is attributes.active>class="active"</cfif>>#item.name#</a>
                            </li>
                        </cfloop>
                    </ul>
                </div>
            </div>
        </div>
    </section>
</cfoutput>